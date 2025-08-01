//
//  RandomKeyProvider.swift
//  CoreCrypto
//
//  Created by Lunabee Studio (François Combe) on 09/09/2024 - 16:09.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import oneSafeKmp

public final class RandomKeyProvider: BubblesRandomKeyProvider {
    /// Only used by KMP, prefers `generateKey` to get `Data`
    public func invoke(size: Int32) -> KotlinByteArray {
        generateKey(size: size).toByteArray()
    }

    public func generateKey(size: Int32) -> Data {
        let size: Int = Int(size)
        var bytes: [Int8] = [Int8](repeating: 0, count: size)
        let status: Int32 = SecRandomCopyBytes(
            kSecRandomDefault,
            size,
            &bytes
        )
        if status == errSecSuccess {
            let data: Data = Data(bytes: bytes, count: size)
            return data
        } else {
            return Data()
        }
    }
}
