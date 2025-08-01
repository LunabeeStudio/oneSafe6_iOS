//
//  DatabaseRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Nicolas) on 06/04/2023 - 15:10.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Protocols
import Storage

final class DatabaseRepositoryImpl: DatabaseRepository {
    private let database: RealmManager = .shared

    func loadDatabases() throws {
        try database.loadDatabases()
    }

    func unloadDatabases() {
        database.unloadDatabases()
    }

    func deleteDatabase() throws {
        try database.deleteDatabase()
    }
}
