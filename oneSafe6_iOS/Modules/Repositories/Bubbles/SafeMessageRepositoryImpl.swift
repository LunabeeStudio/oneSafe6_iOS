//
//  SafeMessageRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 17:49.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import oneSafeKmp
import Storage
import RealmSwift
import Combine
import Errors
import Protocols

final class SafeMessageRepositoryImpl: SafeMessageRepository {
    private let database: RealmManager = .shared

    @Published private var safeMessages: [Model.SafeMessage] = []
    private var cancellables: Set<AnyCancellable> = []

    func startObserving() throws {
        try database
            .publisher(objectsOfType: SafeMessage.self, sortingKeyPath: SafeMessagesSortingOption.order.safeMessageIndexValueName)
            .sink { [weak self] messages in
                self?.safeMessages = messages
            }
            .store(in: &cancellables)
    }

    func stopObserving() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }

    func __countByContact(contactId: DoubleratchetDoubleRatchetUUID, exceptIds: [DoubleratchetDoubleRatchetUUID]) async throws -> KotlinInt {
        let count: Int = try database.getAll(objectOfType: SafeMessage.self, withFilter: { message in
            message.fromContactId == contactId.uuidString() &&
            !message.id.in(exceptIds.map { $0.uuidString() })
        }).count
        return KotlinInt(int: Int32(count))
    }

    func __deleteAllMessages(contactId: DoubleratchetDoubleRatchetUUID) async throws {
        try database.deleteAll(objectsOfType: SafeMessage.self, withFilter: { message in
            message.fromContactId == contactId.uuidString()
        })
    }

    func __deleteMessage(messageId: DoubleratchetDoubleRatchetUUID) async throws {
        try database.delete(objectOfType: SafeMessage.self, id: messageId.uuidString())
    }

    func __getAllByContact(contactId: DoubleratchetDoubleRatchetUUID) async throws -> [oneSafeKmp.SafeMessage] {
        try database.getAll(objectOfType: SafeMessage.self, withFilter: { message in
            message.fromContactId == contactId.uuidString()
        }, sortingKeyPath: SafeMessagesSortingOption.order.safeMessageIndexValueName, ascending: false).map { $0.toKMPSafeMessageModel() }
    }

    func __getAtByContact(position: Int32, contactId: DoubleratchetDoubleRatchetUUID, exceptIds: [DoubleratchetDoubleRatchetUUID]) async throws -> oneSafeKmp.MessageOrder? {
        let allMessages: [Model.SafeMessage] = try database.getAll(withFilter: { message in
            message.fromContactId == contactId.uuidString() &&
            !message.id.in(exceptIds.map { $0.uuidString() })
        }, sortingKeyPath: SafeMessagesSortingOption.order.safeMessageIndexValueName, ascending: false)

        guard allMessages.count >= position else { return nil }

        let message: Model.SafeMessage = allMessages[Int(position)]

        return message.toKMPMessageOrderModel()
    }

    func __getByContactByOrder(contactId: DoubleratchetDoubleRatchetUUID, order: Float) async throws -> oneSafeKmp.SafeMessage {
        guard let contact = try database.getFirst(SafeMessage.self, where: { message in
            message.fromContactId == contactId.uuidString() && message.order == order
        }) else {
            throw AppError.noObjectMatchingConditions
        }

        return contact.toKMPSafeMessageModel()
    }

    func __getFirstByContact(contactId: DoubleratchetDoubleRatchetUUID, exceptIds: [DoubleratchetDoubleRatchetUUID]) async throws -> oneSafeKmp.MessageOrder? {
        let allMessages: [Model.SafeMessage] = try database.getAll(withFilter: { message in
            message.fromContactId == contactId.uuidString() &&
            !message.id.in(exceptIds.map { $0.uuidString() })
        }, sortingKeyPath: SafeMessagesSortingOption.order.safeMessageIndexValueName)

        guard let message = allMessages.first else { return nil }

        return message.toKMPMessageOrderModel()
    }

    func __getLastByContact(contactId: DoubleratchetDoubleRatchetUUID, exceptIds: [DoubleratchetDoubleRatchetUUID]) async throws -> oneSafeKmp.MessageOrder? {
        let allMessages: [Model.SafeMessage] = try database.getAll(withFilter: { message in
            message.fromContactId == contactId.uuidString() &&
            !message.id.in(exceptIds.map { $0.uuidString() })
        }, sortingKeyPath: SafeMessagesSortingOption.order.safeMessageIndexValueName, ascending: false)

        guard let message = allMessages.first else { return nil }

        return message.toKMPMessageOrderModel()
    }

    func __getLastMessage(contactId: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.SkieSwiftOptionalFlow<oneSafeKmp.SafeMessage> {
        fatalError("Never used by KMP. We will be using lastMessagePublisher because publisher is more convenient and the compiler has trouble with SkieSwiftOptionalFlow in other modules.")
    }

    func getLastMessage(contactId: String) throws -> Model.SafeMessage? {
        try database.getAll(objectOfType: SafeMessage.self, withFilter: { message  in
            message.fromContactId == contactId
        }, sortingKeyPath: SafeMessagesSortingOption.order.safeMessageIndexValueName)
        .last
    }

    func getAllMessages() throws -> [Model.SafeMessage] {
        try database.getAll()
    }

    func lastMessagePublisher(contactId: String) throws -> AnyPublisher<Model.SafeMessage?, Never> {
        $safeMessages
            .map { messages in
                messages
                    .filter { $0.fromContactId == contactId }
                    .max(by: { lhs, rhs in
                        lhs.order < rhs.order
                    })
            }
            .eraseToAnyPublisher()
    }

    func __markMessagesAsRead(contactId: DoubleratchetDoubleRatchetUUID) async throws {
        try database.update(objectsOfType: SafeMessage.self, value: true, forKey: "isRead", filter: { message in
            message.fromContactId == contactId.uuidString()
        })
    }

    func __save(message: oneSafeKmp.SafeMessage, order: Float) async throws {
        let newMessage: Model.SafeMessage = .from(kmpModel: message, order: order)
        try database.save(newMessage)
    }

    func messagesPublisher(contactId: String) throws -> AnyPublisher<[Model.SafeMessage], Never> {
        $safeMessages
            .map { messages in
                messages.filter { $0.fromContactId == contactId }
            }
            .eraseToAnyPublisher()
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: Model.SafeMessage.self)
    }
}
