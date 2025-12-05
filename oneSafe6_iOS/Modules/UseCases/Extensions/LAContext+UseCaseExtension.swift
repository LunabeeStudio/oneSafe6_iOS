//
//  LAContext+Extension.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 20/02/2023 - 15:21.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import LocalAuthentication

extension LAContext {
    static var isBiometryAvailable: Bool { Self().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) }
}
