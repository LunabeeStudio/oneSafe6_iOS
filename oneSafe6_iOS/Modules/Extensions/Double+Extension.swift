//
//  Double+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 16/10/2023 - 06:47.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Double {
    func formatDuration(style: DateComponentsFormatter.UnitsStyle = .positional, showAllDigits: Bool = true) -> String? {
        let formatter: DateComponentsFormatter = DateComponentsFormatter()
        if self >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        formatter.unitsStyle = style
        if showAllDigits {
            formatter.zeroFormattingBehavior = .pad
        }
        return formatter.string(from: self)
    }
}
