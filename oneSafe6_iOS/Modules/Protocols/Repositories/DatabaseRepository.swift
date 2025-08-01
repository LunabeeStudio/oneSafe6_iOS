//
//  DatabaseRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 17:21.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model

public protocol DatabaseRepository {
    func loadDatabases() throws
    func unloadDatabases()
    func deleteDatabase() throws
}
