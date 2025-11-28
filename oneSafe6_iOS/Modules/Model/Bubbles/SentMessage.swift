//
//  SentMessage.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 14:09.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp

public struct SentMessage {
    public let id: String
    public let contactId: String
    public let encContent: Data
    public let encCreatedAt: Data
    public let order: Float
    public let safeId: String

    public init(id: String, contactId: String, encContent: Data, encCreatedAt: Data, order: Float, safeId: String) {
        self.id = id
        self.contactId = contactId
        self.encContent = encContent
        self.encCreatedAt = encCreatedAt
        self.order = order
        self.safeId = safeId
    }
}

extension SentMessage {
    public static func from(kmpModel: oneSafeKmp.SentMessage) -> SentMessage {
        SentMessage(
            id: kmpModel.id.uuidString(),
            contactId: kmpModel.contactId.uuidString(),
            encContent: kmpModel.encContent.toNSData(),
            encCreatedAt: kmpModel.encCreatedAt.toNSData(),
            order: kmpModel.order,
            safeId: kmpModel.safeId.uuidString()

        )
    }

    public func toKMPModel() -> oneSafeKmp.SentMessage {
        do {
            return oneSafeKmp.SentMessage(
                id: try .companion.fromString(uuidString: id),
                contactId: try .companion.fromString(uuidString: contactId),
                encContent: encContent.toByteArray(),
                encCreatedAt: encCreatedAt.toByteArray(),
                order: order,
                safeId: try .companion.fromString(uuidString: safeId)
            )
        } catch {
            fatalError("Coudn't convert into DoubleRatchetUUID")
        }
    }
}
