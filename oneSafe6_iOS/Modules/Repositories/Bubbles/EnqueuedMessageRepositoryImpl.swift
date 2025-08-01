//
//  EnqueuedMessageRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 14:37.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp
import Storage
import Model
import Combine

final class EnqueuedMessageRepositoryImpl: EnqueuedMessageLocalDataSource {
    private let database: RealmManager = .shared
    private var oldestMessageFlowWrapper: FlowWrapper<oneSafeKmp.EnqueuedMessage> = .init()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        try? database.publisher(objectsOfType: Model.EnqueuedMessage.self)
            .sink { [weak self] messages in
                guard let self else { return }
                if let oldestMessage = messages.max(by: { lhs, rhs in
                    lhs.id < rhs.id
                }) {
                    oldestMessageFlowWrapper.emit(value: oldestMessage.toKMPModel())
                }
            }
            .store(in: &cancellables)
    }

    func __delete(id: Int32) async throws {
        try database.delete(objectOfType: EnqueuedMessage.self, id: id)
    }

    func __deleteAll() async throws {
        try database.deleteAll(objectsOfType: EnqueuedMessage.self)
    }

    func __getAll() async throws -> [oneSafeKmp.EnqueuedMessage] {
        let messages: [Model.EnqueuedMessage] = try database.getAll()
        return messages.map { $0.toKMPModel() }
    }

    func __getOldestAsFlow() async throws -> oneSafeKmp.SkieSwiftOptionalFlow<oneSafeKmp.EnqueuedMessage> {
        .init(oldestMessageFlowWrapper.flow())
    }

    func __save(encMessage: KotlinByteArray, encChannel: KotlinByteArray?) async throws {
        let newMessage: Model.EnqueuedMessage = .init(
            id: try database.getLastID(objectOfType: EnqueuedMessage.self) ?? -1 + 1,
            encIncomingMessage: encMessage.toNSData(),
            encChannel: encChannel?.toNSData()
        )
        try database.save(newMessage)
    }

}
