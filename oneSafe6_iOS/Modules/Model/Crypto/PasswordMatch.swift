//
//  PasswordMatch.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 24/01/2023 - 15:19.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct PasswordMatch: Codable {
    public let pattern: String?
    public let token: String?
    public let startIndex: UInt?
    public let endIndex: UInt?
    public let entropy: Double?
    public let cardinality: Int?

    public let dictionary: Dictionary?
    public let l33t: L33t?
    public let spatial: Spatial?
    public let `repeat`: Repeat?
    public let sequence: Sequence?
    public let date: Date?

    public init(pattern: String?, token: String?, startIndex: UInt?, endIndex: UInt?, entropy: Double?, cardinality: Int?, dictionary: Dictionary?, l33t: L33t?, spatial: Spatial?, repeat: Repeat?, sequence: Sequence?, date: Date?) {
        self.pattern = pattern
        self.token = token
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.entropy = entropy
        self.cardinality = cardinality
        self.dictionary = dictionary
        self.l33t = l33t
        self.spatial = spatial
        self.repeat = `repeat`
        self.sequence = sequence
        self.date = date
    }

    public struct Dictionary: Codable {
        public let matchedWord: String?
        public let dictionaryName: String?
        public let rank: Int?
        public let baseEntropy: Double?
        public let upperCaseEntropy: Double?

        public init(matchedWord: String?, dictionaryName: String?, rank: Int?, baseEntropy: Double?, upperCaseEntropy: Double?) {
            self.matchedWord = matchedWord
            self.dictionaryName = dictionaryName
            self.rank = rank
            self.baseEntropy = baseEntropy
            self.upperCaseEntropy = upperCaseEntropy
        }
    }

    public struct L33t: Codable {
        public let sub: [String: String]?
        public let subDisplay: String?
        public let l33tEntropy: Int?

        public init(sub: [String: String]?, subDisplay: String?, l33tEntropy: Int?) {
            self.sub = sub
            self.subDisplay = subDisplay
            self.l33tEntropy = l33tEntropy
        }
    }

    public struct Spatial: Codable {
        public let graph: String?
        public let turns: Int?
        public let shiftedCount: Int?

        public init(graph: String?, turns: Int?, shiftedCount: Int?) {
            self.graph = graph
            self.turns = turns
            self.shiftedCount = shiftedCount
        }
    }

    public struct Repeat: Codable {
        public let repeatedChar: String?

        public init(repeatedChar: String?) {
            self.repeatedChar = repeatedChar
        }
    }

    public struct Sequence: Codable {
        public let sequenceName: String?
        public let sequenceSpace: Int?
        public let ascending: Bool?

        public init(sequenceName: String?, sequenceSpace: Int?, ascending: Bool?) {
            self.sequenceName = sequenceName
            self.sequenceSpace = sequenceSpace
            self.ascending = ascending
        }
    }

    public struct Date: Codable {
        public let day: Int?
        public let month: Int?
        public let year: Int?
        public let separator: String?

        public init(day: Int?, month: Int?, year: Int?, separator: String?) {
            self.day = day
            self.month = month
            self.year = year
            self.separator = separator
        }
    }
}
