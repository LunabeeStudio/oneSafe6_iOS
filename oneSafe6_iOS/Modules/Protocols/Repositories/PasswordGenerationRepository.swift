//
//  PasswordGenerationRepository.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/03/2023 - 11:12 AM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public protocol PasswordGenerationRepository {
    func saveCriterias(uppercase: Bool, lowercase: Bool, number: Bool, symbol: Bool, length: Int)
    func getCriterias() -> (uppercase: Bool, lowercase: Bool, number: Bool, symbol: Bool, length: Int)
}
