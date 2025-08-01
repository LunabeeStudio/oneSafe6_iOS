//
//  BubblesEnvironment.swift
//  oneSafe
//
//  Created by Lunabee Studio (François Combe) on 27/06/2024 - 16:43.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import SwiftUI
import oneSafeKmp
import Model
import Assets
import UseCases
import Combine

@MainActor
final class BubblesEnvironment: ObservableObject {
    @Published var contacts: [UIContact] = []
    @Published var conversations: [UIConversationInfo] = []

    // This is used to display a placeholder when conversations is empty due to clearing memory on lock.
    // This could be improved in the future by using ObservableObject for each contacts / conversation (same as SafeItemGridView and ItemHeaderEnvironment)
    @Published var hasConversations: Bool = false

    let itemsHeadersCache: ItemsHeadersCache = .init()

    private let getAllContactUseCase: GetAllContactsUseCase = BubblesUseCases().getAllContactsUseCase

    private var lastMessageCancellables: Set<AnyCancellable> = []
    private var contactsCancellable: AnyCancellable?
    private var observeContactsTask: Task<Void, Never>?
    private var applicationStateCancellable: AnyCancellable?

    init() {
        startObservers()
        observeApplicationState()

        Task {
            contacts = try await UseCase.getAllContacts().asyncMap { try await UIContact.from(contact: $0) }
        }
    }

    private func startObservers() {
        observeContacts()
    }

    private func stopObservers() {
        contactsCancellable?.cancel()
        contactsCancellable = nil
        lastMessageCancellables.forEach { $0.cancel() }
        lastMessageCancellables.removeAll()
        observeContactsTask?.cancel()
        observeContactsTask = nil
    }

    private func observeContacts() {
        contactsCancellable = $contacts
            .sink { [weak self] contacts in
                guard let self else { return }
                lastMessageCancellables.removeAll()
                self.conversations.removeAll()
                contacts.forEach { contact in
                    try? UseCase.lastMessagePublisher(contactId: contact.id)
                        .combineLatest(UseCase.observeIsAppAuthenticated())
                        .asyncMap { message, isAuthenticated in
                            guard isAuthenticated else { return nil }
                            return try? await UIConversationInfo.from(contact: contact, lastMessage: message)
                        }
                        .receive(on: RunLoop.main)
                        .sink { [weak self] (conversation: UIConversationInfo?) in
                            guard let conversation else { return }
                            self?.conversations.removeAll(where: { $0.contactId == contact.id })
                            self?.conversations.append(conversation)
                        }
                        .store(in: &self.lastMessageCancellables)
                }
            }

        observeContactsTask = Task {
            await collectContacts()
        }
    }

    private func collectContacts() async {
        for await contacts in getAllContactUseCase.invoke() {
            do {
                self.contacts = try await contacts.asyncMap { try await UIContact.from(contact: $0) }
                self.hasConversations = !contacts.isEmpty
            } catch {
                continue
            }
        }
    }

    private func observeApplicationState() {
        applicationStateCancellable = UseCase.observeIsAppAuthenticated()
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.startObservers()
                } else {
                    self?.stopObservers()
                    self?.clearMemory()
                }
            }
    }

    private func clearMemory() {
        contacts = []
        conversations = []
    }
}
