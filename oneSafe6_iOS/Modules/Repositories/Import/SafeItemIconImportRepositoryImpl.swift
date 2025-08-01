//
//  SafeItemIconImportRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Francois Beta) on 04/08/2022 - 17:23.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage

final class SafeItemIconImportRepositoryImpl: SafeItemIconImportRepository {
    private let fileManager: IconDirectoryManager = .shared

    func allImportIconsUrls() throws -> [URL] {
        try fileManager.allImportIconsUrls()
    }

    func saveImportIcons(for urls: [URL], progress: Progress) async throws {
        try await fileManager.saveImportIcons(for: urls, progress: progress)
    }

    func processIconsImport(progress: Progress) async throws {
        try await fileManager.processIconsImport(progress: progress)
    }

    func deleteAllImportIcons() throws {
        try fileManager.deleteAllImportIcons()
    }

    func saveIconData(_ encData: Data, iconId: String) throws {
        try fileManager.writeImportIconDataToFile(encData, iconId: iconId)
    }
}
