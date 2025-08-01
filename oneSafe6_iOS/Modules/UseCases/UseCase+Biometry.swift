//
//  UseCase+Biometry.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 15/02/2023 - 15:19.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import CoreCrypto
import Repositories
import Model
import LocalAuthentication
import Errors
import Combine

public extension UseCase {
    static func isBiometryAvailable() -> Bool {
        LAContext.isBiometryAvailable
    }

    static func checkUserBiometry(reason: String, cancelTitle: String) async throws -> Bool {
        updateShouldPreventAutoLock(true)
        defer { updateShouldPreventAutoLock(false) }
        let context: LAContext = .init()
        context.localizedFallbackTitle = "" // This is here to prevent iOS from showing the device code fallback option.
        context.localizedCancelTitle = cancelTitle
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }

    static func activateBiometry(password: String) throws {
        let coreCrypto: CoreCrypto = .shared

        let masterSalt: Data = try cryptoRepository.getMasterSalt()
        guard try coreCrypto.areCredentialsValid(password, salt: masterSalt) else { throw AppError.cryptoWrongPassword }

        let searchIndexSalt: Data = try cryptoRepository.getSearchIndexSalt()

        let masterKey: Data = try coreCrypto.derive(password: password, salt: masterSalt)
        let searchIndexMasterKey: Data = try coreCrypto.derive(password: password, salt: searchIndexSalt)

        try cryptoRepository.save(masterKey: masterKey)
        try cryptoRepository.save(searchIndexMasterKey: searchIndexMasterKey)
    }

    static func isBiometryActivated() -> Bool {
        LAContext.isBiometryAvailable && cryptoRepository.isBiometryActivated()
    }

    static func observeIsBiometryActivated() -> CurrentValueSubject<Bool, Never> {
        cryptoRepository.observeIsBiometryActivated()
    }

    static func deactivateBiometry() throws {
        try cryptoRepository.deleteBiometryMasterKeys()
    }

    static func biometryAvailabilityError() -> BiometryAvailabilityError? {
        let context: LAContext = .init()
        var error: NSError?
        let canEvaluate: Bool = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        guard let error, !canEvaluate else { return nil }
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return .notAvailable
        case LAError.passcodeNotSet.rawValue, LAError.biometryNotEnrolled.rawValue:
            return .notEnrolled
        case LAError.biometryLockout.rawValue:
            return .locked
        default:
            return nil
        }
    }

    static func deviceBiometry() -> Biometry? {
        let context: LAContext = .init()
        // We must call canEvaluatePolicy before access biometryType
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return nil
        @unknown default:
            return nil
        }
    }
}
