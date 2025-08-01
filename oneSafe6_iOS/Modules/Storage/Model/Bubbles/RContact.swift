//
//  RContact.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 15:53.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RContact: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encName: Data
    @Persisted public var encSharedKey: Data?
    @Persisted public var updatedAt: Date
    @Persisted public var encSharingMode: Data
    @Persisted public var sharedConversationId: String
    @Persisted public var consultedAt: Date?
    @Persisted public var safeId: String // ignored until multi safe is supported
    @Persisted public var encResetConversationDate: Data?

    public convenience init(id: String, encName: Data, encSharedKey: Data?, updatedAt: Date, encSharingMode: Data, sharedConversationId: String, consultedAt: Date?, safeId: String, encResetConversationDate: Data?) {
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

extension RContact: CodableForAppModel {
    public static func from(appModel: Contact) -> RContact {
        RContact(
            id: appModel.id,
            encName: appModel.encName,
            encSharedKey: appModel.encSharedKey.map { $0.encKey },
            updatedAt: appModel.updatedAt,
            encSharingMode: appModel.encSharingMode,
            sharedConversationId: appModel.sharedConversationId,
            consultedAt: appModel.consultedAt,
            safeId: appModel.safeId,
            encResetConversationDate: appModel.encResetConversationDate
        )
    }

    public func toAppModel() -> Contact {
        Contact(
            id: id,
            encName: encName,
            encSharedKey: encSharedKey.map { ContactSharedKey(encKey: $0) },
            updatedAt: updatedAt,
            encSharingMode: encSharingMode,
            sharedConversationId: sharedConversationId,
            consultedAt: consultedAt,
            safeId: id,
            encResetConversationDate: encResetConversationDate
        )
    }
}

extension Contact: RealmStorable {
    public typealias RModel = RContact
}
