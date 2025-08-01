//
//  ContactSharedKey.swift
//  oneSafe
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 15:50.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp

public struct ContactSharedKey {
    public let encKey: Data

    public init(encKey: Data) {
        self.encKey = encKey
    }
}

extension ContactSharedKey {
    public static func from(kmpModel: oneSafeKmp.ContactSharedKey, contactId: DoubleratchetDoubleRatchetUUID) -> ContactSharedKey {
        ContactSharedKey(encKey: kmpModel.encKey.toNSData())
    }

    public func toKMPModel() -> oneSafeKmp.ContactSharedKey {
        .init(encKey: encKey.toByteArray())
    }
}
