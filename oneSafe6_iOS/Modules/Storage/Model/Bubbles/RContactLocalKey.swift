//
//  RContactLocalKey.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 15:02.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RContactLocalKey: Object {
    @Persisted(primaryKey: true) public var contactId: String
    @Persisted public var encKey: Data

    public convenience init(contactId: String, encKey: Data) {
        self.init()
        self.contactId = contactId
        self.encKey = encKey
    }
}

extension RContactLocalKey: CodableForAppModel {
    public var id: String { contactId }

    public static func from(appModel: ContactLocalKey) -> RContactLocalKey {
        RContactLocalKey(
            contactId: appModel.contactId,
            encKey: appModel.encKey
        )
    }

    public func toAppModel() -> ContactLocalKey {
        ContactLocalKey(contactId: contactId, encKey: encKey)
    }
}

extension ContactLocalKey: RealmStorable {
    public typealias RModel = RContactLocalKey
}
