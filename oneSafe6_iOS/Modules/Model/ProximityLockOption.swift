//
//  ProximityLockOption.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 13/12/2023 - 18:45.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum ProximityLockOption: String, CaseIterable {
    case never
    case instant
    case slightDelay

    public var durationInMilliseconds: Int? {
        switch self {
        case .never:
            nil
        case .instant:
            0
        case .slightDelay:
            700
        }
    }

    public static let defaultValue: ProximityLockOption = .never
}
