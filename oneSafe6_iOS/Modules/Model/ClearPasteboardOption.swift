//
//  ClearPasteboardOption.swift
//  Model
//
//  Created by Lunabee Studio (Alexandre Cools) on 27/03/2023 - 3:05 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum ClearPasteboardOption: String, CaseIterable {
    case seconds10
    case seconds30
    case minute1
    case minutes2
    case minutes10
    case never

    public var durationInSeconds: Double? {
        switch self {
        case .seconds10:
            return 10
        case .seconds30:
            return 30
        case .minute1:
            return 60
        case .minutes2:
            return 120
        case .minutes10:
            return 600
        case .never:
            return nil
        }
    }

    public static let defaultValue: ClearPasteboardOption = .seconds30
}
