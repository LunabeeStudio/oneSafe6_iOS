//
//  RSentMessage.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 14:15.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import RealmSwift
import Model

public final class RSentMessage: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var contactId: String
    @Persisted public var encContent: Data
    @Persisted public var encCreatedAt: Data
    @Persisted public var order: Float
    @Persisted public var safeId: String

    convenience public init(id: String, contactId: String, encContent: Data, encCreatedAt: Data, order: Float, safeId: String) {
        self.init()
        self.id = id
        self.contactId = contactId
        self.encContent = encContent
        self.encCreatedAt = encCreatedAt
        self.order = order
        self.safeId = safeId
    }
}

extension RSentMessage: CodableForAppModel {
    public static func from(appModel: SentMessage) -> RSentMessage {
        RSentMessage(
            id: appModel.id,
            contactId: appModel.contactId,
            encContent: appModel.encContent,
            encCreatedAt: appModel.encCreatedAt,
            order: appModel.order,
            safeId: appModel.safeId
        )
    }

    public func toAppModel() -> SentMessage {
        SentMessage(
            id: id,
            contactId: contactId,
            encContent: encContent,
            encCreatedAt: encCreatedAt,
            order: order, 
            safeId: safeId
        )
    }
}

extension SentMessage: RealmStorable {
    public typealias RModel = RSentMessage
}
