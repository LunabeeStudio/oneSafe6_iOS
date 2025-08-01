//
//  PasswordStrength.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 24/01/2023 - 15:07.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct PasswordStrength: Codable {
    /// Bits
    public let entropy: String
    /// Estimation of actual crack time, in seconds.
    public let crackTime: String
    /// Same crack time, as a friendlier string: "instant", "6 minutes", "centuries", etc.
    public let crackTimeDisplay: String
    /// [0,1,2,3,4] if crack time is less than [10**2, 10**4, 10**6, 10**8, Infinity]. (useful for implementing a strength bar.)
    public let score: Int
    /// The list of patterns that zxcvbn based the entropy calculation on.
    public let matchSequence: [PasswordMatch]
    /// How long it took to calculate an answer, in milliseconds. Usually only a few ms.
    public let calcTime: Double

    public init(entropy: String, crackTime: String, crackTimeDisplay: String, score: Int, matchSequence: [PasswordMatch], calcTime: Double) {
        self.entropy = entropy
        self.crackTime = crackTime
        self.crackTimeDisplay = crackTimeDisplay
        self.score = score
        self.matchSequence = matchSequence
        self.calcTime = calcTime
    }
}

public extension PasswordStrength {
    enum Level {
        case veryWeak
        case weak
        case good
        case strong
        case veryStrong
        case bulletProof
    }

    var level: Level {
        let entropy: Double = Double(entropy) ?? 0

        switch entropy {
        case ..<25:
            return .veryWeak
        case 25..<50:
            return .weak
        case 50..<75:
            return .good
        case 75..<85:
            return .strong
        case 85..<100:
            return .veryStrong
        default:
            return .bulletProof
        }
    }
}
