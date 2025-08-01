//
//  ContactRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 19/07/2024 - 15:37.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import oneSafeKmp
import Storage
import Combine
import Protocols
import RealmSwift

final class ContactRepositoryImpl: Protocols.ContactRepository {

    @Published private var contacts: [Model.Contact] = []

    private let database: RealmManager = .shared
    private var databaseContactsCancellable: AnyCancellable?
    private var kmpCancellables: Set<AnyCancellable> = []

    func startObserving() throws {
        databaseContactsCancellable = try database
            .publisher(objectsOfType: Contact.self)
            .sink { [weak self] contacts in
                self?.contacts = contacts
            }

    }

    func stopObserving() {
        databaseContactsCancellable?.cancel()
        databaseContactsCancellable = nil
    }

    func hasContact() throws -> Bool {
        try database.doesContain(objectOfType: Contact.self)
    }

    func observeHasContact() throws -> AnyPublisher<Bool, Never> {
        try database.countPublisher(objectsOfType: Contact.self)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }

    func __addContactSharedKey(id: DoubleratchetDoubleRatchetUUID, sharedKey: oneSafeKmp.ContactSharedKey) async throws {
        guard var contact = try database.get(Model.Contact.self, id: id.uuidString()) else { return }
        contact.encSharedKey = ContactSharedKey(encKey: sharedKey.encKey.toNSData())
        try database.save(contact)
    }

    func __deleteContact(id: DoubleratchetDoubleRatchetUUID) async throws {
        try database.delete(objectOfType: Contact.self, id: id.uuidString())
        try database.deleteAll(objectsOfType: ContactLocalKey.self) { $0.contactId.equals(id.uuidString()) }
    }

    func safeGetAllContacts() throws -> [oneSafeKmp.Contact] {
        let contacts: [Model.Contact] = try database.getAll()
        return contacts.map { $0.toKMPModel() }
    }

    func getAllContacts() -> [oneSafeKmp.Contact] {
        contacts.map { $0.toKMPModel() }
    }

    func getAllContactsFlow(safeId: DoubleratchetDoubleRatchetUUID) -> oneSafeKmp.SkieSwiftFlow<[oneSafeKmp.Contact]> {
        let wrapper: FlowListWrapper<oneSafeKmp.Contact> = .init()

        $contacts
            .sink { contacts in
                wrapper.emit(value: contacts.map { $0.toKMPModel() })
            }
            .store(in: &kmpCancellables)

        return wrapper.flow()
    }

    func __getContact(id: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.Contact? {
        let contact: Model.Contact? = try database.get(id: id.uuidString())
        return contact?.toKMPModel()
    }

    func __getContactInSafe(id: DoubleratchetDoubleRatchetUUID, safeId: DoubleratchetDoubleRatchetUUID)async throws -> oneSafeKmp.Contact? {
        let contact: Model.Contact? = try database.get(id: id.uuidString())
        return contact?.toKMPModel()
    }

    func getContactFlow(id: DoubleratchetDoubleRatchetUUID) -> oneSafeKmp.SkieSwiftOptionalFlow<oneSafeKmp.Contact> {
        let wrapper: FlowNullableWrapper<oneSafeKmp.Contact> = .init()
        $contacts
            .map { contacts in
                contacts.first(where: { $0.id == id.uuidString() })
            }
            .sink { contact in
                wrapper.emit(value: contact?.toKMPModel())
            }
            .store(in: &kmpCancellables)

        return wrapper.flow()
    }

    func getContactCountFlow(safeId: DoubleratchetDoubleRatchetUUID) -> SkieSwiftFlow<KotlinInt> {
        let wrapper: FlowWrapper<KotlinInt> = .init()
        $contacts
            .sink { wrapper.emit(value: KotlinInt(int: Int32($0.count))) }
            .store(in: &kmpCancellables)
        return wrapper.flow()
    }

    func __getContactSharedKey(id: DoubleratchetDoubleRatchetUUID) async throws -> oneSafeKmp.ContactSharedKey? {
        let contact: Model.Contact? = try database.get(id.uuidString())
        return contact?.encSharedKey?.toKMPModel()
    }

    // Ignoring safeId until multisafe is supported
    func getRecentContactsFlow(maxNumber: Int32, safeId: DoubleratchetDoubleRatchetUUID) -> oneSafeKmp.SkieSwiftFlow<[oneSafeKmp.Contact]> {
        let wrapper: FlowListWrapper<oneSafeKmp.Contact> = .init()
        $contacts
            .map { contacts in
                contacts.max(count: Int(maxNumber), sortedBy: { lhs, rhs in
                    lhs.updatedAt < rhs.updatedAt
                })
            }
            .sink { contacts in
                wrapper.emit(value: contacts.map { $0.toKMPModel() })
            }
            .store(in: &kmpCancellables)
        return wrapper.flow()
    }

    func __saveContact(contact: oneSafeKmp.Contact, key: oneSafeKmp.ContactLocalKey) async throws {
        let newContact: Model.Contact = .from(kmpModel: contact)
        let newContactKey: Model.ContactLocalKey = .from(kmpModel: key, contactId: contact.id)
        try database.save(newContact)
        try database.save(newContactKey)
    }

    func __updateContact(id: DoubleratchetDoubleRatchetUUID, encSharingMode: KotlinByteArray, encName: KotlinByteArray, updateAt: KotlinInstant) async throws {
        var contact: Model.Contact? = try database.get(id.uuidString())
        contact?.encSharingMode = encSharingMode.toNSData()
        contact?.encName = encName.toNSData()
        contact?.updatedAt = updateAt.toDate()
        try database.save(contact)
    }

    func __updateContactConsultedAt(id: DoubleratchetDoubleRatchetUUID, consultedAt: KotlinInstant) async throws {
        var contact: Model.Contact? = try database.get(id.uuidString())
        contact?.consultedAt = consultedAt.toDate()
        try database.save(contact)
    }

    func __updateMessageSharingMode(id: DoubleratchetDoubleRatchetUUID, encSharingMode: KotlinByteArray, updateAt: KotlinInstant) async throws {
        var contact: Model.Contact? = try database.get(id.uuidString())
        contact?.encSharingMode = encSharingMode.toNSData()
        contact?.updatedAt = updateAt.toDate()
        try database.save(contact)
    }

    func __updateUpdatedAt(id: DoubleratchetDoubleRatchetUUID, updateAt: KotlinInstant) async throws {
        var contact: Model.Contact? = try database.get(id.uuidString())
        contact?.updatedAt = updateAt.toDate()
        try database.save(contact)
    }

    func __getContactCount(safeId: DoubleratchetDoubleRatchetUUID) async throws -> KotlinInt {
        let count: Int = try database.getAll(objectOfType: Contact.self, withFilter: { $0.safeId == safeId.uuidString() }).count
        return KotlinInt(int: Int32(count))
     }

    func __updateContactResetConversationDate(id: DoubleratchetDoubleRatchetUUID, encResetConversationDate: KotlinByteArray) async throws {
        var contact: Model.Contact? = try database.get(id.uuidString())
        contact?.encResetConversationDate = encResetConversationDate.toNSData()
        try database.save(contact)
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: Model.Contact.self)
    }
}
