//
//  DoubleRatchetKeyRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 18:44.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Storage
import Model
import oneSafeKmp

final class DoubleRatchetKeyRepositoryImpl: DoubleRatchetKeyLocalDatasource {
    private let database: RealmManager = .shared

    func __deleteById(id: String) async throws {
        try database.delete(objectOfType: EncDoubleRatchetKey.self, id: id)
    }

    func __getById(id: String) async throws -> KotlinByteArray? {
        let key: Model.EncDoubleRatchetKey? = try database.get(id)
        return key?.data.toByteArray()
    }

    func __insert(key: oneSafeKmp.EncDoubleRatchetKey) async throws {
        let newKey: Model.EncDoubleRatchetKey = .from(kmpModel: key)
        try database.save(newKey)
    }
}
