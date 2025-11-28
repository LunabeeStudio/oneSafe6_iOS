//
//  ContactLocalKey.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 14:50.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp

public struct ContactLocalKey {
    public let contactId: String
    public let encKey: Data

    public init(contactId: String, encKey: Data) {
        self.contactId = contactId
        self.encKey = encKey
    }
}

extension ContactLocalKey {
    public static func from(kmpModel: oneSafeKmp.ContactLocalKey, contactId: DoubleratchetDoubleRatchetUUID) -> ContactLocalKey {
        ContactLocalKey(
            contactId: contactId.uuidString(),
            encKey: kmpModel.encKey.toNSData()
        )
    }

    public func toKMPModel() -> oneSafeKmp.ContactLocalKey {
        .init(encKey: encKey.toByteArray())
    }
}
