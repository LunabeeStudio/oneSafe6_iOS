//
//  UseCase+Archive.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 06/12/2022 - 15:19.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import UIKit
import Model
import CoreCrypto
import Combine
import Protocols
import Errors
import LBFoundationKit
import oneSafeKmp

public extension UseCase {
    static func isArchiveFile(_ url: URL) -> Bool {
        archiveRepository.archiveExtensions.contains(url.pathExtension)
    }
}

public extension UseCase {
    static func archiveSupportedVersion() -> Int {
        archiveRepository.supportedVersion
    }
}

// MARK: - Sharing -
public extension UseCase {
    static func getSharableData(for safeItem: SafeItem, includeSubItems: Bool) async throws -> ExportData {
        var parentItem: SafeItem = safeItem
        parentItem.parentId = nil
        let items: [SafeItem] = await [parentItem] + (includeSubItems ? try getAllSubItemsRecursively(item: safeItem) : [])
        let itemsData: (fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], fileUrls: [URL]) = try await getSafeItemsData(safeItems: items)
        return ExportData(
            items: items,
            fields: itemsData.fields,
            keys: itemsData.keys,
            iconsUrls: itemsData.iconsUrls,
            fileUrls: itemsData.fileUrls
        )
    }
}

// MARK: - Backup export -
public extension UseCase {
    static func getArchivableData() async throws -> ExportData {
        let items: [SafeItem] = try safeItemRepository.getAllItems()
        let itemsData: (fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], fileUrls: [URL]) = try await getSafeItemsData(safeItems: items)
        let bubblesData: (
            contacts: [Model.Contact],
            keys: [Model.ContactLocalKey],
            messages: [Model.SafeMessage],
            conversations: [Model.EncConversation],
            masterKey: Data
        ) = try await getBubblesDataForExport()
        return ExportData(
            items: items,
            fields: itemsData.fields,
            keys: itemsData.keys,
            iconsUrls: itemsData.iconsUrls,
            fileUrls: itemsData.fileUrls,
            bubblesContacts: bubblesData.contacts,
            bubblesContactsKeys: bubblesData.keys,
            messages: bubblesData.messages,
            conversations: bubblesData.conversations,
            bubblesMasterKey: bubblesData.masterKey
        )
    }

    static func backup(exportData: ExportData,
                       kind: ArchiveKind,
                       password: String? = nil,
                       progressProvider: (@MainActor (_ progress: Progress) -> Void)? = nil) async throws -> URL {
        try await archive(exportData: exportData, password: password, archiveKind: kind, progressProvider: progressProvider)
    }

    static func clearArchiveExportFiles() throws {
        try archiveRepository.clearExportArchiveFiles()
    }

    static func setLastManualBackupDate() {
        archiveRepository.setLastManualBackupDate(.now)
    }
}

// MARK: - Backup import -
public extension UseCase {
    static func extractArchiveData(url: URL, progressProvider: (@MainActor (_ progress: Progress) -> Void)? = nil) async throws -> ArchiveInfo {
        try await extractArchiveInfo(url: url, progressProvider: progressProvider)
    }

    static func analyzeArchiveDataToImport(archiveInfo: ArchiveInfo, password: String, progressProvider: @escaping @MainActor (_ progress: Progress) -> Void) async throws -> ArchiveInfo {
        try clearImportData()
        return try await prepareArchiveDataImport(archiveInfo: archiveInfo, password: password, progressProvider: progressProvider)
    }

    /// Returns the ids of the SafeItem added to the safe which don't have parent.
    @discardableResult static func finalizeArchiveDataImport(archiveInfo: ArchiveInfo, mode: ArchiveImportMode, progressProvider: @escaping @MainActor (_ progress: Progress) -> Void) async throws -> [String] {
        guard let masterKey = archiveInfo.archiveMasterKey else { throw AppError.archiveDataNoMasterKeyForImport }

        let newParentItemIds: [String]

        switch mode {
        case let .append(parentInfo):
            if let parentInfo {
                try await createParentItemImport(parentName: parentInfo.parentName, parentColor: parentInfo.parentColor, parentKey: parentInfo.parentKey)
            }

            newParentItemIds = try await processDataTransferFromImportToMain(
                fromMasterKey: masterKey,
                archiveEncBubblesMasterKey: archiveInfo.archiveEncBubblesMasterKey,
                shouldImportItems: archiveInfo.shouldImportItems,
                shouldImportBubbles: archiveInfo.shouldImportBubbles,
                progressProvider: progressProvider
            )
        case .replace:
            try deleteAllItems()
            try await deleteAllSearchIndex()
            newParentItemIds = try await processDataTransferFromImportToMain(
                fromMasterKey: masterKey,
                archiveEncBubblesMasterKey: archiveInfo.archiveEncBubblesMasterKey,
                shouldImportItems: archiveInfo.shouldImportItems,
                shouldImportBubbles: archiveInfo.shouldImportBubbles,
                needRegenerateIds: false,
                progressProvider: progressProvider
            )
        }

        try await reindexItemsForAlphabeticalSorting()
        try await reindexItemsForConsultedAtSorting()
        try await reindexItemsForCreatedAtSorting()

        try clearArchiveImportData()
        try await clearDeletedSafeItems()

        return newParentItemIds
    }

    static func clearArchiveImportData() throws {
        try clearImportData()
        try clearImportFiles()
    }
}

// MARK: Auto backup
public extension UseCase {
    static func getMaximumNumberOfAutoBackups() -> Int {
        Constant.Archive.maximumAutoBackups
    }

    static func getLastAutoBackupDate() -> Date? {
        archiveRepository.lastAutoBackupDate
    }

    static func shouldAutoBackup() -> Bool {
        guard settingsRepository.isAutoBackupEnabled() else { return false }
        guard (try? safeItemRepository.getAllKeys().count) ?? 0 > 0 else { return false }
        let lastAutoBackupDate: Date = archiveRepository.lastAutoBackupDate ?? .distantPast
        let frequency: AutoBackupFrequencyOption = settingsRepository.getAutoBackupFrequencyOption()
        switch frequency {
        case .everyDay:
            return lastAutoBackupDate.addingTimeInterval(.hours(24)) < .now
        case .everyWeek:
            return lastAutoBackupDate.addingTimeInterval(.days(7)) < .now
        case .everyMonth:
            return lastAutoBackupDate.addingTimeInterval(.days(30)) < .now
        }
    }

    // This method must be async as iCloud Drive url call must not be called from the main thread (Apple recommendation).
    static func storeAutoBackup(backupUrl: URL) async throws {
        // Move the backup file in the correct location
        if settingsRepository.isAutoBackupICloudEnabled() {
            try removeOldestICloudDriveBackupIfNeeded()
            try archiveRepository.copyAutoBackupToICloudDrive(backupUrl: backupUrl)
            if settingsRepository.isAutoBackupLocalEnabled() {
                try removeOldestLocalBackupIfNeeded()
                try archiveRepository.moveAutoBackupToLocalDirectory(backupUrl: backupUrl)
            } else {
                try FileManager.default.removeItem(at: backupUrl)
            }
        } else {
            try removeOldestLocalBackupIfNeeded()
            try archiveRepository.moveAutoBackupToLocalDirectory(backupUrl: backupUrl)
        }

        // Update last auto backup succeeded date for next time
        archiveRepository.updateLastAutoBackupDate(.now)
    }

    static func getAutoBackupDirectoryUrl() throws -> URL {
        try archiveRepository.getAutoBackupDirectoryUrl()
    }

    static func getAutoBackupICloudDriveDirectoryUrl() throws -> URL {
        try archiveRepository.getAutoBackupICloudDriveDirectoryUrl()
    }

    static func getLastBackupURL() async -> URL? {
        let localBackupUrls: [URL] = (try? archiveRepository.getAllLocalAutoBackupUrls()) ?? []
        let iCloudBackupUrls: [URL] = (try? archiveRepository.getAllICloudAutoBackupUrls()) ?? []

        return (localBackupUrls + iCloudBackupUrls).sorted { lhs, rhs in
            lhs.lastPathComponent > rhs.lastPathComponent
        }.first
    }
}

// MARK: - Private Backup export -
private extension UseCase {
    static func getSafeItemsData(safeItems: [SafeItem]) async throws -> (fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], fileUrls: [URL]) {
        let itemsIds: [String] = safeItems.map(\.id)
        let fields: [SafeItemField] = try await safeItemRepository.getFields(for: itemsIds)
        let keys: [SafeItemKey] = try await safeItemRepository.getKeys(for: itemsIds)
        let iconsIds: [String] = safeItems.compactMap(\.iconId)
        let iconsUrls: [URL] = try safeItemIconRepository.getAllIconsUrls(for: iconsIds)
        let fileUrls: [URL] = try await getFilesUrls(for: safeItems)

        return (fields, keys, iconsUrls, fileUrls)
    }

    static func getBubblesDataForExport() async throws -> (
        contacts: [Model.Contact],
        keys: [Model.ContactLocalKey],
        messages: [Model.SafeMessage],
        conversations: [Model.EncConversation],
        masterKey: Data
    ) {
        let kmpContacts: [oneSafeKmp.Contact] = contactRepository.getAllContacts()
        let contacts: [Model.Contact] = kmpContacts.map { .from(kmpModel: $0) }
        let keys: [Model.ContactLocalKey] = try await kmpContacts.asyncMap { try await getContactLocalKey(contactId: $0.id) }
        let messages: [Model.SafeMessage] = try messageRepository.getAllMessages()
        let conversations: [Model.EncConversation] = try await conversationsRepository
            .getAllConversations()
            .asyncCompactMap {
                try? await convertBubblesConversationPrivateKeySec1DerToPKCS8Der(encConversation: $0)
            }
        let masterKey: Data = try cryptoRepository.getEncBubblesMasterKey()
        return (contacts, keys, messages, conversations, masterKey)
    }

    static func getFilesUrls(for items: [SafeItem]) async throws -> [URL] {
        try await withThrowingTaskGroup(of: [URL].self) { itemsGroup in
            for item in items {
                itemsGroup.addTask {
                    let fields: [SafeItemField] = try safeItemRepository.getFields(for: item.id)
                    guard let key = try safeItemRepository.getKey(for: item.id) else { throw AppError.cryptoNoKeyForDecryption }
                    return try await withThrowingTaskGroup(of: Optional<URL>.self, body: { fieldsGroup in
                        for field in fields {
                            fieldsGroup.addTask {
                                guard let kind = try SafeItemField.Kind(rawValue: getStringFromEncryptedData(data: field.encKind, key: key) ?? "") else {
                                    throw AppError.appUnknown
                                }
                                guard [.file, .photo, .video].contains(kind) else {
                                    return nil
                                }
                                guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else {
                                    throw AppError.fileNoId
                                }
                                guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else {
                                    throw AppError.fileNoId
                                }
                                do {
                                    return try fileRepository.getEncryptedFileUrlInStorage(fileId: fileId)
                                } catch {
                                    throw error
                                }
                            }
                        }
                        return try await fieldsGroup.collect().compactMap()
                    })
                }
            }
            return try await itemsGroup.collect().flatMap { $0 }
        }
    }

    static func archive(exportData: ExportData,
                        password: String? = nil,
                        archiveKind: ArchiveKind,
                        progressProvider: (@MainActor (_ progress: Progress) -> Void)? = nil) async throws -> URL {
        let coreCrypto: CoreCrypto = .shared

        try archiveRepository.clearExportArchiveFiles()

        // Progress management.
        let reencryptionStepsInMainProgress: Int64 = 2
        let archiveDataCreationStepsInMainProgress: Int64 = 1
        let iconsStepsInMainProgress: Int64 = 1
        let filesStepsInMainProgress: Int64 = 1
        let archiveStepsInMainProgress: Int64 = 4

        let baseMainProgressSteps: Int64 = archiveDataCreationStepsInMainProgress + iconsStepsInMainProgress + archiveStepsInMainProgress

        let totalMainProgressSteps: Int64 = password == nil ? baseMainProgressSteps : baseMainProgressSteps + reencryptionStepsInMainProgress

        let progress: Progress = .init(totalUnitCount: totalMainProgressSteps)
        await progressProvider?(progress)

        let archiveDataCreationProgress: Progress = .init()
        progress.addChild(archiveDataCreationProgress, withPendingUnitCount: archiveDataCreationStepsInMainProgress)

        let iconsProgress: Progress = .init()
        progress.addChild(iconsProgress, withPendingUnitCount: iconsStepsInMainProgress)

        let filesProgress: Progress = .init()
        progress.addChild(filesProgress, withPendingUnitCount: filesStepsInMainProgress)

        let archiveLocalProgress: Progress = .init()
        let archiveExposedProgress: Progress = .init()
        progress.addChild(archiveExposedProgress, withPendingUnitCount: archiveStepsInMainProgress)

        let keysToExport: [SafeItemKey]
        let toSalt: Data
        let cryptoToken: Data?

        if let password {
            let keysReencryptionProgress: Progress = .init(totalUnitCount: Int64(exportData.keys.count))
            progress.addChild(keysReencryptionProgress, withPendingUnitCount: reencryptionStepsInMainProgress)

            // In the case a specific password is provided, the keys must be reencrypted to be archived.
            toSalt = coreCrypto.generateSalt()
            let toMasterKey: Data = try coreCrypto.derive(password: password, salt: toSalt)

            if let currentCryptoToken = try cryptoRepository.cryptoToken() {
                let decryptedToken: Data = try coreCrypto.decrypt(value: currentCryptoToken, scope: .main)
                cryptoToken = try coreCrypto.encrypt(value: decryptedToken, key: toMasterKey)
            } else {
                cryptoToken = nil
            }

            keysToExport = try await withThrowingTaskGroup(of: SafeItemKey.self) { taskGroup in
                for key in exportData.keys {
                    taskGroup.addTask {
                        let keyId: String = key.id
                        let encryptedValue: Data = key.value

                        let value: Data = try coreCrypto.decrypt(value: encryptedValue)
                        let reencryptedValue: Data = try coreCrypto.encrypt(value: value, key: toMasterKey)

                        RunLoop.main.perform {
                            keysReencryptionProgress.completedUnitCount += 1
                        }
                        return .init(id: keyId, value: reencryptedValue)
                    }
                }

                return try await taskGroup.collect()
            }
        } else {
            toSalt = try cryptoRepository.getMasterSalt()
            cryptoToken = try cryptoRepository.cryptoToken()
            keysToExport = exportData.keys
        }

        var updatedExportData: ExportData = exportData
        updatedExportData.keys = keysToExport

        try archiveRepository.writeExportArchiveMetadata(
            archiveKind: archiveKind,
            itemsCount: updatedExportData.items.count,
            contactsCount: updatedExportData.bubblesContacts.count,
            cryptoToken: cryptoToken
        )
        try await archiveRepository.writeExportArchiveData(
            exportData: updatedExportData,
            toSalt: toSalt,
            progress: archiveDataCreationProgress
        )

        // We now store all the icons to the temporary creation directory.
        try await archiveRepository.copyIconsToIconsExport(iconsUrls: updatedExportData.iconsUrls, progress: iconsProgress)

        // Copy files to the temporary creation directory
        try await archiveRepository.copyFilesToFilesExport(filesUrls: updatedExportData.fileUrls, progress: filesProgress)

        // The following is necessary due to a threading issue: a progress object linked to a UIProgressView can't be updated out of the main thread.
        // So here, as the unzip function is not launched in the main thread, it will update the localProgress in a background thread.
        // Then, we observe theses updates and we update the exposedProgress values but this time from the main thread not to have the app crashing.
        let cancellable: AnyCancellable = archiveLocalProgress.publisher(for: \.fractionCompleted)
            .throttle(for: 0.05, scheduler: DispatchQueue(label: #function), latest: true)
            .receive(on: RunLoop.main)
            .sink { _ in
                archiveExposedProgress.totalUnitCount = archiveLocalProgress.totalUnitCount
                archiveExposedProgress.completedUnitCount = archiveLocalProgress.completedUnitCount
            }

        // We create the archive.
        let destinationUrl: URL = try archiveRepository.zipArchive(archiveKind: archiveKind, progress: archiveLocalProgress)

        // We can now remove the progress observer.
        cancellable.cancel()

        return destinationUrl
    }
}

// MARK: - Private Backup Import -
private extension UseCase {

    static func extractArchiveInfo(url: URL, progressProvider: (@MainActor (_ progress: Progress) -> Void)? = nil) async throws -> ArchiveInfo {
        // We create a progress instance to be able to monitor the archive unarchiving progress.
        let localProgress: Progress = .init()
        let exposedProgress: Progress = .init()
        await progressProvider?(exposedProgress)
        try clearArchiveImportData()

        // We copy the archive to the temporary inbox directory.
        let inboxArchiveUrl: URL = try archiveRepository.copyArchiveToImportToInbox(archiveUrl: url)

        // The following is necessary due to a threading issue: a progress object linked to a UIProgressView can't be updated out of the main thread.
        // So here, as the unzip function is not launched in the main thread, it will update the localProgress in a background thread.
        // Then, we observe theses updates and we update the exposedProgress values but this time from the main thread not to have the app crashing.
        let cancellable: AnyCancellable = localProgress.publisher(for: \.fractionCompleted)
            .throttle(for: 0.05, scheduler: DispatchQueue(label: #function), latest: true)
            .receive(on: RunLoop.main)
            .sink { _ in
                exposedProgress.totalUnitCount = localProgress.totalUnitCount
                exposedProgress.completedUnitCount = localProgress.completedUnitCount
            }

        // We unarchive the archive.
        let archiveExtractionUrl: URL = try archiveRepository.unzipArchive(inboxArchiveUrl: inboxArchiveUrl, progress: localProgress)

        // We can now remove the progress observer.
        cancellable.cancel()

        return try archiveRepository.getImportArchiveInfo(archiveExtractionUrl: archiveExtractionUrl)
    }

    static func prepareArchiveDataImport(archiveInfo: ArchiveInfo, password: String, progressProvider: @escaping @MainActor (_ progress: Progress) -> Void) async throws -> ArchiveInfo {
        // This function we'll try to decrypt the backup data and, if it succeeds to, it will store the data to import into a temporary dedicated database, waiting for the user to choose between appending or replacing the data.
        let coreCrypto: CoreCrypto = .shared

        let archiveContentPart: Int64 = 4
        let iconsPart: Int64 = 1
        let filesPart: Int64 = 1
        let totalSteps: Int64 = archiveContentPart + iconsPart

        let progress: Progress = .init(totalUnitCount: totalSteps)

        let archiveContentProgress: Progress = .init()
        progress.addChild(archiveContentProgress, withPendingUnitCount: archiveContentPart)

        let iconsProgress: Progress = .init()
        progress.addChild(iconsProgress, withPendingUnitCount: iconsPart)

        let filesProgress: Progress = .init()
        progress.addChild(filesProgress, withPendingUnitCount: filesPart)

        await progressProvider(progress)

        // First, we get the url to access the archive export directory.
        let archiveExtractionUrl: URL = archiveInfo.archiveDirectoryUrl

        var archiveContent: ArchiveImportContent = try await archiveRepository.getImportArchiveContent(
            archiveExtractionUrl: archiveExtractionUrl,
            safeId: bubblesSafeRepository.currentSafeId().uuidString(),
            progress: archiveContentProgress
        )

        let iconsUrls: [URL] = try archiveRepository.getImportArchiveIconsUrls(archiveExtractionUrl: archiveExtractionUrl)
        let filesUrls: [URL] = try archiveRepository.getImportArchiveFilesUrls(archiveExtractionUrl: archiveExtractionUrl)

        // We calculate the masterkey needed to reencrypt the keys when we'll process import.
        let masterKey: Data = try coreCrypto.derive(password: password, salt: archiveContent.salt)

        let keysById: [String: SafeItemKeyImport] = .init(archiveContent.keys.map { ($0.id, $0) }) { _, last in
            last
        }
        var itemIdsWithNotDecryptableData: Set<String> = []
        var decryptableFilesIds: Set<String> = []
        var filteredFields: [SafeItemFieldImport] = archiveContent.fields.compactMap {
            guard let encValue = $0.encValue else { return $0 }
            do {
                let keyData: Data = try coreCrypto.decrypt(
                    value: keysById[$0.itemId]!.value,
                    key: masterKey
                )
                let data: Data = try coreCrypto.decrypt(value: encValue, key: keyData)
                if let value = String(data: data, encoding: .utf8), let fileId = value.components(separatedBy: "|").first, value.contains("|") {
                    decryptableFilesIds.insert(fileId)
                }
                return $0
            } catch {
                itemIdsWithNotDecryptableData.insert($0.itemId)
                return nil
            }
        }
        let filteredItems: [SafeItemImport] = archiveContent.items.filter { !itemIdsWithNotDecryptableData.contains($0.id) }
        let decryptableItemsIconIds: [String] = filteredItems.compactMap { $0.iconId }
        filteredFields = filteredFields.filter { !itemIdsWithNotDecryptableData.contains($0.itemId) }
        let filteredKeys: [SafeItemKeyImport] = archiveContent.keys.filter { !itemIdsWithNotDecryptableData.contains($0.id) }

        archiveContent = .init(
            items: filteredItems,
            fields: filteredFields,
            keys: filteredKeys,
            contacts: archiveContent.contacts,
            contactsKeys: archiveContent.contactsKeys,
            messages: archiveContent.messages,
            conversations: archiveContent.conversations,
            encBubblesMasterKey: archiveContent.encBubblesMasterKey,
            salt: archiveContent.salt
        )

        // Now we must check if the provided password is correct.
        if let cryptoToken = archiveInfo.cryptoToken {
            let token: String = try coreCrypto.decryptToString(value: cryptoToken, key: masterKey)
            guard UUID(uuidString: token) != nil else { throw AppError.cryptoWrongPassword }
        } else {
            guard let key = archiveContent.keys.first else { throw AppError.archiveNoKeyInArchive }
            _ = try coreCrypto.decrypt(value: key.value, key: masterKey)
        }

        var updatedArchiveInfo: ArchiveInfo = archiveInfo
        updatedArchiveInfo.archiveMasterKey = masterKey
        updatedArchiveInfo.archiveEncBubblesMasterKey = archiveContent.encBubblesMasterKey // We do not have access to archive content later so we pass the bubbles master key into the archive info

        // We save all our data to import into a dedicated database.
        try safeItemImportRepository.save(items: archiveContent.items)
        try safeItemImportRepository.save(keys: archiveContent.keys)
        try safeItemImportRepository.save(fields: archiveContent.fields)

        let filteredIconsUrls: [URL] = iconsUrls.filter {
            decryptableItemsIconIds.contains($0.lastPathComponent)
        }
        let filteredFilesUrls: [URL] = filesUrls.filter {
            decryptableFilesIds.contains($0.lastPathComponent)
        }
        try await safeItemIconImportRepository.saveImportIcons(for: filteredIconsUrls, progress: iconsProgress)
        try await safeItemFileImportRepository.saveImportFiles(for: filteredFilesUrls, progress: filesProgress)

        try bubblesImportRepository.save(contacts: archiveContent.contacts)
        try bubblesImportRepository.save(contactKeys: archiveContent.contactsKeys)
        try bubblesImportRepository.save(messages: archiveContent.messages)
        try bubblesImportRepository.save(conversations: archiveContent.conversations)

        updatedArchiveInfo.hasBubblesData = !archiveContent.contacts.isEmpty

        return updatedArchiveInfo
    }

    static func createParentItemImport(parentName: String, parentColor: String, parentKey: SafeItemKey) async throws {
        // If we are appending the data, we update all the archive root items to add them as child of the import grouping item.
        let parentItemInfo: (item: SafeItem, encIconData: Data?, iconId: String?, key: SafeItemKey) = try await createImportParentItem(name: parentName, color: parentColor, key: parentKey)
        let updatedItems: [SafeItemImport] = try safeItemImportRepository.getRootItems().map {
            var item: SafeItemImport = $0
            item.parentId = parentItemInfo.item.id
            return item
        }

        var parentItem: SafeItem = parentItemInfo.item
        parentItem.updatedAt = Date()
        // In the case the parent item has an icon, we write its data to the icons import directory.
        if let encIconData = parentItemInfo.encIconData, let iconId = parentItemInfo.iconId {
            try safeItemIconImportRepository.saveIconData(encIconData, iconId: iconId)
        }

        // We write the import grouping item and the updated items to the temporary import database.
        try safeItemImportRepository.save(items: updatedItems)
        try safeItemRepository.save(items: [parentItem])

        // This key can directly be saved to the main db as it is encrypted for the current safe.
        try safeItemRepository.save(keys: [parentItemInfo.key])
    }

    /// Returns the ids of the SafeItem added to the safe which don't have parent.
    private static func processDataTransferFromImportToMain(fromMasterKey: Data, archiveEncBubblesMasterKey: Data?, shouldImportItems: Bool, shouldImportBubbles: Bool, needRegenerateIds: Bool = true, progressProvider: @escaping @MainActor (_ progress: Progress) -> Void) async throws -> [String] {
        let coreCrypto: CoreCrypto = .shared

        let getItemDataPart: Int64 = 1
        let getBubblesDataPart: Int64 = 1
        let reencryptionPart: Int64 = 1
        let iconsPart: Int64 = 1
        let filesPart: Int64 = 1
        let savePart: Int64 = 1
        let indexPart: Int64 = 4
        let totalSteps: Int64 = (shouldImportItems ? getItemDataPart + reencryptionPart + iconsPart + filesPart + savePart + indexPart : 0) + (shouldImportBubbles ? getBubblesDataPart : 0)

        let progress: Progress = .init(totalUnitCount: totalSteps)

        let getBubblesDataProgress: Progress = .init()
        if shouldImportBubbles {
            progress.addChild(getBubblesDataProgress, withPendingUnitCount: getBubblesDataPart)
        }

        let getItemDataProgress: Progress = .init()
        let reencryptionProgress: Progress = .init()
        let iconsProgress: Progress = .init()
        let filesProgress: Progress = .init()
        let saveProgress: Progress = .init(totalUnitCount: 3)
        let indexProgress: Progress = .init()
        let idsRegenerationProgress: Progress?

        if shouldImportItems {
            progress.addChild(getItemDataProgress, withPendingUnitCount: getItemDataPart)
            progress.addChild(reencryptionProgress, withPendingUnitCount: reencryptionPart)
            progress.addChild(iconsProgress, withPendingUnitCount: iconsPart)
            progress.addChild(filesProgress, withPendingUnitCount: filesPart)
            progress.addChild(saveProgress, withPendingUnitCount: savePart)
            progress.addChild(indexProgress, withPendingUnitCount: indexPart)

            idsRegenerationProgress = needRegenerateIds ? {
                let idsRegenerationPart: Int64 = 1
                let idsRegenerationProgress: Progress = .init()
                progress.totalUnitCount += idsRegenerationPart
                progress.addChild(idsRegenerationProgress, withPendingUnitCount: idsRegenerationPart)
                return idsRegenerationProgress
            }() : nil
        } else {
            idsRegenerationProgress = nil
        }

        await progressProvider(progress)

        var newParentItemIds: [String] = []

        if shouldImportItems {
            let (items, fields, keys): ([SafeItem], [SafeItemField], [SafeItemKey]) = try await safeItemImportRepository.getAllDataToImport(progress: getItemDataProgress)

            reencryptionProgress.totalUnitCount = Int64(keys.count)

            // Reencrypt SafeItemKey with local master key
            let reencryptedKeys: [SafeItemKey] = try await withThrowingTaskGroup(of: SafeItemKey.self) { taskGroup in
                for key in keys {
                    taskGroup.addTask {
                        let keyId: String = key.id
                        let encryptedValue: Data = key.value

                        let value: Data = try coreCrypto.decrypt(value: encryptedValue, key: fromMasterKey)
                        let reencryptedValue: Data = try coreCrypto.encrypt(value: value)
                        await MainActor.run { reencryptionProgress.completedUnitCount += 1 }
                        return .init(id: keyId, value: reencryptedValue)
                    }
                }
                return try await taskGroup.collect()
            }

            // We change all our data objects ids to be sure to not conflicts with ids already used in the current app database.
            let iconsUrls: [URL] = try safeItemIconImportRepository.allImportIconsUrls()
            let filesUrls: [URL] = try safeItemFileImportRepository.allImportFilesUrls()

            let updatedItemsData: (items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], filesUrls: [URL])

            if let idsRegenerationProgress {
                // We change all our data objects ids to be sure to not conflicts with ids already used in the current app database.
                updatedItemsData = try await regenerateItemsIds(items: items, fields: fields, keys: reencryptedKeys, iconsUrls: iconsUrls, filesUrls: filesUrls, progress: idsRegenerationProgress)
            } else {
                updatedItemsData = (items: items, fields: fields, keys: reencryptedKeys, iconsUrls: iconsUrls, filesUrls: filesUrls)
            }

            newParentItemIds = updatedItemsData.items.filter { $0.parentId == nil }.map(\.id)

            try await safeItemIconImportRepository.processIconsImport(progress: iconsProgress)
            try await safeItemFileImportRepository.processFilesImport(progress: filesProgress)
            try safeItemRepository.save(keys: updatedItemsData.keys)
            await MainActor.run { saveProgress.completedUnitCount += 1 }
            try safeItemRepository.save(fields: updatedItemsData.fields)
            await MainActor.run { saveProgress.completedUnitCount += 1 }
            try safeItemRepository.save(items: updatedItemsData.items)
            await MainActor.run { saveProgress.completedUnitCount += 1 }
            try await indexItems(updatedItemsData.items, progress: indexProgress)
        }

        if shouldImportBubbles {
            let (contacts, contactsKeys, messages, conversations): ([Model.Contact], [Model.ContactLocalKey], [Model.SafeMessage], [Model.EncConversation]) = try await bubblesImportRepository.getAllDataToImport(progress: getBubblesDataProgress)

            // Reencrypt ContactLocalKey with local bubbles master key.
            var reencryptedContactsKeys: [Model.ContactLocalKey] = []
            if let archiveEncBubblesMasterKey {
                let archiveBubblesMasterKey: Data = try coreCrypto.decrypt(value: archiveEncBubblesMasterKey, key: fromMasterKey)
                reencryptedContactsKeys = try await withThrowingTaskGroup(of: Model.ContactLocalKey.self) { taskGroup in
                    for key in contactsKeys {
                        taskGroup.addTask {
                            do {
                                let keyValue: Data = try coreCrypto.decrypt(value: key.encKey, key: archiveBubblesMasterKey)
                                let reencryptedKeyValue: Data = try coreCrypto.encrypt(value: keyValue, scope: .bubbles)
                                return ContactLocalKey(contactId: key.contactId, encKey: reencryptedKeyValue)
                            } catch {
                                print(error)
                                throw error
                            }
                        }
                    }
                    return try await taskGroup.collect()
                }
            }

            let updatedBubblesData: (contacts: [Model.Contact], contactsKeys: [Model.ContactLocalKey], messages: [Model.SafeMessage], conversations: [Model.EncConversation])

            updatedBubblesData = (contacts, reencryptedContactsKeys, messages, conversations)

            // If there is Bubbles data to import, we first delete existing Bubbles data.
            try deleteAllBubblesData()

            for contact in updatedBubblesData.contacts {
                guard let key = reencryptedContactsKeys.first(where: { $0.contactId == contact.id }) else { continue }
                try await contactRepository.saveContact(contact: contact.toKMPModel(), key: key.toKMPModel())
            }

            for message in updatedBubblesData.messages {
                try await messageRepository.save(message: message.toKMPSafeMessageModel(), order: message.order)
            }

            for conversation in updatedBubblesData.conversations {
                try await conversationsRepository.insert(conversation: conversation.toKMPModel())
            }
        }

        return newParentItemIds
    }
}

// MARK: - Private data clearing -
private extension UseCase {
    static func clearImportData() throws {
        try safeItemImportRepository.deleteAllItems()
        try safeItemImportRepository.deleteAllKeys()
        try safeItemIconImportRepository.deleteAllImportIcons()
        try safeItemFileImportRepository.deleteAllImportFiles()
        try bubblesImportRepository.deleteAll()
    }

    static func clearImportFiles() throws {
        try archiveRepository.clearImportArchiveFiles()
    }
}

// MARK: - Utils -
private extension UseCase {
    static func createImportParentItem(name: String, color: String, key: SafeItemKey) async throws -> (item: SafeItem, encIconData: Data?, iconId: String?, key: SafeItemKey) {
        let coreCrypto: CoreCrypto = .shared

        let position: Double = try (safeItemRepository.getItems(parentId: nil).sorted { $0.position < $1.position }.last?.position).map { $0 + 1.0 } ?? 0.0
        let icon: Data? = UIImage(named: "BackupIcon")?.pngData()
        var iconId: String?
        var encIconData: Data?
        let color: String = color

        let keyValue: Data = try coreCrypto.decrypt(value: key.value)

        var item: SafeItem = .init(id: key.id, position: position)
        item.encName = try coreCrypto.encrypt(value: name, key: keyValue)
        item.encColor = try coreCrypto.encrypt(value: color, key: keyValue)

        if let icon {
            let existingIconsIds: Set<String> = .init(try safeItemIconRepository.getAllIconsUrls().map { $0.deletingPathExtension().lastPathComponent })
            var newIconId: String = UUID().uuidStringV4
            while existingIconsIds.contains(newIconId) { newIconId = UUID().uuidStringV4 }
            iconId = newIconId
            encIconData = try coreCrypto.encrypt(value: icon, key: keyValue)
            item.iconId = newIconId
        }

        return (item, encIconData, iconId, key)
    }
}

// MARK: - Private Auto Backup -
private extension UseCase {
    static func removeOldestLocalBackupIfNeeded() throws {
        let existingBackupUrls: [URL] = (try? archiveRepository.getAllLocalAutoBackupUrls()) ?? []
        if existingBackupUrls.count >= Constant.Archive.maximumAutoBackups {
            let backupToDeleteUrls: [URL] = try sortBackupUrlsByAscendingDate(existingBackupUrls).dropLast(Constant.Archive.maximumAutoBackups - 1)
            // Delete oldest backups
            try backupToDeleteUrls.forEach {
                try FileManager.default.removeItem(at: $0)
            }
        }
    }

    static func removeOldestICloudDriveBackupIfNeeded() throws {
        let existingBackupUrls: [URL] = (try? archiveRepository.getAllICloudAutoBackupUrls()) ?? []
        if existingBackupUrls.count >= Constant.Archive.maximumAutoBackups {
            let backupToDeleteUrls: [URL] = try sortBackupUrlsByAscendingDate(existingBackupUrls).dropLast(Constant.Archive.maximumAutoBackups - 1)
            // Delete oldest backups
            try backupToDeleteUrls.forEach {
                try FileManager.default.removeItem(at: $0)
            }
        }
    }

    static func sortBackupUrlsByAscendingDate(_ backupUrls: [URL]) throws -> [URL] {
        // Extract all backups information files
        let backupUrlsAndDates: [(URL, Date)] = try backupUrls.map { backupUrl in
            let creationDate: Date = try backupUrl.resourceValues(forKeys: [.creationDateKey]).creationDate ?? .distantPast
            return (backupUrl, creationDate)
        }
        // Find and return the oldest backup
        return backupUrlsAndDates
            .sorted { lhs, rhs in
                lhs.1 < rhs.1
            }
            .map(\.0)
    }
}
