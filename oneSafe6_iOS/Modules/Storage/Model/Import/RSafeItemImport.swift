//
//  RSafeItemImport.swift
//  Crypto
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSafeItemImport: Object {
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
    @Persisted public var position: Double

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
                     position: Double) {
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
        self.position = position
    }
}

extension RSafeItemImport: CodableForAppModel {
    public static func from(appModel: SafeItemImport) -> RSafeItemImport {
        RSafeItemImport(id: appModel.id,
                        encName: appModel.encName,
                        encColor: appModel.encColor,
                        iconId: appModel.iconId,
                        parentId: appModel.parentId,
                        deletedParentId: appModel.deletedParentId,
                        isFavorite: appModel.isFavorite,
                        createdAt: appModel.createdAt,
                        updatedAt: appModel.updatedAt,
                        deletedAt: appModel.deletedAt,
                        position: appModel.position)
    }
    public func toAppModel() -> SafeItemImport {
        SafeItemImport(id: id,
                       encName: encName,
                       encColor: encColor,
                       iconId: iconId,
                       parentId: parentId,
                       deletedParentId: deletedParentId,
                       isFavorite: isFavorite,
                       createdAt: createdAt,
                       updatedAt: updatedAt,
                       deletedAt: deletedAt,
                       position: position)
    }
}

extension SafeItemImport: RealmStorable {
    public typealias RModel = RSafeItemImport
}
