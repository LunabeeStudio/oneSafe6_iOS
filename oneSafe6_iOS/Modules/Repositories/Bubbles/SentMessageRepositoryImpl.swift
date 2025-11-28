//
//  SentMessageRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 14:07.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp
import Model
import Storage
import Protocols

final class SentMessageRepositoryImpl: Protocols.SentMessageRepository {
    private let database: RealmManager = .shared

    func __deleteSentMessage(id: DoubleratchetDoubleRatchetUUID) async throws {
        try database.delete(objectOfType: SentMessage.self, id: id.uuidString())
    }

    func __getOldestSentMessage(safeId: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.SentMessage? {
        let allMessages: [Model.SentMessage] = try database.getAll()
        return allMessages.max { lhs, rhs in
            lhs.order < rhs.order
        }?.toKMPModel()
    }

    func __getSentMessage(id: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.SentMessage? {
        let message: Model.SentMessage? = try database.get(id.uuidString())
        return message?.toKMPModel()
    }

    func __saveSentMessage(sentMessage: oneSafeKmp.SentMessage) async throws {
        let newMessage: Model.SentMessage = .from(kmpModel: sentMessage)
        try database.save(newMessage)
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: Model.SentMessage.self)
    }
}
