//
//  SafeItem.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions

public struct SafeItem: Sendable {
    public var id: String
    public var encName: Data?
    public var encColor: Data?
    public var iconId: String?
    public var parentId: String?
    public var deletedParentId: String?
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var consultedAt: Date?
    public var position: Double
    public var alphabeticalPosition: Double?
    public var consultedAtPosition: Double?
    public var createdAtPosition: Double?

    public init(id: String = UUID().uuidStringV4,
                encName: Data? = nil,
                encColor: Data? = nil,
                iconId: String? = nil,
                parentId: String? = nil,
                deletedParentId: String? = nil,
                isFavorite: Bool = false,
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                deletedAt: Date? = nil,
                consultedAt: Date? = nil,
                position: Double = 0,
                alphabeticalPosition: Double? = nil,
                consultedAtPosition: Double? = nil,
                createdAtPosition: Double? = nil) {
        self.id = id
        self.encName = encName
        self.encColor = encColor
        self.iconId = iconId
        self.parentId = parentId
        self.deletedParentId = deletedParentId
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.consultedAt = consultedAt
        self.position = position
        self.alphabeticalPosition = alphabeticalPosition
        self.consultedAtPosition = consultedAtPosition
        self.createdAtPosition = createdAtPosition
    }
}

extension SafeItem: Hashable {
    public static func == (lhs: SafeItem, rhs: SafeItem) -> Bool {
        lhs.id == rhs.id
            && lhs.updatedAt == rhs.updatedAt
            && lhs.isFavorite == rhs.isFavorite
            && lhs.deletedAt == rhs.deletedAt
            && lhs.parentId == rhs.parentId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isFavorite)
        hasher.combine(updatedAt)
        hasher.combine(deletedAt)
        hasher.combine(parentId)
    }
}
