//
//  PasswordVerificationRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Quentin Noblet) on 13/06/2023 - 16:10.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Protocols
import Storage

final class PasswordVerificationRepositoryImpl: PasswordVerificationRepository {
    var lastPasswordVerificationDate: Date? {
        guard let timeStamp = FileDirectoryManager.shared.lastPasswordVerificationTimestamp() else { return nil }
        return Date(timeIntervalSince1970: timeStamp)
    }

    func updateLastPasswordEnterWithSuccessDate() throws {
        try FileDirectoryManager.shared.updateLastPasswordVerificationTimestamp(Date().timeIntervalSince1970)
    }
}
