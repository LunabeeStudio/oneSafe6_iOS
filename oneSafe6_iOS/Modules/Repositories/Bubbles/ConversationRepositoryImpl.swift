//
//  ConversationRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 17:59.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp
import Model
import Storage
import Protocols

final class ConversationRepositoryImpl: Protocols.ConversationRepository {
    private let database: RealmManager = .shared

    func __getById(id: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.EncConversation? {
        let conversation: Model.EncConversation? = try database.get(id.uuidString())
        return conversation?.toKMPModel()
    }

    func __insert(conversation: oneSafeKmp.EncConversation) async throws {
        let newConversation: Model.EncConversation = .from(kmpModel: conversation)
        try database.save(newConversation)
    }

    func getAllConversations() throws -> [Model.EncConversation] {
        try database.getAll()
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: Model.EncConversation.self)
    }

    func deleteConversationForId(id: String) throws {
        try database.delete(objectOfType: Model.EncConversation.self, id: id)
    }
}
