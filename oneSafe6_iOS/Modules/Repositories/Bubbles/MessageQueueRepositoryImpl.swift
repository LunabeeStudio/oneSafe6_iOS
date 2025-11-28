//
//  MessageQueueRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 31/07/2024 - 09:50.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp
import Storage

final class MessageQueueRepositoryImpl: MessageQueueLocalDatasource {
    private let userDefault: UserDefaultsManager = .shared

    func __insertValue(key: String, value: KotlinByteArray) async throws {
        userDefault.bubblesMessageQueue = value.toNSData()
    }

    func __retrieveValue(key: String) async throws -> KotlinByteArray? {
        userDefault.bubblesMessageQueue?.toByteArray()
    }
}
