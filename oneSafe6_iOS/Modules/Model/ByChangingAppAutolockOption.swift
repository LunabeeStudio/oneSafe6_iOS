//
//  ByChangingAppAutolockOption.swift
//  oneSafe
//
//  Created by Lunabee Studio (Alexandre Cools) on 19/03/2023 - 4:17 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum ByChangingAppAutolockOption: String, CaseIterable {
    case directly
    case seconds5
    case seconds10
    case minute1
    case minute5
    case never

    public var durationInSeconds: Double? {
        switch self {
        case .directly:
            return 0
        case .seconds5:
            return 5
        case .seconds10:
            return 10
        case .minute1:
            return 60
        case .minute5:
            return 300
        case .never:
            return nil
        }
    }

    public static let defaultValue: ByChangingAppAutolockOption = .seconds10
}
