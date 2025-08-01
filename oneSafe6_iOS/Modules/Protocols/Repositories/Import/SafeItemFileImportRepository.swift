//
//  SafeItemFileImportRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Nicolas Dominati) on 07/09/2023 - 12:00.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public protocol SafeItemFileImportRepository {
    func allImportFilesUrls() throws -> [URL]
    func saveImportFiles(for urls: [URL], progress: Progress) async throws
    func processFilesImport(progress: Progress) async throws
    func deleteAllImportFiles() throws
}
