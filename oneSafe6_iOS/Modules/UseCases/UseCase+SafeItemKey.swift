//
//  UseCase+SafeItemKey.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 18/11/2022 - 15:00.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Model
import CoreCrypto
import Extensions

public extension UseCase {
    static func createSafeItemKey(itemId: String = UUID().uuidStringV4) throws -> SafeItemKey {
        let coreCrypto: CoreCrypto = .shared

        let key: Data = coreCrypto.generateKey()
        let encKey: Data = try coreCrypto.encrypt(value: key)
        return .init(id: itemId, value: encKey)
    }

    static func getSafeItemKey(itemId: String) throws -> SafeItemKey? {
        try safeItemRepository.getKey(for: itemId)
    }

    static func saveSafeItemKey(key: SafeItemKey) throws {
        try safeItemRepository.save(key: key)
    }

    static func saveSafeItemKeys(keys: [SafeItemKey]) throws {
        try safeItemRepository.save(keys: keys)
    }
}
