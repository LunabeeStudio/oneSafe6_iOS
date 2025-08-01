//
//  RSafeMessafeImport.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 17:42.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSafeMessageImport: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var fromContactId: String
    @Persisted public var encSentAt: Data
    @Persisted public var encContent: Data
    @Persisted public var direction: Direction
    @Persisted public var encChannel: Data?
    @Persisted public var isRead: Bool
    @Persisted public var order: Float
    @Persisted public var encSafeItemId: Data?

    convenience init(id: String, fromContactId: String, encSentAt: Data, encContent: Data, direction: Direction, encChannel: Data?, isRead: Bool, order: Float, encSafeItemId: Data?) {
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

public extension RSafeMessageImport {
    enum Direction: String, PersistableEnum {
        case sent
        case received
    }
}

extension RSafeMessageImport: CodableForAppModel {
    public static func from(appModel: SafeMessageImport) throws -> RSafeMessageImport {
        RSafeMessageImport(
            id: appModel.id,
            fromContactId: appModel.fromContactId,
            encSentAt: appModel.encSentAt,
            encContent: appModel.encContent,
            direction: appModel.direction == .sent ? .sent : .received,
            encChannel: appModel.encChannel,
            isRead: appModel.isRead,
            order: appModel.order,
            encSafeItemId: appModel.encSafeItemId
        )
    }

    public func toAppModel() throws -> SafeMessageImport {
        SafeMessageImport(
            id: id,
            fromContactId: fromContactId,
            encSentAt: encSentAt,
            encContent: encContent,
            direction: direction == .sent ? .sent : .received,
            encChannel: encChannel,
            isRead: isRead,
            order: order,
            encSafeItemId: encSafeItemId
        )
    }
}

extension SafeMessageImport: RealmStorable {
    public typealias RModel = RSafeMessageImport
}
