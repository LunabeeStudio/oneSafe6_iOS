//
//  UseCase+PasswordStength.swift
//  coreCrypto
//
//  Created by Lunabee Studio (Nicolas) on 10/02/2023 - 15:45.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import ZxcvbnSwift

extension UseCase {
    public static func passwordStrength(_ password: String) -> PasswordStrength? {
        guard let result = DBZxcvbn().passwordStrength(password) else { return nil }
        return .from(result: result)
    }
}

// MARK: - Private Passwords stuff -
private extension PasswordStrength {
    static func from(result: DBResult) -> Self {
        let strength: PasswordStrength = .init(entropy: result.entropy ?? "",
                                               crackTime: result.crackTime ?? "",
                                               crackTimeDisplay: result.crackTimeDisplay ?? "",
                                               score: Int(result.score),
                                               matchSequence: (result.matchSequence as? [DBMatch])?.map { .from(match: $0) } ?? [],
                                               calcTime: Double(result.calcTime))
        return strength
    }
}

private extension PasswordMatch {
    static func from(match: DBMatch) -> Self {
        let dictionary: PasswordMatch.Dictionary? = match.matchedWord.map { .init(matchedWord: $0, dictionaryName: match.dictionaryName, rank: Int(match.rank), baseEntropy: Double(match.baseEntropy), upperCaseEntropy: Double(match.upperCaseEntropy)) }
        let l33t: PasswordMatch.L33t? = match.l33t ? .init(sub: match.sub as? [String: String], subDisplay: match.subDisplay, l33tEntropy: Int(match.l33tEntropy)) : nil
        let spatial: PasswordMatch.Spatial? = match.graph.map { .init(graph: $0, turns: Int(match.turns), shiftedCount: Int(match.shiftedCount)) }
        let `repeat`: PasswordMatch.Repeat? = match.repeatedChar.map { .init(repeatedChar: $0) }
        let sequence: PasswordMatch.Sequence? = match.sequenceName.map { .init(sequenceName: $0, sequenceSpace: Int(match.sequenceSpace), ascending: match.ascending) }

        let dateFound: Bool = match.day != 0 || match.month != 0 || match.year != 0 || match.separator != nil
        let date: PasswordMatch.Date? = dateFound ? .init(day: Int(match.day), month: Int(match.month), year: Int(match.year), separator: match.separator) : nil

        let passwordMatch: PasswordMatch = .init(pattern: match.pattern as String?,
                                                 token: match.token,
                                                 startIndex: match.i,
                                                 endIndex: match.j,
                                                 entropy: Double(match.entropy),
                                                 cardinality: Int(match.cardinality),
                                                 dictionary: dictionary,
                                                 l33t: l33t,
                                                 spatial: spatial,
                                                 repeat: `repeat`,
                                                 sequence: sequence,
                                                 date: date)
        return passwordMatch
    }
}
