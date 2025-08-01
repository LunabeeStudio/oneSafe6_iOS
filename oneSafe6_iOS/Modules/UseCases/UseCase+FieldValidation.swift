//
//  UseCase+FieldValidation.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 12/01/2023 - 11:01.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model

public extension UseCase {
    static func getMasterPasswordValidCriterias(_ password: String) -> [PasswordCriteria] {
        PasswordCriteria.allCases.filter { criteria in
            switch criteria {
            case .numberOfCharacter:
                return password.count >= Constant.PasswordCriteria.minNumberOfCharacters
            case .number:
                return !password.ranges(of: Constant.PasswordCriteria.containNumberRegex).isEmpty
            case .lowercase:
                return !password.ranges(of: Constant.PasswordCriteria.containLowercaseRegex).isEmpty
            case .uppercase:
                return !password.ranges(of: Constant.PasswordCriteria.containUppercaseRegex).isEmpty
            case .specialCharacter:
                return !password.ranges(of: Constant.PasswordCriteria.containSpecialCharacterRegex).isEmpty
            }
        }
    }
}
