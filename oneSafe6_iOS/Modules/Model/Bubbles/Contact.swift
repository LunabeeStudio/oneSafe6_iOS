//
//  Contact.swift
//  oneSafe
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 15:48.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp

public struct Contact {
    public var id: String
    public var encName: Data
    public var encSharedKey: ContactSharedKey?
    public var updatedAt: Date
    public var encSharingMode: Data
    public let sharedConversationId: String
    public var consultedAt: Date?
    public let safeId: String // ignored until multi safe is supported
    public var encResetConversationDate: Data?

    public init(id: String, encName: Data, encSharedKey: ContactSharedKey?, updatedAt: Date, encSharingMode: Data, sharedConversationId: String, consultedAt: Date?, safeId: String, encResetConversationDate: Data?) {
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

extension Contact {
    public static func from(kmpModel: oneSafeKmp.Contact) -> Contact {
        Contact(
            id: kmpModel.id.uuidString(),
            encName: kmpModel.encName.toNSData(),
            encSharedKey: kmpModel.encSharedKey.map { .from(kmpModel: $0, contactId: kmpModel.id) },
            updatedAt: kmpModel.updatedAt.toDate(),
            encSharingMode: kmpModel.encSharingMode.toNSData(),
            sharedConversationId: kmpModel.sharedConversationId.uuidString(),
            consultedAt: kmpModel.consultedAt?.toDate(),
            safeId: kmpModel.safeId.uuidString(),
            encResetConversationDate: kmpModel.encResetConversationDate?.toNSData()
        )
    }

    public func toKMPModel() -> oneSafeKmp.Contact {
        do {
            return oneSafeKmp.Contact(
                id: try .companion.fromString(uuidString: id),
                encName: encName.toByteArray(),
                encSharedKey: encSharedKey?.toKMPModel(),
                updatedAt: updatedAt.toInstant(),
                encSharingMode: encSharingMode.toByteArray(),
                sharedConversationId: try .companion.fromString(uuidString: sharedConversationId),
                consultedAt: consultedAt?.toInstant(),
                safeId: try .companion.fromString(uuidString: safeId),
                encResetConversationDate: encResetConversationDate?.toByteArray()
            )
        } catch {
            fatalError("Coudn't convert String into DoubleRatchetUUID")
        }
    }
}
