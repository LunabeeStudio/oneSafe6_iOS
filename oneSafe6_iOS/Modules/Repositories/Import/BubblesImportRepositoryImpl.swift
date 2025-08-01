//
//  BubblesImportRepositoryImpl.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 17:09.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Protocols
import Model
import Storage

final class BubblesImportRepositoryImpl: BubblesImportRepository {
    private let database: RealmManager = .shared

    func getAllDataToImport(progress: Progress) async throws -> (
        contacts: [Contact],
        contactsKeys: [ContactLocalKey],
        messages: [SafeMessage],
        conversations: [EncConversation]
    ) {
        let importContacts: [ContactImport] = try getAllContacts()
        let importContactsKeys: [ContactLocalKeyImport] = try getAllContactKeys()
        let importMessages: [SafeMessageImport] = try getAllMessages()
        let importConversations: [EncConversationImport] = try getAllConversations()

        let worker: ProgressWorker = .init(progress: progress)
        worker.progress.totalUnitCount = Int64(importContacts.count + importContactsKeys.count + importMessages.count + importConversations.count)

        async let contacts: [Contact] = try withThrowingTaskGroup(of: Contact.self) { taskGroup in
            for contact in importContacts {
                taskGroup.addTask {
                    await worker.increment(1)
                    return contact.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let contactsKeys: [ContactLocalKey] = try withThrowingTaskGroup(of: ContactLocalKey.self) { taskGroup in
            for key in importContactsKeys {
                taskGroup.addTask {
                    await worker.increment(1)
                    return key.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let messages: [SafeMessage] = try withThrowingTaskGroup(of: SafeMessage.self) { taskGroup in
            for message in importMessages {
                taskGroup.addTask {
                    await worker.increment(1)
                    return message.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let conversations: [EncConversation] = try withThrowingTaskGroup(of: EncConversation.self) { taskGroup in
            for conversation in importConversations {
                taskGroup.addTask {
                    await worker.increment(1)
                    return conversation.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }
        return try await (contacts, contactsKeys, messages, conversations)
    }
    
    func getAllContacts() throws -> [ContactImport] {
        try database.getAll()
    }
    
    func save(contacts: [ContactImport]) throws {
        try database.save(contacts)
    }
    
    func getAllContactKeys() throws -> [ContactLocalKeyImport] {
        try database.getAll()
    }
    
    func save(contactKeys: [ContactLocalKeyImport]) throws {
        try database.save(contactKeys)
    }
    
    func getAllMessages() throws -> [SafeMessageImport] {
        try database.getAll()
    }
    
    func save(messages: [SafeMessageImport]) throws {
        try database.save(messages)
    }
    
    func getAllConversations() throws -> [EncConversationImport] {
        try database.getAll()
    }
    
    func save(conversations: [EncConversationImport]) throws {
        try database.save(conversations)
    }
    
    func deleteAll() throws {
        try database.deleteAll(objectsOfType: ContactImport.self)
        try database.deleteAll(objectsOfType: ContactLocalKeyImport.self)
        try database.deleteAll(objectsOfType: SafeMessageImport.self)
        try database.deleteAll(objectsOfType: EncConversationImport.self)
    }
}

// MARK: Model conversion
private extension ContactImport {
    func toAppModel() -> Contact {
        Contact(
            id: id,
            encName: encName,
            encSharedKey: encSharedKey.map { ContactSharedKey(encKey: $0.encKey) },
            updatedAt: updatedAt,
            encSharingMode: encSharingMode,
            sharedConversationId: sharedConversationId,
            consultedAt: consultedAt,
            safeId: safeId,
            encResetConversationDate: encResetConversationDate
        )
    }
}

private extension ContactLocalKeyImport {
    func toAppModel() -> ContactLocalKey {
        ContactLocalKey(
            contactId: contactId,
            encKey: encKey
        )
    }
}

private extension SafeMessageImport {
    func toAppModel() -> SafeMessage {
        SafeMessage(
            id: id,
            fromContactId: fromContactId,
            encSentAt: encSentAt,
            encContent: encContent,
            direction: direction,
            encChannel: encChannel,
            isRead: isRead,
            order: order,
            encSafeItemId: encSafeItemId
        )
    }
}

private extension EncConversationImport {
    func toAppModel() -> EncConversation {
        EncConversation(
            id: id,
            encPersonalPublicKey: encPersonalPublicKey,
            encPersonalPrivateKey: encPersonalPrivateKey,
            encMessageNumber: encMessageNumber,
            encSequenceNumber: encSequenceNumber,
            encRootKey: encRootKey,
            encSendingChainKey: encSendingChainKey,
            encReceiveChainKey: encReceiveChainKey,
            encLastContactPublicKey: encLastContactPublicKey,
            encReceivedLastMessageNumber: encReceivedLastMessageNumber
        )
    }
}
