//
//  BiometryAvailabilityError.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 03/02/2023 - 14:11.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public enum BiometryAvailabilityError {
    /// Biometry not activated on the device (no face/no fingers registered).
    case notEnrolled
    /// Biometry refused by the user for the application.
    case notAvailable
    /// Authentication was not successful because there were too many failed biometry attempts and
    /// biometry is now locked
    case locked
}
