//
//  MessageResendDelay.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 17:27.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation

public enum MessageResendDelay: CaseIterable {
    case never
    case oneDay
    case twoDay
    case fiveDay
    case always

    public init?(numberOfMilliSeconds: Int64) {
        switch numberOfMilliSeconds {
        case 0:
            self = .never
        case 86_400_000:
            self = .oneDay
        case 172_800_000:
            self = .twoDay
        case 432_000_000:
            self = .fiveDay
        case .max:
            self = .always
        default:
            return nil
        }
    }

    public var numberOfMilliSeconds: Int64 {
        switch self {
        case .never: 0
        case .oneDay: 86_400_000
        case .twoDay: 172_800_000
        case .fiveDay: 432_000_000
        case .always: .max
        }
    }

    public static let defaultValue: MessageResendDelay = .oneDay
}
