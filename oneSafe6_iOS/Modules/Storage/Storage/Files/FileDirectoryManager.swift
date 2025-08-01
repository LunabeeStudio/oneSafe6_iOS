//
//  FileDirectoryManager.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 31/07/2023 - 16:50.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Combine
import Foundation
import Extensions
import Errors
import Model

public final class FileDirectoryManager {
    public static let shared: FileDirectoryManager = .init()

    public let inactivityAutolockOptionObserver: PassthroughSubject<InactivityAutolockOption, Never> = .init()
    public let byChangingAppAutolockOptionObserver: PassthroughSubject<ByChangingAppAutolockOption, Never> = .init()
    public let updatePasswordVerificationOptionObserver: PassthroughSubject<PasswordVerificationOption, Never> = .init()
    public let clearPasteboardOptionObserver: PassthroughSubject<ClearPasteboardOption, Never> = .init()
    public let proximityLockOptionObserver: PassthroughSubject<ProximityLockOption, Never> = .init()

    private init() { }

    public func save(string: String, key: FileKey) throws {
        try string.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: key.rawValue),
            atomically: true,
            encoding: .utf8
        )
    }

    public func save(data: Data, key: FileKey) throws {
        try data.write(to: filesConfigurationDirectoryUrl(create: true).appending(path: key.rawValue), options: .atomic)
    }

    // MARK: - TEMPORARY DEBUG STUFF THAT MUST NOT BE MERGED -
    public func getFilesConfigurationDirectoryContent() throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: filesConfigurationDirectoryUrl(create: false).path())
    }
}

// MARK: Configuration
public extension FileDirectoryManager {
    func inactivityAutolockOption() -> InactivityAutolockOption? {
        guard let savedValue = try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.inactivityAutolockOption.rawValue), encoding: .utf8) else { return nil }
        return InactivityAutolockOption(rawValue: savedValue)
    }

    func byChangingAppAutolockOption() -> ByChangingAppAutolockOption? {
        guard let savedValue = try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.byChangingAppAutolockOption.rawValue), encoding: .utf8) else { return nil }
        return ByChangingAppAutolockOption(rawValue: savedValue)
    }

    func passwordVerificationOption() -> PasswordVerificationOption? {
        guard let savedValue = try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.passwordVerificationInterval.rawValue), encoding: .utf8) else { return nil }
        return PasswordVerificationOption(rawValue: savedValue)
    }

    func lastPasswordVerificationTimestamp() -> Double? {
        guard let savedValue = try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.lastPasswordVerificationTimestamp.rawValue), encoding: .utf8) else {
            let value: Double = Date().timeIntervalSince1970
            try? initLastPasswordVerificationTimestamp(with: value)
            return value
        }

        return Double(savedValue)
    }

    func clearPasteboardOption() -> ClearPasteboardOption? {
        guard let savedValue = try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.clearPasteboardOption.rawValue), encoding: .utf8) else { return nil }
        return ClearPasteboardOption(rawValue: savedValue)
    }

    func proximityLockOption() -> ProximityLockOption? {
        guard let savedValue = try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.proximityLockOption.rawValue), encoding: .utf8) else { return nil }
        return ProximityLockOption(rawValue: savedValue)
    }

    func updateInactivityAutolockOption(_ option: InactivityAutolockOption) throws {
        try option.rawValue.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.inactivityAutolockOption.rawValue),
            atomically: true,
            encoding: .utf8
        )
        inactivityAutolockOptionObserver.send(option)
    }

    func updateByChangingAppAutolockOption(_ option: ByChangingAppAutolockOption) throws {
        try option.rawValue.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.byChangingAppAutolockOption.rawValue),
            atomically: true,
            encoding: .utf8
        )
        byChangingAppAutolockOptionObserver.send(option)
    }

    func updatePasswordVerificationOption(_ option: PasswordVerificationOption) throws {
        try option.rawValue.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.passwordVerificationInterval.rawValue),
            atomically: true,
            encoding: .utf8
        )
        updatePasswordVerificationOptionObserver.send(option)
    }

    func updateClearPasteboardOption(_ option: ClearPasteboardOption) throws {
        try option.rawValue.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.clearPasteboardOption.rawValue),
            atomically: true,
            encoding: .utf8
        )
        clearPasteboardOptionObserver.send(option)
    }

    func updateLastPasswordVerificationTimestamp(_ timestamp: Double) throws {
        try "\(timestamp)".write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.lastPasswordVerificationTimestamp.rawValue),
            atomically: true,
            encoding: .utf8
        )
    }

    func updateProximityLockOption(_ option: ProximityLockOption) throws {
        try option.rawValue.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.proximityLockOption.rawValue),
            atomically: true,
            encoding: .utf8
        )
        proximityLockOptionObserver.send(option)
    }
}

private extension FileDirectoryManager {
    func initLastPasswordVerificationTimestamp(with value: Double) throws {
        try updateLastPasswordVerificationTimestamp(value)
    }
}

// MARK: Salt
public extension FileDirectoryManager {
    func masterSalt() throws -> Data? {
        try? Data(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.masterSalt.rawValue))
    }

    func save(masterSalt: Data) throws {
        try masterSalt.write(to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.masterSalt.rawValue), options: .atomic)
    }

    func deleteMasterSalt() {
        try? FileManager.default.removeItem(at: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.masterSalt.rawValue))
    }

    func searchIndexSalt() throws -> Data? {
        try? Data(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.searchIndexSalt.rawValue))
    }

    func save(searchIndexSalt: Data) throws {
        try searchIndexSalt.write(to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.searchIndexSalt.rawValue), options: .atomic)
    }

    func deleteSearchIndexSalt() {
        try? FileManager.default.removeItem(at: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.searchIndexSalt.rawValue))
    }
}

// MARK: Search text and drafts
public extension FileDirectoryManager {
    func savedSearchText() throws -> String? {
        try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.searchText.rawValue), encoding: .utf8)
    }

    func save(searchText: String) throws {
        try searchText.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.searchText.rawValue),
            atomically: true,
            encoding: .utf8
        )
    }

    func deleteSavedSearchText() throws {
        try? FileManager.default.removeItem(at: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.searchText.rawValue))
    }

    func currentSafeItemDraftData() throws -> Data? {
        try? Data(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.currentSafeItemDraft.rawValue))
    }

    func save(safeItemDraftData: Data) throws {
        try safeItemDraftData.write(to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.currentSafeItemDraft.rawValue), options: .atomic)
    }

    func deleteCurrentSafeItemDraft() throws {
        try? FileManager.default.removeItem(at: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.currentSafeItemDraft.rawValue))
    }

    func bubblesInputMessageDraft() throws -> Data? {
        try? Data(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.bubblesInputMessageDraft.rawValue))
    }

    func save(bubblesInputMessageDraft: Data) throws {
        try bubblesInputMessageDraft.write(to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.bubblesInputMessageDraft.rawValue), options: .atomic)
    }

    func deleteBubblesInputMessageDraft() throws {
        try? FileManager.default.removeItem(at: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.bubblesInputMessageDraft.rawValue))
    }
}

// MARK: - CryptoToken -
public extension FileDirectoryManager {
    func cryptoToken() throws -> Data? {
        try? Data(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: FileKey.cryptoToken.rawValue))
    }

    func save(cryptoToken: Data) throws {
        try cryptoToken.write(to: filesConfigurationDirectoryUrl(create: true).appending(path: FileKey.cryptoToken.rawValue), options: .atomic)
    }
}

// MARK: - Database names -
extension FileDirectoryManager {
    func databaseName() throws -> String? {
        try databaseName(.databaseName)
    }

    func createNewDatabaseName() throws -> String {
        try createNewDatabaseName(.databaseName)
    }

    func deleteDatabaseName() throws {
        try deleteDatabaseName(.databaseName)
    }
    
    func importDatabaseName() throws -> String? {
        try databaseName(.importDatabaseName)
    }

    func createNewImportDatabaseName() throws -> String {
        try createNewDatabaseName(.importDatabaseName)
    }

    func deleteImportDatabaseName() throws {
        try deleteDatabaseName(.importDatabaseName)
    }

    func searchDatabaseName() throws -> String? {
        try databaseName(.searchDatabaseName)
    }

    func createNewSearchDatabaseName() throws -> String {
        try createNewDatabaseName(.searchDatabaseName)
    }

    func deleteSearchDatabaseName() throws {
        try deleteDatabaseName(.searchDatabaseName)
    }

    func bubblesDatabaseName() throws -> String? {
        try databaseName(.bubblesDatabaseName)
    }

    func createNewBubblesDatabaseName() throws -> String {
        try createNewDatabaseName(.bubblesDatabaseName)
    }

    func deleteBubblesDatabaseName() throws {
        try deleteDatabaseName(.bubblesDatabaseName)
    }
}

// MARK: - Database names utils -
extension FileDirectoryManager {
    func databaseName(_ key: FileKey) throws -> String? {
        try? String(contentsOf: filesConfigurationDirectoryUrl(create: false).appending(path: key.rawValue), encoding: .utf8)
    }

    func createNewDatabaseName(_ key: FileKey) throws -> String {
        let newDatabaseName: String = UUID().uuidString.lowercased()
        try newDatabaseName.write(
            to: filesConfigurationDirectoryUrl(create: true).appending(path: key.rawValue),
            atomically: true,
            encoding: .utf8
        )
        return newDatabaseName
    }

    func deleteDatabaseName(_ key: FileKey) throws {
        try? FileManager.default.removeItem(at: filesConfigurationDirectoryUrl(create: false).appending(path: key.rawValue))
    }
}

// MARK: Storage
public extension FileDirectoryManager {
    func writeFileDataToStorage(_ data: Data, fileId: String) throws {
        try data.write(to: filesStorageDirectoryUrl(create: true).appending(component: fileId, directoryHint: .notDirectory), options: .atomic)
    }

    func getAllFilesUrlsInStorage() throws -> [URL] {
        let directoryUrl: URL = try filesStorageDirectoryUrl(create: false)
        guard FileManager.default.fileExists(atPath: directoryUrl.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }

    func getFileUrlInStorage(fileId: String) throws -> URL {
        let url: URL = try filesStorageDirectoryUrl(create: false).appending(component: fileId, directoryHint: .notDirectory)
        return url
    }

    func getFileDataFromStorage(fileId: String) throws -> Data? {
        try Data(contentsOf: filesStorageDirectoryUrl(create: false).appending(component: fileId, directoryHint: .notDirectory), options: .alwaysMapped)
    }

    func deleteFileDataFromStorage(fileId: String) throws {
        try FileManager.default.removeItem(at: filesStorageDirectoryUrl(create: false).appending(component: fileId, directoryHint: .notDirectory))
    }

    func deleteAllFilesFromStorage() {
        try? FileManager.default.removeItem(at: filesStorageDirectoryUrl(create: false))
    }
}

// MARK: Temporary Read/Edit
public extension FileDirectoryManager {
    func temporayReadEditDirectoryUrl(directoryId: String) throws -> URL {
        try fileReadEditTemporaryDirectoryUrl(directoryId: directoryId, create: true)
    }

    func temporayReadEditDirectoryContentFileNames(directoryId: String) throws -> [String] {
        let url: URL = try fileReadEditTemporaryDirectoryUrl(directoryId: directoryId, create: true)
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).map { $0.lastPathComponent }
    }

    func writeFileDataToTemporayReadEditDirectory(fileName: String, directoryId: String, data: Data) throws -> URL {
        let url: URL = try fileReadEditTemporaryDirectoryUrl(directoryId: directoryId, create: true).appending(component: fileName, directoryHint: .notDirectory)
        try data.write(to: url, options: .atomic)
        return url
    }

    func getFileUrlInTemporaryDirectory(fileName: String, directoryId: String) throws -> URL {
        try fileReadEditTemporaryDirectoryUrl(directoryId: directoryId, create: false).appending(component: fileName, directoryHint: .notDirectory)
    }

    func removeAllFilesInReadEditTemporaryDirectory(directoryId: String) async throws {
        let url: URL = try fileReadEditTemporaryDirectoryUrl(directoryId: directoryId, create: false)

        try FileManager.default.removeItem(at: url)
    }

    func clearReadEditTemporaryDirectory() throws {
        let tempUrls: [URL] = try FileManager.default.contentsOfDirectory(at: FileManager.default.temporaryDirectory,
                                                                          includingPropertiesForKeys: nil)
        try tempUrls.forEach {
            try FileManager.default.removeItem(at: $0)
        }
    }

    func clearTemporaryDirectory() {
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory)
    }
}

// MARK: Autolock
public extension FileDirectoryManager {
    func writeFileDataToAutolockDirectory(_ data: Data, fileId: String) throws {
        try data.write(to: fileAutolockDirectoryUrl(create: true).appending(path: fileId, directoryHint: .notDirectory), options: .atomic)
    }

    func getFileDataFromAutolock(fileId: String) throws -> Data? {
        try Data(contentsOf: fileAutolockDirectoryUrl(create: false).appending(component: fileId, directoryHint: .notDirectory), options: .alwaysMapped)
    }

    func clearAutolockDirectory() async throws {
        try FileManager.default.removeItem(at: fileAutolockDirectoryUrl(create: false))
    }
}

// MARK: Import
public extension FileDirectoryManager {
    func allImportFilesUrls() throws -> [URL] {
        let directoryUrl: URL = try filesImportDirectoryUrl(create: false)
        guard FileManager.default.fileExists(atPath: directoryUrl.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }

    func saveImportFiles(for urls: [URL], progress: Progress) async throws {
        let directoryUrl: URL = try filesImportDirectoryUrl(create: true)
        progress.totalUnitCount = Int64(urls.count)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    await MainActor.run(body: {
                        progress.completedUnitCount += 1
                    })
                    try FileManager.default.copyItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func processFilesImport(progress: Progress) async throws {
        let directoryUrl: URL = try filesStorageDirectoryUrl(create: true)
        let urls: [URL] = try allImportFilesUrls()
        progress.totalUnitCount = Int64(urls.count)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    await MainActor.run(body: {
                        progress.completedUnitCount += 1
                    })
                    try FileManager.default.moveItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func deleteAllImportFiles() throws {
        let directoryUrl: URL = try filesImportDirectoryUrl(create: false)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            try FileManager.default.removeItem(at: directoryUrl)
        }
    }
}

// MARK: - Duplicate -
public extension FileDirectoryManager {
    func allDuplicateFilesUrls() throws -> [URL] {
        let directoryUrl: URL = try filesDuplicateDirectoryUrl(create: false)
        guard FileManager.default.fileExists(atPath: directoryUrl.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }

    func saveDuplicateFiles(for urls: [URL]) async throws {
        let directoryUrl: URL = try filesDuplicateDirectoryUrl(create: true)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    try FileManager.default.copyItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func processFilesDuplicate() async throws {
        let directoryUrl: URL = try filesStorageDirectoryUrl(create: true)
        let urls: [URL] = try allDuplicateFilesUrls()

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    try FileManager.default.moveItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func deleteAllDuplicateFiles() throws {
        let directoryUrl: URL = try filesDuplicateDirectoryUrl(create: false)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            try FileManager.default.removeItem(at: directoryUrl)
        }
    }

    func writeEncryptedFileDataToDuplicateDirectory(_ encData: Data, fileId: String) throws -> URL {
        let url: URL = try filesDuplicateDirectoryUrl(create: true).appending(path: fileId, directoryHint: .notDirectory)
        try encData.write(to: url, options: .atomic)
        return url
    }

    func fileReadEditTemporaryDirectoryUrl(directoryId: String, create: Bool) throws -> URL {
        let directoryUrl: URL = FileManager.default.temporaryDirectory.appending(components: "fileReadEditTemp", directoryId, directoryHint: .isDirectory)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryUrl
    }
}

private extension FileDirectoryManager {
    func filesStorageDirectoryUrl(create: Bool) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appending(component: "filesStorage", directoryHint: .isDirectory)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func fileAutolockDirectoryUrl(create: Bool) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appending(component: "filesAutolock", directoryHint: .isDirectory)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func filesImportDirectoryUrl(create: Bool) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appending(component: "filesImport", directoryHint: .isDirectory)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func filesDuplicateDirectoryUrl(create: Bool) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appending(component: "filesDuplicate", directoryHint: .isDirectory)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func filesConfigurationDirectoryUrl(create: Bool) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appending(component: "configuration", directoryHint: .isDirectory)
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}
