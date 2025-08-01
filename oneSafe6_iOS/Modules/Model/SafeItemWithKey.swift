//
//  SafeItemWithKey.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 22/12/2022 - 17:54.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation

public struct SafeItemWithKey: Identifiable {
    public var id: String { item.id }
    public let item: SafeItem
    public let key: SafeItemKey?

    public init(item: SafeItem, key: SafeItemKey?) {
        self.item = item
        self.key = key
    }
}

extension SafeItemWithKey: Hashable {
    public static func == (lhs: SafeItemWithKey, rhs: SafeItemWithKey) -> Bool {
        lhs.item.id == rhs.item.id && lhs.item.updatedAt == rhs.item.updatedAt
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(item.updatedAt)
    }
}
