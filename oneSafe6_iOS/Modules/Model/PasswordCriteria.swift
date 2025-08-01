//
//  PasswordCriterias.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 12/01/2023 - 11:02.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public enum PasswordCriteria: CaseIterable {
    case numberOfCharacter
    case number
    case lowercase
    case uppercase
    case specialCharacter
}
