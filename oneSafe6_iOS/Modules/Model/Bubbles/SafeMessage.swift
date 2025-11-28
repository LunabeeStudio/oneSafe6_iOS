//
//  SafeMessage.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 17:53.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp

public struct SafeMessage {
    public var id: String
    public let fromContactId: String
    public let encSentAt: Data
    public let encContent: Data
    public let direction: Direction
    public let encChannel: Data?
    public let isRead: Bool
    public let order: Float
    public let encSafeItemId: Data?

    public init(id: String, fromContactId: String, encSentAt: Data, encContent: Data, direction: Direction, encChannel: Data?, isRead: Bool, order: Float, encSafeItemId: Data?) {
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

public extension SafeMessage {
    enum Direction {
        case sent
        case received
    }
}

extension SafeMessage {
    public static func from(kmpModel: oneSafeKmp.SafeMessage, order: Float) -> SafeMessage {
        SafeMessage(
            id: kmpModel.id.uuidString(),
            fromContactId: kmpModel.fromContactId.uuidString(),
            encSentAt: kmpModel.encSentAt.toNSData(),
            encContent: kmpModel.encContent.toNSData(),
            direction: .from(kmpModel: kmpModel.direction),
            encChannel: kmpModel.encChannel?.toNSData(),
            isRead: kmpModel.isRead,
            order: order,
            encSafeItemId: kmpModel.encSafeItemId?.toNSData()
        )
    }

    public func toKMPSafeMessageModel() -> oneSafeKmp.SafeMessage {
        do {
            return oneSafeKmp.SafeMessage(
                id: try .companion.fromString(uuidString: id),
                fromContactId: try .companion.fromString(uuidString: fromContactId),
                encSentAt: encSentAt.toByteArray(),
                encContent: encContent.toByteArray(),
                direction: direction.toKMPModel(),
                encChannel: encChannel?.toByteArray(),
                isRead: isRead,
                encSafeItemId: encSafeItemId?.toByteArray()
            )
        } catch {
            fatalError("Coudn't convert into DoubleRatchetUUID")
        }
    }

    public func toKMPMessageOrderModel() -> oneSafeKmp.MessageOrder {
        do {
            return oneSafeKmp.MessageOrder(
                id: try .companion.fromString(uuidString: id),
                encSentAt: encSentAt.toByteArray(),
                order: order
            )
        } catch {
            fatalError("Coudn't convert \(id) into DoubleRatchetUUID")
        }
    }
}

extension SafeMessage.Direction {
    public static func from(kmpModel: oneSafeKmp.MessageDirection) -> SafeMessage.Direction {
        switch kmpModel {
        case .received: .received
        case .sent: .sent
        }
    }

    public func toKMPModel() -> oneSafeKmp.MessageDirection {
        switch self {
        case .sent: .sent
        case .received: .received
        }
    }
}
