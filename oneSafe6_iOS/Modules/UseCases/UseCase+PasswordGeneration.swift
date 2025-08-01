//
//  UseCase+PasswordGeneration.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 01/03/2023 - 05:53.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model

public extension UseCase {
    static func generatePassword(config: PasswordConfig) -> String {
        var password: String = ""
        repeat {
            password = randomString(config: config)
        } while !checkAllConditionsAreValid(password: password, config: config)
        return password
    }

    static func savePasswordGenerationCriterias(uppercase: Bool, lowercase: Bool, number: Bool, symbol: Bool, length: Int) {
        passwordGenerationRepository.saveCriterias(uppercase: uppercase, lowercase: lowercase, number: number, symbol: symbol, length: length)
    }

    static func getPasswordGenerationCriterias() -> (uppercase: Bool, lowercase: Bool, number: Bool, symbol: Bool, length: Int) {
        passwordGenerationRepository.getCriterias()
    }
}

private extension UseCase {
    static func randomString(config: PasswordConfig) -> String {
        var letters: [Character] = []
        if config.includeUppercase {
            letters.append(contentsOf: Constant.PasswordCriteria.uppercaseCharacterSet)
        }
        if config.includeLowercase {
            letters.append(contentsOf: Constant.PasswordCriteria.lowerCaseCharacterSet)
        }
        if config.includeNumber {
            letters.append(contentsOf: Constant.PasswordCriteria.numberCharacterSet)
        }
        if config.includeSymbol {
            letters.append(contentsOf: Constant.PasswordCriteria.specialCharacterSet)
        }
        var generatedString: String = ""
        var generator: Generator = .init()
        (0..<config.length).forEach { _ in
            letters.randomElement(using: &generator).map { generatedString.append($0) }
        }
        return generatedString
    }

    static func checkAllConditionsAreValid(password: String, config: PasswordConfig) -> Bool {
        password.count == config.length
        && (!config.includeUppercase || password.matches(of: Constant.PasswordCriteria.containUppercaseRegex).count > 0)
        && (!config.includeLowercase || password.matches(of: Constant.PasswordCriteria.containLowercaseRegex).count > 0)
        && (!config.includeNumber || password.matches(of: Constant.PasswordCriteria.containNumberRegex).count > 0)
        && (!config.includeSymbol || password.matches(of: Constant.PasswordCriteria.containSpecialCharacterRegex).count > 0)
    }
}
