//
//  Generator.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 04/03/2023 - 16:25.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

struct Generator: RandomNumberGenerator {
    @inlinable
    mutating func next() -> UInt64 {
        secureRandomInt()
    }

    private func secureRandomInt() -> UInt64 {
        let count: Int = MemoryLayout<UInt64>.size
        var bytes: [Int8] = .init(repeating: 0, count: count)

        let status: OSStatus = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)

        switch status {
        case errSecSuccess:
            return bytes.withUnsafeBytes { $0.load(as: UInt64.self) }
        default:
            return 0
        }
    }
}
