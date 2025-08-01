//
//  String+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Optional where Wrapped == String {
    var orEmpty: String {
        switch self {
        case .some(let value):
            return value
        case .none:
            return ""
        }
    }

    var orNotAvailable: String {
        switch self {
        case .some(let value):
            return value
        case .none:
            return "N/A"
        }
    }
}
