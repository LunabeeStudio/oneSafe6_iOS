//
//  Character+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 16/03/2023 - 16:17.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Character {
    var isSimpleEmoji: Bool {
        guard let firstProperty: Unicode.Scalar.Properties = unicodeScalars.first?.properties else { return false }
        return unicodeScalars.count == 1 && (firstProperty.isEmojiPresentation || firstProperty.generalCategory == .otherSymbol || firstProperty.generalCategory == .unassigned)
    }
    var isCombinedIntoEmoji: Bool {
        unicodeScalars.count > 1 && unicodeScalars.contains { $0.properties.isEmoji }
    }
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}
