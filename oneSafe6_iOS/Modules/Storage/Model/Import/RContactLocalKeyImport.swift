//
//  RContactLocalKeyImport.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 17:39.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RContactLocalKeyImport: Object {
    @Persisted(primaryKey: true) public var contactId: String
    @Persisted public var encKey: Data

    convenience init(contactId: String, encKey: Data) {
        self.init()
        self.contactId = contactId
        self.encKey = encKey
    }
}

extension RContactLocalKeyImport: CodableForAppModel {
    public static func from(appModel: ContactLocalKeyImport) throws -> RContactLocalKeyImport {
        RContactLocalKeyImport(
            contactId: appModel.contactId,
            encKey: appModel.encKey
        )
    }

    public func toAppModel() throws -> ContactLocalKeyImport {
        ContactLocalKeyImport(
            contactId: contactId,
            encKey: encKey
        )
    }
}

extension ContactLocalKeyImport: RealmStorable {
    public typealias RModel = RContactLocalKeyImport
}
