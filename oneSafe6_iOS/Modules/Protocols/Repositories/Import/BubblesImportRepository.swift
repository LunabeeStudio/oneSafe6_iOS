//
//  BubblesImportRepository.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 16:49.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Model

public protocol BubblesImportRepository {
    func getAllDataToImport(progress: Progress) async throws -> (
        contacts: [Contact],
        contactsKeys: [ContactLocalKey],
        messages: [SafeMessage],
        conversations: [EncConversation]
    )
    func getAllContacts() throws -> [ContactImport]
    func save(contacts: [ContactImport]) throws
    func getAllContactKeys() throws -> [ContactLocalKeyImport]
    func save(contactKeys: [ContactLocalKeyImport]) throws
    func getAllMessages() throws -> [SafeMessageImport]
    func save(messages: [SafeMessageImport]) throws
    func getAllConversations() throws -> [EncConversationImport]
    func save(conversations: [EncConversationImport]) throws
    func deleteAll() throws
}
