//
//  BubblesMainCryptoRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 24/07/2024 - 17:11.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp
import CoreCrypto

final class BubblesMainCryptoRepositoryImpl: BubblesMainCryptoRepository {
    func __decryptBubbles(data: KotlinByteArray) async throws -> KotlinByteArray {
        try CoreCrypto.shared.decrypt(value: data.toNSData(), scope: .bubbles).toByteArray()
    }

    func __encryptBubbles(data: KotlinByteArray) async throws -> KotlinByteArray {
        try CoreCrypto.shared.encrypt(value: data.toNSData(), scope: .bubbles).toByteArray()
    }
}
