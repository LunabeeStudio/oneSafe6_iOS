//
//  RContactImport.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 17:16.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation
import RealmSwift
import Model

public final class RContactImport: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encName: Data
    @Persisted public var encSharedKey: Data?
    @Persisted public var updatedAt: Date
    @Persisted public var encSharingMode: Data
    @Persisted public var sharedConversationId: String
    @Persisted public var consultedAt: Date?
    @Persisted public var safeId: String // ignored until multi safe is supported
    @Persisted public var encResetConversationDate: Data?

    convenience init(
        id: String,
        encName: Data,
        encSharedKey: Data?,
        updatedAt: Date,
        encSharingMode: Data,
        sharedConversationId: String,
        consultedAt: Date?,
        safeId: String,
        encResetConversationDate: Data?
    ) {
        self.init()
        self.id = id
        self.encName = encName
        self.encSharedKey = encSharedKey
        self.updatedAt = updatedAt
        self.encSharingMode = encSharingMode
        self.sharedConversationId = sharedConversationId
        self.consultedAt = consultedAt
        self.safeId = safeId
        self.encResetConversationDate = encResetConversationDate
    }
}

extension RContactImport: CodableForAppModel {
    public static func from(appModel: ContactImport) throws -> RContactImport {
        RContactImport(
            id: appModel.id,
            encName: appModel.encName,
            encSharedKey: appModel.encSharedKey?.encKey,
            updatedAt: appModel.updatedAt,
            encSharingMode: appModel.encSharingMode,
            sharedConversationId: appModel.sharedConversationId,
            consultedAt: appModel.consultedAt,
            safeId: appModel.safeId,
            encResetConversationDate: appModel.encResetConversationDate
        )
    }

    public func toAppModel() throws -> ContactImport {
        ContactImport(
            id: id,
            encName: encName,
            encSharedKey: encSharedKey.map { ContactSharedKeyImport(encKey: $0) },
            updatedAt: updatedAt,
            encSharingMode: encSharingMode,
            sharedConversationId: sharedConversationId,
            consultedAt: consultedAt,
            safeId: safeId,
            encResetConversationDate: encResetConversationDate
        )
    }
}

extension ContactImport: RealmStorable {
    public typealias RModel = RContactImport
}
