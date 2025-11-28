//
//  ConversationRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 21/05/2025 - 11:49.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//


import Model
@preconcurrency import oneSafeKmp

public protocol ConversationRepository: ConversationLocalDatasource {
    func getAllConversations() throws -> [Model.EncConversation]
    func deleteAll() throws
    func deleteConversationForId(id: String) throws
}
