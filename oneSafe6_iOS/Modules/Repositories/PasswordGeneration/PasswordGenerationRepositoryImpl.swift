//
//  PasswordGenerationRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/03/2023 - 11:12 AM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Protocols
import Storage

final class PasswordGenerationRepositoryImpl: PasswordGenerationRepository {
    func saveCriterias(uppercase: Bool, lowercase: Bool, number: Bool, symbol: Bool, length: Int) {
        UserDefaultsManager.shared.passwordGenerationUppercaseRequired = uppercase
        UserDefaultsManager.shared.passwordGenerationLowercaseRequired = lowercase
        UserDefaultsManager.shared.passwordGenerationNumberRequired = number
        UserDefaultsManager.shared.passwordGenerationSymbolRequired = symbol
        UserDefaultsManager.shared.passwordGenerationLengthRequired = length
    }

    func getCriterias() -> (uppercase: Bool, lowercase: Bool, number: Bool, symbol: Bool, length: Int) {
        (UserDefaultsManager.shared.passwordGenerationUppercaseRequired,
        UserDefaultsManager.shared.passwordGenerationLowercaseRequired,
        UserDefaultsManager.shared.passwordGenerationNumberRequired,
        UserDefaultsManager.shared.passwordGenerationSymbolRequired,
        UserDefaultsManager.shared.passwordGenerationLengthRequired)
    }
}
