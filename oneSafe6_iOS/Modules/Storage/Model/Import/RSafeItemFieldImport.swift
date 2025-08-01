//
//  RSafeItemFieldImport.swift
//  Crypto
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSafeItemFieldImport: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encName: Data?
    @Persisted public var position: Double
    @Persisted public var itemId: String
    @Persisted public var encPlaceholder: Data?
    @Persisted public var encValue: Data?
    @Persisted public var encKind: Data?
    @Persisted public var createdAt: Date
    @Persisted public var updatedAt: Date
    @Persisted public var isItemIdentifier: Bool
    @Persisted public var encFormattingMask: Data?
    @Persisted public var encSecureDisplayMask: Data?
    @Persisted public var isSecured: Bool

    convenience init(id: String, encName: Data?, position: Double, itemId: String, encPlaceholder: Data? = nil, encValue: Data? = nil, encKind: Data?, createdAt: Date, updatedAt: Date, isItemIdentifier: Bool, encFormattingMask: Data?, encSecureDisplayMask: Data?, isSecured: Bool) {
        self.init()
        self.id = id
        self.encName = encName
        self.position = position
        self.itemId = itemId
        self.encPlaceholder = encPlaceholder
        self.encValue = encValue
        self.encKind = encKind
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isItemIdentifier = isItemIdentifier
        self.encFormattingMask = encFormattingMask
        self.encSecureDisplayMask = encSecureDisplayMask
        self.isSecured = isSecured
    }
}

extension RSafeItemFieldImport: CodableForAppModel {
    public static func from(appModel: SafeItemFieldImport) -> RSafeItemFieldImport {
        RSafeItemFieldImport(id: appModel.id,
                             encName: appModel.encName,
                             position: appModel.position,
                             itemId: appModel.itemId,
                             encPlaceholder: appModel.encPlaceholder,
                             encValue: appModel.encValue,
                             encKind: appModel.encKind,
                             createdAt: appModel.createdAt,
                             updatedAt: appModel.updatedAt,
                             isItemIdentifier: appModel.isItemIdentifier,
                             encFormattingMask: appModel.encFormattingMask,
                             encSecureDisplayMask: appModel.encSecureDisplayMask,
                             isSecured: appModel.isSecured)
    }

    public func toAppModel() -> SafeItemFieldImport {
        SafeItemFieldImport(id: id,
                            encName: encName,
                            position: position,
                            itemId: itemId,
                            encPlaceholder: encPlaceholder,
                            encValue: encValue,
                            encKind: encKind,
                            createdAt: createdAt,
                            updatedAt: updatedAt,
                            isItemIdentifier: isItemIdentifier,
                            encFormattingMask: encFormattingMask,
                            encSecureDisplayMask: encSecureDisplayMask,
                            isSecured: isSecured)
    }
}

extension SafeItemFieldImport: RealmStorable {
    public typealias RModel = RSafeItemFieldImport
}
