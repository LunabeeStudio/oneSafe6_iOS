//
//  InactivityAutolockOption.swift
//  oneSafe
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/03/2023 - 5:37 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum InactivityAutolockOption: String, CaseIterable {
    case seconds30
    case minute1
    case minutes2
    case minutes5
    case minutes10
    case never

    public var durationInSeconds: Double? {
        switch self {
        case .seconds30:
            return 30
        case .minute1:
            return 60
        case .minutes2:
            return 120
        case .minutes5:
            return 300
        case .minutes10:
            return 600
        case .never:
            return nil
        }
    }

    public static let defaultValue: InactivityAutolockOption = .seconds30
}
