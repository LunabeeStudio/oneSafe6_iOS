//
//  SafeItemFileDuplicateRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas Dominati) on 07/09/2023 - 14:16.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage

final class SafeItemFileDuplicateRepositoryImpl: SafeItemFileDuplicateRepository {
    private let fileManager: FileDirectoryManager = .shared

    func allDuplicateFilesUrls() throws -> [URL] {
        try fileManager.allDuplicateFilesUrls()
    }

    func saveDuplicateFiles(for urls: [URL]) async throws {
        try await fileManager.saveDuplicateFiles(for: urls)
    }

    func processFilesDuplicate() async throws {
        try await fileManager.processFilesDuplicate()
    }

    func deleteAllDuplicateFiles() throws {
        try fileManager.deleteAllDuplicateFiles()
    }

    func writeEncryptedFileDataToDuplicateDirectory(_ encData: Data, fileId: String) throws -> URL {
        try fileManager.writeEncryptedFileDataToDuplicateDirectory(encData, fileId: fileId)
    }
}
