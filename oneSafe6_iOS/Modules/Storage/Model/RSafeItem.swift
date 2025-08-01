//
//  RSafeItem.swift
//  Crypto
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSafeItem: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encName: Data?
    @Persisted public var encColor: Data?
    @Persisted public var iconId: String?
    @Persisted public var parentId: String?
    @Persisted public var deletedParentId: String?
    @Persisted public var isFavorite: Bool
    @Persisted public var createdAt: Date
    @Persisted public var updatedAt: Date
    @Persisted public var deletedAt: Date?
    @Persisted public var consultedAt: Date?
    @Persisted public var position: Double
    @Persisted public var alphabeticalPosition: Double?
    @Persisted public var consultedAtPosition: Double?
    @Persisted public var createdAtPosition: Double?

    convenience init(id: String,
                     encName: Data?,
                     encColor: Data?,
                     iconId: String?,
                     parentId: String?,
                     deletedParentId: String?,
                     isFavorite: Bool,
                     createdAt: Date,
                     updatedAt: Date,
                     deletedAt: Date?,
                     consultedAt: Date?,
                     position: Double,
                     alphabeticalPosition: Double?,
                     consultedAtPosition: Double?,
                     createdAtPosition: Double?) {
        self.init()
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

extension RSafeItem: CodableForAppModel {
    public static func from(appModel: SafeItem) -> RSafeItem {
        RSafeItem(id: appModel.id,
                  encName: appModel.encName,
                  encColor: appModel.encColor,
                  iconId: appModel.iconId,
                  parentId: appModel.parentId,
                  deletedParentId: appModel.deletedParentId,
                  isFavorite: appModel.isFavorite,
                  createdAt: appModel.createdAt,
                  updatedAt: appModel.updatedAt,
                  deletedAt: appModel.deletedAt,
                  consultedAt: appModel.consultedAt,
                  position: appModel.position,
                  alphabeticalPosition: appModel.alphabeticalPosition,
                  consultedAtPosition: appModel.consultedAtPosition,
                  createdAtPosition: appModel.createdAtPosition)
    }

    public func toAppModel() -> SafeItem {
        SafeItem(id: id,
                 encName: encName,
                 encColor: encColor,
                 iconId: iconId,
                 parentId: parentId,
                 deletedParentId: deletedParentId,
                 isFavorite: isFavorite,
                 createdAt: createdAt,
                 updatedAt: updatedAt,
                 deletedAt: deletedAt,
                 consultedAt: consultedAt,
                 position: position,
                 alphabeticalPosition: alphabeticalPosition,
                 consultedAtPosition: consultedAtPosition,
                 createdAtPosition: createdAtPosition)
    }
}

extension SafeItem: RealmStorable {
    public typealias RModel = RSafeItem
}
