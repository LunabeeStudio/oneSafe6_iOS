//
//  UseCase+PasswordVerification.swift
//  Repositories
//
//  Created by Lunabee Studio (Quentin Noblet) on 13/06/2023 - 16:15.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model

public extension UseCase {
    private static var lastPasswordVerificationRequestDate: Date?

    static func shouldShowPasswordVerification() -> Bool {
        guard isBiometryActivated() else { return false }
        // Should be shown once a day or after an app restard
        guard !Calendar.current.isDateInToday(lastPasswordVerificationRequestDate ?? .distantPast) else { return false }

        guard let passwordVerificationDurationInWeeks = settingsRepository.getPasswordVerificationOption().durationInWeeks else { return false }
        guard let lastPasswordVerificationDate = passwordVerificationRepository.lastPasswordVerificationDate else { return false }

        var dateComponent: DateComponents = .init()
        dateComponent.weekOfYear = passwordVerificationDurationInWeeks

        guard let minimumPasswordVerificationDate = Calendar.current.date(byAdding: dateComponent, to: lastPasswordVerificationDate) else { return false }

        return minimumPasswordVerificationDate < Date()
    }

    static func showPasswordVerificationLater() {
        lastPasswordVerificationRequestDate = Date()
    }
}
