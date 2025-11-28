//
//  Constant.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 07/03/2023 - 16:07.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

enum Constant {
    enum Keychain {
        static let service: String = Bundle.stCurrentBundleIdentifier
        static let accessGroup: String = "VH79XGK7M2.studio.lunabee.oneSafe.ios"
    }

    enum PasswordGeneration {
        static let defaultLength: Int = 12
    }
}
