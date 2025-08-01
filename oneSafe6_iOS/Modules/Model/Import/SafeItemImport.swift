//
//  SafeItemImport.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions

public struct SafeItemImport {
    public let id: String
    public var encName: Data?
    public var encColor: Data?
    public var iconId: String?
    public var parentId: String?
    public let deletedParentId: String?
    public let isFavorite: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let position: Double

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
                position: Double = 0) {
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
        self.position = position
    }
}
