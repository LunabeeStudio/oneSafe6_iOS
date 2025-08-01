//
//  UseCase+SafeItemIcon.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 18/11/2022 - 15:29.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import UIKit
import Model
import CoreCrypto

public extension UseCase {
    static func getSafeItemImageUrl(for iconId: String?) throws -> URL? {
        try safeItemIconRepository.getAllIconsUrls(for: [iconId ?? ""]).first
    }

    static func getSafeItemImageDataFromIconId(_ iconId: String?, key: SafeItemKey) throws -> Data? {
        let coreCrypto: CoreCrypto = .shared

        guard let iconId else { return nil }
        guard let encIconData = try safeItemIconRepository.getEncryptedIconData(id: iconId) else { return nil }

        let key: Data = try coreCrypto.decrypt(value: key.value)

        return try coreCrypto.decrypt(value: encIconData, key: key)
    }

    static func decryptSafeItemImageData(encIconData: Data, key: SafeItemKey) throws -> Data? {
        let coreCrypto: CoreCrypto = .shared
        let key: Data = try coreCrypto.decrypt(value: key.value)
        return try coreCrypto.decrypt(value: encIconData, key: key)
    }

    static func saveSafeItemIcon(image: UIImage, previousIconId: String?, key: SafeItemKey) throws -> String? {
        let coreCrypto: CoreCrypto = .shared

        guard let imageData = image.pngData() else { return nil }

        let key: Data = try coreCrypto.decrypt(value: key.value)
        let encIconData: Data = try coreCrypto.encrypt(value: imageData, key: key)
        return try safeItemIconRepository.saveEncryptedIconData(encIconData, previousIconId: previousIconId)
    }

    static func deleteSafeItemIcon(iconId: String) throws {
        try safeItemIconRepository.deleteIconData(iconId: iconId)
    }
}
