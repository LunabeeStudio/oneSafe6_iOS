//
//  ContactKeyRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 14:49.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp
import Model
import Storage
import RealmSwift
import Protocols

final class ContactKeyRepositoryImpl: Protocols.ContactKeyRepository {
    private let database: RealmManager = .shared

    func __getContactLocalKey(contactId: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.ContactLocalKey? {
        guard let key = try database.get(ContactLocalKey.self, id: contactId.uuidString()) else { return nil }
        return key.toKMPModel()
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: Model.ContactLocalKey.self)
    }
}
