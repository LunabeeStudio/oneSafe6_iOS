//
//  PasswordVerificationOption.swift
//  Model
//
//  Created by Lunabee Studio (Quentin Noblet) on 13/06/2023 - 14:22.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum PasswordVerificationOption: String, CaseIterable {
    case week1
    case week2
    case month1
    case month2
    case month6
    case never

    public var durationInWeeks: Int? {
        switch self {
        case .week1:
            return 1
        case .week2:
            return 2
        case .month1:
            return 4
        case .month2:
            return 8
        case .month6:
            return 24
        case .never:
            return nil
        }
    }

    public static let defaultValue: PasswordVerificationOption = .week1
}
