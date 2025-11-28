//
//  SafeMessageRepository.swift
//  oneSafe
//
//  Created by Lunabee Studio (François Combe) on 19/08/2024 - 14:12.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Model
@preconcurrency import oneSafeKmp
import Combine

public protocol SafeMessageRepository: MessageLocalDataSource {
    func startObserving() throws
    func stopObserving()

    func getLastMessage(contactId: String) throws -> Model.SafeMessage?
    func getAllMessages() throws -> [Model.SafeMessage]
    func lastMessagePublisher(contactId: String) throws -> AnyPublisher<Model.SafeMessage?, Never>
    func messagesPublisher(contactId: String) throws -> AnyPublisher<[Model.SafeMessage], Never>

    func deleteAll() throws
}
