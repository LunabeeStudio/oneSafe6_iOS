//
//  HandShakeDataRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 16:53.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp
import Storage
import Model
import Protocols

final class HandShakeDataRepositoryImpl: Protocols.HandShakeDataRepository {
    private let database: RealmManager = .shared

    func __delete(conversationLocalId: DoubleratchetDoubleRatchetUUID) async throws {
        try database.delete(objectOfType: EncHandShakeData.self, id: conversationLocalId.uuidString())
    }

    func __getById(conversationLocalId: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.EncHandShakeData? {
        guard let data: Model.EncHandShakeData = try database.get(conversationLocalId.uuidString()) else { return nil }
        return data.toKMPModel()
    }

    func __insert(handShakeData: oneSafeKmp.EncHandShakeData) async throws {
        try database.save(Model.EncHandShakeData.from(kmpModel: handShakeData))
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: Model.EncHandShakeData.self)
    }
}
