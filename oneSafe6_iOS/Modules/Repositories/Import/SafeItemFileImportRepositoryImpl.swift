//
//  SafeItemFileImportRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas Dominati) on 07/09/2023 - 14:16.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage

final class SafeItemFileImportRepositoryImpl: SafeItemFileImportRepository {
    private let fileManager: FileDirectoryManager = .shared

    func allImportFilesUrls() throws -> [URL] {
        try fileManager.allImportFilesUrls()
    }

    func saveImportFiles(for urls: [URL], progress: Progress) async throws {
        try await fileManager.saveImportFiles(for: urls, progress: progress)
    }

    func processFilesImport(progress: Progress) async throws {
        try await fileManager.processFilesImport(progress: progress)
    }

    func deleteAllImportFiles() throws {
        try fileManager.deleteAllImportFiles()
    }
}
