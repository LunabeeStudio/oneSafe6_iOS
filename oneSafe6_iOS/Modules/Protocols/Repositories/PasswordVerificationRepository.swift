//
//  PasswordVerificationRepository.swift
//  Repositories
//
//  Created by Lunabee Studio (Quentin Noblet) on 13/06/2023 - 16:07.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public protocol PasswordVerificationRepository {
    var lastPasswordVerificationDate: Date? { get }
    func updateLastPasswordEnterWithSuccessDate() throws

}
