//
//  SafeItemIconDuplicateRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Jérémie Carrez) on 27/06/2023 - 14:28.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage

final class SafeItemIconDuplicateRepositoryImpl: SafeItemIconDuplicateRepository {

    private let fileManager: IconDirectoryManager = .shared

    func allDuplicateIconsUrls() throws -> [URL] {
        try fileManager.allDuplicateIconsUrls()
    }

    func saveDuplicateIcons(for urls: [URL]) async throws {
        try await fileManager.saveDuplicateIcons(for: urls)
    }

    func processIconsDuplicate() async throws {
        try await fileManager.processIconsDuplicate()
    }

    func deleteAllDuplicateIcons() throws {
        try fileManager.deleteAllDuplicateIcons()
    }

    func saveIconData(_ encData: Data, iconId: String) throws {
        try fileManager.writeDuplicateIconDataToFile(encData, iconId: iconId)
    }
}
