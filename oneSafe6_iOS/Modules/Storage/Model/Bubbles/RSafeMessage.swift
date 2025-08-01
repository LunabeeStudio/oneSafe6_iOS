//
//  RSafeMessage.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 09:17.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSafeMessage: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var fromContactId: String?
    @Persisted public var encSentAt: Data
    @Persisted public var encContent: Data
    @Persisted public var direction: Direction
    @Persisted public var encChannel: Data?
    @Persisted public var isRead: Bool
    @Persisted public var order: Float
    @Persisted public var encSafeItemId: Data?

    public convenience init(id: String, fromContactId: String, encSentAt: Data, encContent: Data, direction: Direction, encChannel: Data?, isRead: Bool, order: Float, encSafeItemId: Data?) {
        self.init()
        self.id = id
        self.fromContactId = fromContactId
        self.encSentAt = encSentAt
        self.encContent = encContent
        self.direction = direction
        self.encChannel = encChannel
        self.isRead = isRead
        self.order = order
        self.encSafeItemId = encSafeItemId
    }
}

public extension RSafeMessage {
    enum Direction: String, PersistableEnum {
        case sent
        case received
    }
}

extension RSafeMessage: CodableForAppModel {
    public static func from(appModel: SafeMessage) throws -> RSafeMessage {
        let direction: RSafeMessage.Direction
        switch appModel.direction {
        case .received:
            direction = .received
        case .sent:
            direction = .sent
        }
        return RSafeMessage(
            id: appModel.id,
            fromContactId: appModel.fromContactId,
            encSentAt: appModel.encSentAt,
            encContent: appModel.encContent,
            direction: direction,
            encChannel: appModel.encChannel,
            isRead: appModel.isRead,
            order: appModel.order,
            encSafeItemId: appModel.encSafeItemId
        )
    }

    public func toAppModel() throws -> SafeMessage {
        let direction: SafeMessage.Direction
        switch self.direction {
        case .received:
            direction = .received
        case .sent:
            direction = .sent
        }
        return SafeMessage(
            id: id,
            fromContactId: fromContactId ?? "",
            encSentAt: encSentAt,
            encContent: encContent,
            direction: direction,
            encChannel: encChannel,
            isRead: isRead,
            order: order,
            encSafeItemId: encSafeItemId
        )
    }
}

extension SafeMessage: RealmStorable {
    public typealias RModel = RSafeMessage
}
