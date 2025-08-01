//
//  SafeItemIconRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Francois Beta) on 04/08/2022 - 17:23.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage
import Algorithms

final class SafeItemIconRepositoryImpl: SafeItemIconRepository {
    private let fileManager: IconDirectoryManager = .shared

    func getEncryptedIconData(id: String) throws -> Data? {
        try fileManager.readIconDataFromFile(iconId: id)
    }

    func saveEncryptedIconData(_ encData: Data, previousIconId: String?) throws -> String {
        if let previousIconId = previousIconId {
            try? fileManager.deleteIconFile(iconId: previousIconId)
        }
        let iconId: String = UUID().uuidStringV4
        try fileManager.writeIconDataToFile(encData, iconId: iconId)
        return iconId
    }

    func deleteIconData(iconId: String) throws {
        try fileManager.deleteIconFile(iconId: iconId)
    }

    func getAllIconsUrls() throws -> [URL] {
        try fileManager.allIconsUrls()
    }

    func getAllIconsUrls(for iconsIds: [String]) throws -> [URL] {
        let allUrls: [URL] = try getAllIconsUrls()
        var urlsByIconId: [String: [URL]] = .init(grouping: allUrls) { $0.deletingPathExtension().lastPathComponent }
        let idsToDelete: [String] = [String](Set(urlsByIconId.keys).subtracting(Set(iconsIds)))
        idsToDelete.forEach { urlsByIconId[$0] = nil }
        return urlsByIconId.values.joined { _, _ in [] }
    }

    func deleteAllIcons() throws {
        try fileManager.deleteAllIcons()
    }
}
