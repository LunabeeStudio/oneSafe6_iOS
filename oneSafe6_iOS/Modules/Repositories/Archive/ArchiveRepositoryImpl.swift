//
//  ArchiveRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Nicolas) on 06/12/2022 - 12:29.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import UIKit
import Model
import Extensions
import ZIPFoundation
import SwiftProtobuf
import Protocols
import Combine
import Errors
import Storage

extension ArchiveKind {
    var fileExtension: String {
        switch self {
        case .backup:
            return Constant.Archive.FileExtension.backup
        case .sharing:
            return Constant.Archive.FileExtension.sharing
        }
    }
}

final class ArchiveRepositoryImpl: ArchiveRepository {
    var archiveExtensions: [String] { Constant.Archive.FileExtension.all }
    var lastAutoBackupDate: Date? { UserDefaultsManager.shared.lastAutoBackupDate }
    var supportedVersion: Int { Constant.Archive.version }
}

extension ArchiveRepositoryImpl {
    func writeExportArchiveMetadata(archiveKind: ArchiveKind, itemsCount: Int, contactsCount: Int, cryptoToken: Data?) throws {
        let archiveMetadata: ArchiveMetadata = .with { metadata in
            metadata.archiveKind = archiveKind.toArchive()
            metadata.isFromOneSafePlus = false
            metadata.archiveVersion = Int32(Constant.Archive.version)
            metadata.fromPlatform = Constant.Archive.Platform.ios
            metadata.createdAt = Date().formatted(.iso8601)
            metadata.itemsCount = Int32(itemsCount)
            metadata.bubblesContactsCount = Int32(contactsCount)
            cryptoToken.map { metadata.cryptoToken = $0 }
        }
        let archiveMetadataData: Data = try archiveMetadata.serializedData()
        try archiveMetadataData.write(to: archiveMetadataFileUrl(), options: .atomic)
    }

    func writeExportArchiveData(exportData: ExportData, toSalt: Data, progress: Progress) async throws {
        let elementsCount: Int = exportData.items.count + exportData.fields.count + exportData.keys.count + exportData.bubblesContacts.count + exportData.bubblesContactsKeys.count + exportData.bubblesMessages.count
        let serializationPart: Int = Int(Double(elementsCount) * 0.1)
        let dataWritingPart: Int = Int(Double(elementsCount) * 0.1)
        let totalSteps: Int = elementsCount + serializationPart + dataWritingPart
        let worker: ProgressWorker = .init(progress: progress)
        worker.progress.totalUnitCount = Int64(totalSteps)

        async let itemsToArchive: [ArchiveSafeItem] = try await withThrowingTaskGroup(of: ArchiveSafeItem.self) { taskGroup in
            for item in exportData.items {
                taskGroup.addTask {
                    await worker.increment(1)
                    return item.toArchive()
                }
            }
            return try await taskGroup.collect()
        }
        async let fieldsToArchive: [ArchiveSafeItemField] = try await withThrowingTaskGroup(of: ArchiveSafeItemField.self) { taskGroup in
            for field in exportData.fields {
                taskGroup.addTask {
                    await worker.increment(1)
                    return field.toArchive()
                }
            }
            return try await taskGroup.collect()
        }
        async let keysToArchive: [ArchiveSafeItemKey] = try await withThrowingTaskGroup(of: ArchiveSafeItemKey.self) { taskGroup in
            for key in exportData.keys {
                taskGroup.addTask {
                    await worker.increment(1)
                    return key.toArchive()
                }
            }
            return try await taskGroup.collect()
        }
        async let contactsToArchive: [ArchiveBubblesContact] = try await withThrowingTaskGroup(of: ArchiveBubblesContact.self) { taskGroup in
            for contact in exportData.bubblesContacts {
                taskGroup.addTask {
                    await worker.increment(1)
                    return contact.toArchive()
                }
            }
            return try await taskGroup.collect()
        }
        async let contactKeysToArchive: [ArchiveBubblesContactKey] = try await withThrowingTaskGroup(of: ArchiveBubblesContactKey.self) { taskGroup in
            for key in exportData.bubblesContactsKeys {
                taskGroup.addTask {
                    await worker.increment(1)
                    return key.toArchive()
                }
            }
            return try await taskGroup.collect()
        }
        async let messagesToArchive: [ArchiveBubblesMessage] = try await withThrowingTaskGroup(of: ArchiveBubblesMessage.self) { taskGroup in
            for message in exportData.bubblesMessages {
                taskGroup.addTask {
                    await worker.increment(1)
                    return message.toArchive()
                }
            }
            return try await taskGroup.collect()
        }
        async let conversationsToArchive: [ArchiveBubblesConversation] = try await withThrowingTaskGroup(of: ArchiveBubblesConversation.self) { taskGroup in
            for conversation in exportData.bubblesConversations {
                taskGroup.addTask {
                    await worker.increment(1)
                    return conversation.toArchive()
                }
            }
            return try await taskGroup.collect()
        }

        let (items, fields, keys, contacts, contactsKeys, messages, conversations): (
            [ArchiveSafeItem],
            [ArchiveSafeItemField],
            [ArchiveSafeItemKey],
            [ArchiveBubblesContact],
            [ArchiveBubblesContactKey],
            [ArchiveBubblesMessage],
            [ArchiveBubblesConversation]
        ) = try await (
            itemsToArchive,
            fieldsToArchive,
            keysToArchive,
            contactsToArchive,
            contactKeysToArchive,
            messagesToArchive,
            conversationsToArchive
        )
        let archive: Archive = .with {
            $0.salt = toSalt
            $0.items = items
            $0.fields = fields
            $0.keys = keys
            $0.contacts = contacts
            $0.contactKeys = contactsKeys
            $0.messages = messages
            $0.conversations = conversations
            $0.encBubblesMasterKey = exportData.bubblesMasterKey ?? Data()
        }
        let archiveData: Data = try archive.serializedData()
        await worker.increment(serializationPart)
        try archiveData.write(to: archiveDataFileUrl(), options: .atomic)
        await worker.increment(dataWritingPart)
    }

    func copyIconsToIconsExport(iconsUrls: [URL], progress: Progress) async throws {
        let worker: ProgressWorker = .init(progress: progress)
        worker.progress.totalUnitCount = Int64(iconsUrls.count)
        try archiveIconsDirectoryUrl() // create the icons directory
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for iconUrl in iconsUrls {
                taskGroup.addTask {
                    await worker.increment(1)
                    try FileManager.default.copyItem(at: iconUrl, to: self.archiveIconsDirectoryUrl().appending(path: iconUrl.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll()
        }
    }

    func copyFilesToFilesExport(filesUrls: [URL], progress: Progress) async throws {
        let worker: ProgressWorker = .init(progress: progress)
        try archiveFilesDirectoryUrl() // create the files directory
        worker.progress.totalUnitCount = Int64(filesUrls.count)
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for fileUrl in filesUrls {
                taskGroup.addTask {
                    await worker.increment(1)
                    try FileManager.default.copyItem(at: fileUrl, to: self.archiveFilesDirectoryUrl().appending(path: fileUrl.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll()
        }
    }

    func zipArchive(archiveKind: ArchiveKind, progress: Progress) throws -> URL {
        let destinationUrl: URL = try backupDestinationFileUrl(archiveKind: archiveKind)
        try FileManager.default.zipItem(at: archiveContentDirectoryUrl(),
                                        to: destinationUrl,
                                        shouldKeepParent: false,
                                        compressionMethod: .deflate,
                                        progress: progress)
        return destinationUrl
    }

    func getUrlsToAuthorizeFileSystemIcloudBackup(_ isAuthorized: Bool) throws {
        let urlsToExclude: [URL] = try [FileManager.applicationGroupContainer(), FileManager.documentsDirectory(), FileManager.libraryDirectory()]
        try urlsToExclude.forEach { url in
            try recursivelyAuthorizeFileSystemIcloudBackup(directoryUrl: url, isAuthorized: isAuthorized)
        }
    }

    private func recursivelyAuthorizeFileSystemIcloudBackup(directoryUrl: URL, isAuthorized: Bool) throws {
        let directoryContent: [URL] = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
        try directoryContent.forEach { url in
            var mutableURL: URL = url
            try mutableURL.excludeFromBackup(!isAuthorized)
            if mutableURL.isDirectory {
                try recursivelyAuthorizeFileSystemIcloudBackup(directoryUrl: mutableURL, isAuthorized: isAuthorized)
            }
        }
    }
}

extension ArchiveRepositoryImpl {
    func copyArchiveToImportToInbox(archiveUrl: URL) throws -> URL {
        let inboxArchiveUrl: URL = try archiveInboxDirectoryUrl().appending(path: archiveUrl.lastPathComponent)
        _ = archiveUrl.startAccessingSecurityScopedResource()
        try FileManager.default.copyItem(at: archiveUrl, to: inboxArchiveUrl)
        archiveUrl.stopAccessingSecurityScopedResource()
        return inboxArchiveUrl
    }

    func unzipArchive(inboxArchiveUrl: URL, progress: Progress?) throws -> URL {
        let extractDirectoryUrl: URL = try unarchiveDirectoryUrl().appending(path: inboxArchiveUrl.lastPathComponent)
        try FileManager.default.unzipItem(at: inboxArchiveUrl, to: extractDirectoryUrl, progress: progress)
        return extractDirectoryUrl
    }

    func getImportArchiveInfo(archiveExtractionUrl: URL) throws -> ArchiveInfo {
        let archiveMetadataData: Data = try Data(contentsOf: archiveMetadataFileUrl(from: archiveExtractionUrl))
        let archiveMetadata: ArchiveMetadata = try .init(serializedData: archiveMetadataData)
        return try archiveMetadata.toAppModel(archiveDirectoryUrl: archiveExtractionUrl)
    }

    func getImportArchiveContent(archiveExtractionUrl: URL, safeId: String, progress: Progress) async throws -> ArchiveImportContent {
        let archiveData: Data = try Data(contentsOf: archiveDataFileUrl(from: archiveExtractionUrl))
        let archive: Archive = try .init(serializedData: archiveData)

        let totalSteps: Int = archive.items.count + archive.fields.count + archive.keys.count + archive.contacts.count + archive.contactKeys.count + archive.messages.count + archive.conversations.count
        let worker: ProgressWorker = .init(progress: progress)
        worker.progress.totalUnitCount = Int64(totalSteps)

        async let items: [SafeItemImport] = try await withThrowingTaskGroup(of: SafeItemImport.self) { taskGroup in
            for item in archive.items {
                taskGroup.addTask {
                    await worker.increment(1)
                    return item.toImportAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let fields: [SafeItemFieldImport] = try await withThrowingTaskGroup(of: SafeItemFieldImport.self) { taskGroup in
            for field in archive.fields {
                taskGroup.addTask {
                    await worker.increment(1)
                    return field.toImportAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let keys: [SafeItemKeyImport] = try await withThrowingTaskGroup(of: SafeItemKeyImport?.self) { taskGroup in
            for key in archive.keys {
                taskGroup.addTask {
                    await worker.increment(1)
                    return key.toImportAppModel()
                }
            }
            return try await taskGroup.collect().compactMap { $0 }
        }

        async let contacts: [ContactImport] = try await withThrowingTaskGroup(of: ContactImport.self) { taskGroup in
            for contact in archive.contacts {
                taskGroup.addTask {
                    await worker.increment(1)
                    return contact.toImportAppModel(safeId: safeId)
                }
            }
            return try await taskGroup.collect()
        }
        async let contactKeys: [ContactLocalKeyImport] = try await withThrowingTaskGroup(of: ContactLocalKeyImport.self) { taskGroup in
            for key in archive.contactKeys {
                taskGroup.addTask {
                    await worker.increment(1)
                    return key.toImportModel()
                }
            }
            return try await taskGroup.collect()
        }
        async let messages: [SafeMessageImport] = try await withThrowingTaskGroup(of: SafeMessageImport.self) { taskGroup in
            for message in archive.messages {
                taskGroup.addTask {
                    await worker.increment(1)
                    return message.toImportModel()
                }
            }
            return try await taskGroup.collect()
        }
        async let conversations: [EncConversationImport] = try await withThrowingTaskGroup(of: EncConversationImport.self) { taskGroup in
            for conversation in archive.conversations {
                taskGroup.addTask {
                    await worker.increment(1)
                    return conversation.toImportModel()
                }
            }
            return try await taskGroup.collect()
        }

        return try await .init(
            items: items,
            fields: fields,
            keys: keys,
            contacts: contacts,
            contactsKeys: contactKeys,
            messages: messages,
            conversations: conversations,
            encBubblesMasterKey: archive.encBubblesMasterKey.isEmpty ? nil : archive.encBubblesMasterKey,
            salt: archive.salt
        )
    }

    func getImportArchiveIconsUrls(archiveExtractionUrl: URL) throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: archiveIconsDirectoryUrl(from: archiveExtractionUrl), includingPropertiesForKeys: nil)
    }

    func getImportArchiveFilesUrls(archiveExtractionUrl: URL) throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: archiveFilesDirectoryUrl(from: archiveExtractionUrl), includingPropertiesForKeys: nil)
    }
}

extension ArchiveRepositoryImpl {
    func lastManualBackupDate() -> CurrentValueSubject<Date, Never> {
        UserDefaultsManager.shared.$lastManualBackupDate
    }

    func setLastManualBackupDate(_ value: Date) {
        UserDefaultsManager.shared.lastManualBackupDate = value
    }
}

// MARK: - Auto backup -
extension ArchiveRepositoryImpl {
    func observeLastAutoBackupDate() -> CurrentValueSubject<Date?, Never> {
        UserDefaultsManager.shared.$lastAutoBackupDate
    }

    func updateLastAutoBackupDate(_ date: Date) {
        UserDefaultsManager.shared.lastAutoBackupDate = date
    }

    func getAllLocalAutoBackupUrls() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: autoBackupDirectoryUrl(create: false), includingPropertiesForKeys: nil)
    }

    func getAllICloudAutoBackupUrls() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: autoBackupICloudDriveDirectoryUrl(create: false), includingPropertiesForKeys: nil)
    }

    func copyAutoBackupToICloudDrive(backupUrl: URL) throws {
        guard let _ = FileManager.default.url(forUbiquityContainerIdentifier: Constant.ICloud.ubiquityContainter) else {
            throw AppError.storageICloudDocumentsDirectoryNotAvailable
        }
        let fileUrl: URL = try autoBackupICloudDriveDirectoryUrl(create: true)
            .appendingPathComponent(backupUrl.lastPathComponent)
        try FileManager.default.copyItem(at: backupUrl, to: fileUrl)
    }

    func moveAutoBackupToLocalDirectory(backupUrl: URL) throws {
        try FileManager.default.moveItem(at: backupUrl, to: autoBackupDirectoryUrl(create: true).appendingPathComponent(backupUrl.lastPathComponent))
    }

    func getAutoBackupDirectoryUrl() throws -> URL {
        try autoBackupDirectoryUrl(create: false)
    }

    func getAutoBackupICloudDriveDirectoryUrl() throws -> URL {
        try autoBackupICloudDriveDirectoryUrl(create: false)
    }
}

// MARK: - Clearing -
extension ArchiveRepositoryImpl {
    func clearExportArchiveFiles() throws {
        let url: URL = try rootDirectoryUrl(create: false, clear: false, name: Constant.Archive.DirectoryName.archive)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    func clearImportArchiveFiles() throws {
        let inboxUrl: URL = try rootDirectoryUrl(create: false, clear: false, name: Constant.Archive.DirectoryName.archiveInbox)
        let unarchiveUrl: URL = try rootDirectoryUrl(create: false, clear: false, name: Constant.Archive.DirectoryName.unarchive)
        if FileManager.default.fileExists(atPath: inboxUrl.path) {
            try FileManager.default.removeItem(at: inboxUrl)
        }
        if FileManager.default.fileExists(atPath: unarchiveUrl.path) {
            try FileManager.default.removeItem(at: unarchiveUrl)
        }
    }
}

// MARK: - Directories methods -
private extension ArchiveRepositoryImpl {
    func archiveDirectoryUrl() throws -> URL {
        try rootDirectoryUrl(create: true, name: Constant.Archive.DirectoryName.archive)
    }

    func archiveContentDirectoryUrl() throws -> URL {
        try archiveDirectoryUrl().appendingDirectory(path: Constant.Archive.DirectoryName.archiveContent)
    }

    @discardableResult
    func archiveIconsDirectoryUrl() throws -> URL {
        try archiveContentDirectoryUrl().appendingDirectory(path: Constant.Archive.DirectoryName.archiveIcons)
    }

    func archiveIconsDirectoryUrl(from directoryUrl: URL) throws -> URL {
        try directoryUrl.appendingDirectory(path: Constant.Archive.DirectoryName.archiveIcons)
    }

    @discardableResult
    func archiveFilesDirectoryUrl() throws -> URL {
        try archiveContentDirectoryUrl().appendingDirectory(path: Constant.Archive.DirectoryName.archiveFiles)
    }

    func archiveFilesDirectoryUrl(from directoryUrl: URL) throws -> URL {
        try directoryUrl.appendingDirectory(path: Constant.Archive.DirectoryName.archiveFiles)
    }

    func archiveInboxDirectoryUrl() throws -> URL {
        try rootDirectoryUrl(create: true, name: Constant.Archive.DirectoryName.archiveInbox)
    }

    func unarchiveDirectoryUrl() throws -> URL {
        try rootDirectoryUrl(create: true, name: Constant.Archive.DirectoryName.unarchive)
    }

    func autoBackupDirectoryUrl(create: Bool) throws -> URL {
        let directoryUrl: URL = FileManager.documentsDirectory().appending(path: Constant.Archive.DirectoryName.autoBackup)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func autoBackupICloudDriveDirectoryUrl(create: Bool) throws -> URL {
        guard let iCloudDriveUrl = FileManager.default.url(forUbiquityContainerIdentifier: Constant.ICloud.ubiquityContainter) else {
            throw AppError.storageICloudDocumentsDirectoryNotAvailable
        }
        let directoryUrl: URL = iCloudDriveUrl
            .appending(path: "Documents")
            .appending(path: Constant.Archive.DirectoryName.autoBackup)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}

// MARK: - Files methods -
private extension ArchiveRepositoryImpl {
    func archiveDataFileUrl() throws -> URL {
        try archiveContentDirectoryUrl().appending(path: Constant.Archive.FileName.archiveData)
    }

    func archiveMetadataFileUrl() throws -> URL {
        try archiveContentDirectoryUrl().appending(path: Constant.Archive.FileName.archiveMetadata)
    }

    func backupDestinationFileUrl(archiveKind: ArchiveKind) throws -> URL {
        try archiveDirectoryUrl().appending(path: backupFileName(fileExtension: archiveKind.fileExtension))
    }

    func archiveMetadataFileUrl(from directoryUrl: URL) throws -> URL {
        directoryUrl.appending(path: Constant.Archive.FileName.archiveMetadata)
    }

    func archiveDataFileUrl(from directoryUrl: URL) throws -> URL {
        directoryUrl.appending(path: Constant.Archive.FileName.archiveData)
    }
}

// MARK: - Utils -
private extension ArchiveRepositoryImpl {
    func backupFileName(fileExtension: String) -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyyMMdd'-'HH'h'mm'm'ss"
        return "oneSafe-\(dateFormatter.string(from: .now))." + fileExtension
    }

    func rootDirectoryUrl(create: Bool = true, clear: Bool = false, name: String) throws -> URL {
        let directoryUrl: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        if clear {
            try? FileManager.default.removeItem(at: directoryUrl)
        }
        if (create || clear) && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}

private extension URL {
    func createDirectory(path: String) throws {
        let directoryUrl: URL = appending(path: path)
        if !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
    }

    /// - Warning: If used in a TasKGroup it can lead to errors when trying to create the same directory simultaneously. Make sure the directory is already created before calling this several times in a TaskGroup.
    func appendingDirectory(path: String) throws -> URL {
        let directoryUrl: URL = appending(path: path)
        if !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}

// MARK: - Private model extensions -
private extension ArchiveMetadata {
    func toAppModel(archiveDirectoryUrl: URL) throws -> ArchiveInfo {
        try .init(archiveKind: archiveKind.toAppModel(),
                  isFromOneSafePlus: isFromOneSafePlus,
                  archiveVersion: Int(archiveVersion),
                  fromPlatform: fromPlatform,
                  createdAt: Date(iso8601: createdAt) ?? .now,
                  itemsCount: Int(itemsCount),
                  archiveDirectoryUrl: archiveDirectoryUrl,
                  cryptoToken: cryptoToken.isEmpty ? nil : cryptoToken)
    }
}

private extension ArchiveMetadata.ArchiveKind {
    func toAppModel() throws -> ArchiveKind {
        switch self {
        case .backup:
            return .backup
        case .sharing:
            return .sharing
        case .UNRECOGNIZED(_), .unspecified:
            throw AppError.archiveWrongArchiveKind
        }
    }
}

private extension ArchiveKind {
    func toArchive() -> ArchiveMetadata.ArchiveKind {
        switch self {
        case .backup:
            return .backup
        case .sharing:
            return .sharing
        }
    }
}

private extension SafeItem {
    func toArchive() -> ArchiveSafeItem {
        .with {
            $0.id = id
            $0.encName = encName ?? Data()
            $0.encColor = encColor ?? Data()
            $0.iconID = iconId ?? ""
            $0.parentID = parentId ?? ""
            $0.deletedParentID = deletedParentId ?? ""
            $0.isFavorite = isFavorite
            $0.createdAt = createdAt.formatted(.iso8601)
            $0.updatedAt = updatedAt.formatted(.iso8601)
            $0.deletedAt = deletedAt?.formatted(.iso8601) ?? ""
            $0.position = position
        }
    }
}

private extension SafeItemField {
    func toArchive() -> ArchiveSafeItemField {
        .with {
            $0.id = id
            $0.encName = encName ?? Data()
            $0.position = position
            $0.itemID = itemId
            $0.encPlaceholder = encPlaceholder ?? Data()
            $0.encValue = encValue ?? Data()
            $0.encKind = encKind ?? Data()
            $0.createdAt = createdAt.formatted(.iso8601)
            $0.updatedAt = updatedAt.formatted(.iso8601)
            $0.isItemIdentifier = isItemIdentifier
            $0.formattingMask = encFormattingMask ?? Data()
            $0.secureDisplayMask = encSecureDisplayMask ?? Data()
            $0.isSecured = isSecured
        }
    }
}

private extension SafeItemKey {
    func toArchive() -> ArchiveSafeItemKey {
        .with {
            $0.id = id
            $0.value = value
        }
    }
}

// MARK: Bubbles models conversion to Archive model
private extension Contact {
    func toArchive() -> ArchiveBubblesContact {
        .with {
            $0.id = id
            $0.encName = encName
            $0.encSharedKey = encSharedKey?.encKey ?? Data()
            $0.updatedAt = updatedAt.formatted(.iso8601)
            $0.sharedConversationID = sharedConversationId
            $0.encSharingMode = encSharingMode
            $0.consultedAt = consultedAt?.formatted(.iso8601) ?? ""
            $0.encResetConversationDate = encResetConversationDate ?? Data()
        }
    }
}

private extension ContactLocalKey {
    func toArchive() -> ArchiveBubblesContactKey {
        .with {
            $0.contactID = contactId
            $0.encLocalKey = encKey
        }
    }
}

private extension SafeMessage {
    func toArchive() -> ArchiveBubblesMessage {
        .with {
            $0.id = id
            $0.fromContactID = fromContactId
            $0.encContent = encContent
            $0.encSentAt = encSentAt
            switch direction {
            case .received:
                $0.direction = .received
            case .sent:
                $0.direction = .sent
            }
            $0.encChannel = encChannel ?? Data()
            $0.isRead = isRead
            $0.encSafeItemID = encSafeItemId ?? Data()
            $0.order = order
        }
    }
}

private extension EncConversation {
    func toArchive() -> ArchiveBubblesConversation {
        .with {
            $0.id = id
            $0.encPersonalPublicKey = encPersonalPublicKey
            $0.encPersonalPrivateKey = encPersonalPrivateKey
            $0.encMessageNumber = encMessageNumber
            $0.encSequenceNumber = encSequenceNumber
            $0.encRootKey = encRootKey ?? Data()
            $0.encSendingChainKey = encSendingChainKey ?? Data()
            $0.encReceiveChainKey = encReceiveChainKey ?? Data()
            $0.encLastContactPublicKey = encLastContactPublicKey ?? Data()
            $0.encReceivedLastMessageNumber = encReceivedLastMessageNumber ?? Data()
        }
    }
}

private extension ArchiveSafeItem {
    func toImportAppModel() -> SafeItemImport {
        .init(id: id,
              encName: encName.isEmpty ? nil : encName,
              encColor: encColor.isEmpty ? nil : encColor,
              iconId: iconID.isEmpty ? nil : iconID,
              parentId: parentID.isEmpty ? nil : parentID,
              deletedParentId: deletedParentID.isEmpty ? nil : deletedParentID,
              isFavorite: isFavorite,
              createdAt: Date(iso8601: createdAt) ?? Date(iso8601: updatedAt) ?? .now,
              updatedAt: Date(iso8601: updatedAt) ?? .now,
              deletedAt: deletedAt.isEmpty ? nil : Date(iso8601: deletedAt),
              position: position)
    }
}

private extension ArchiveSafeItemField {
    func toImportAppModel() -> SafeItemFieldImport {
        .init(id: id,
              encName: encName.isEmpty ? nil : encName,
              position: position,
              itemId: itemID,
              encPlaceholder: encPlaceholder.isEmpty ? nil : encPlaceholder,
              encValue: encValue.isEmpty ? nil : encValue,
              showPrediction: showPrediction,
              encKind: encKind.isEmpty ? nil : encKind,
              createdAt: Date(iso8601: createdAt) ?? .now,
              updatedAt: Date(iso8601: updatedAt) ?? .now,
              isItemIdentifier: isItemIdentifier,
              encFormattingMask: formattingMask.isEmpty ? nil : formattingMask,
              encSecureDisplayMask: secureDisplayMask.isEmpty ? nil : secureDisplayMask,
              isSecured: isSecured)
    }
}

private extension ArchiveSafeItemKey {
    func toImportAppModel() -> SafeItemKeyImport {
        .init(id: id, value: value)
    }
}

private extension ArchiveBubblesContact {
    func toImportAppModel(safeId: String) -> ContactImport {
        .init(
            id: id,
            encName: encName,
            encSharedKey: encSharedKey.isEmpty ? nil : ContactSharedKeyImport(encKey: encSharedKey),
            updatedAt: Date(iso8601: updatedAt) ?? .now,
            encSharingMode: encSharingMode,
            sharedConversationId: sharedConversationID,
            consultedAt: Date(iso8601: consultedAt),
            safeId: safeId,
            encResetConversationDate: encResetConversationDate.isEmpty ? nil : encResetConversationDate
        )
    }
}

private extension ArchiveBubblesContactKey {
    func toImportModel() -> ContactLocalKeyImport {
        .init(
            contactId: contactID,
            encKey: encLocalKey
        )
    }
}

private extension ArchiveBubblesMessage {
    func toImportModel() -> SafeMessageImport {
        .init(
            id: id,
            fromContactId: fromContactID,
            encSentAt: encSentAt,
            encContent: encContent,
            direction: direction == .sent ? .sent : .received,
            encChannel: encChannel.isEmpty ? nil : encChannel,
            isRead: isRead,
            order: order,
            encSafeItemId: encSafeItemID.isEmpty ? nil : encSafeItemID
        )
    }
}

private extension ArchiveBubblesConversation {
    func toImportModel() -> EncConversationImport {
        .init(
            id: id,
            encPersonalPublicKey: encPersonalPublicKey,
            encPersonalPrivateKey: encPersonalPrivateKey,
            encMessageNumber: encMessageNumber,
            encSequenceNumber: encSequenceNumber,
            encRootKey: encRootKey.isEmpty ? nil : encRootKey,
            encSendingChainKey: encSendingChainKey.isEmpty ? nil : encSendingChainKey,
            encReceiveChainKey: encReceiveChainKey.isEmpty ? nil : encReceiveChainKey,
            encLastContactPublicKey: encLastContactPublicKey.isEmpty ? nil : encLastContactPublicKey,
            encReceivedLastMessageNumber: encReceivedLastMessageNumber.isEmpty ? nil : encReceivedLastMessageNumber
        )
    }
}
