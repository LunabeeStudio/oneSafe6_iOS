//
//  UseCase+Authentication.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 10/02/2023 - 15:56.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Combine
import Errors
import CoreCrypto
import LocalAuthentication

public extension UseCase {
    static func isAppAuthenticated() -> Bool {
        CoreCrypto.shared.isLoaded.value
    }

    static func observeIsAppAuthenticated() -> AnyPublisher<Bool, Never> {
        CoreCrypto.shared.isLoaded.eraseToAnyPublisher()
    }

    static func authenticate(password: String) throws {
        let coreCrypto: CoreCrypto = .shared
        let masterSalt: Data = try cryptoRepository.getMasterSalt()
        let masterKey: Data = try coreCrypto.derive(password: password, salt: masterSalt)

        guard try areCredentialsValid(password) else { throw AppError.cryptoWrongPassword }

        let searchIndexSalt: Data = try cryptoRepository.getSearchIndexSalt()
        let searchIndexMasterKey: Data = try coreCrypto.derive(password: password, salt: searchIndexSalt)

        let bubblesMasterKey: Data = try retrieveBubblesMasterKey(masterKey: masterKey)

        try finishAuthentication(masterKey: masterKey, searchIndexMasterKey: searchIndexMasterKey, bubblesMasterKey: bubblesMasterKey)
    }

    static func authenticateWithBiometry(prompt: String) async throws {
        let coreCrypto: CoreCrypto = .shared
        updateShouldPreventAutoLock(true)
        defer { updateShouldPreventAutoLock(false) }
        let context: LAContext = .init()
        context.localizedReason = prompt

        let masterKey: Data = try cryptoRepository.getMasterKey(context: context)
        let searchIndexMasterKey: Data = try cryptoRepository.getSearchIndexMasterKey(context: context)
        let bubblesMasterKey: Data = try retrieveBubblesMasterKey(masterKey: masterKey)

        try finishAuthentication(masterKey: masterKey, searchIndexMasterKey: searchIndexMasterKey, bubblesMasterKey: bubblesMasterKey)
    }

    static func setupAuthentication(password: String, activateBiometry: Bool) async throws {
        let coreCrypto: CoreCrypto = .shared

        let masterSalt: Data = coreCrypto.generateSalt()
        let searchIndexSalt: Data = coreCrypto.generateSalt()

        try cryptoRepository.saveMasterSalt(masterSalt)
        try cryptoRepository.saveSearchIndexSalt(searchIndexSalt)

        let masterKey: Data = try coreCrypto.derive(password: password, salt: masterSalt)
        let searchIndexMasterKey: Data = try coreCrypto.derive(password: password, salt: searchIndexSalt)

        let token: String = UUID().uuidString
        let cryptoToken: Data = try coreCrypto.encrypt(value: token, key: masterKey)
        try cryptoRepository.save(cryptoToken: cryptoToken)

        if activateBiometry {
            try cryptoRepository.save(masterKey: masterKey)
            try cryptoRepository.save(searchIndexMasterKey: searchIndexMasterKey)
        }

        let bubblesMasterKey: Data = try retrieveBubblesMasterKey(masterKey: masterKey)

        try databaseRepository.loadDatabases()
        coreCrypto.load(scope: .main(masterKey: masterKey))
        coreCrypto.load(scope: .searchIndex(masterKey: searchIndexMasterKey))
        coreCrypto.load(scope: .bubbles(masterKey: bubblesMasterKey))
    }

    private static func finishAuthentication(masterKey: Data, searchIndexMasterKey: Data, bubblesMasterKey: Data) throws {
        let coreCrypto: CoreCrypto = .shared

        try databaseRepository.loadDatabases()
        try messageRepository.startObserving()
        try contactRepository.startObserving()

        coreCrypto.load(scope: .main(masterKey: masterKey))
        coreCrypto.load(scope: .searchIndex(masterKey: searchIndexMasterKey))
        coreCrypto.load(scope: .bubbles(masterKey: bubblesMasterKey))

        if !Bundle.isAutoFillCredentialsProvider {
            Task {
                try? await migrateMessagesOrderIfNeeded()
            }
        }
    }

    private static func retrieveBubblesMasterKey(masterKey: Data) throws -> Data {
        let coreCrypto: CoreCrypto = .shared
        do {
            let encBubblesMasterKey: Data = try cryptoRepository.getEncBubblesMasterKey()
            return try coreCrypto.decrypt(value: encBubblesMasterKey, key: masterKey)

        } catch AppError.cryptoNoBubblesMasterKey {
            let bubblesMasterKey: Data = coreCrypto.randomKeyProvider.generateKey(size: Constant.keySize)
            // Use the master key instead of using the scope because at this moment the core crypto is not loaded.
            let encBubblesMasterKey: Data = try coreCrypto.encrypt(value: bubblesMasterKey, key: masterKey)
            try cryptoRepository.save(encBubblesMasterKey: encBubblesMasterKey)
            return bubblesMasterKey

        } catch {
            throw error
        }
    }
}

private extension Constant {
    static let keySize: Int32 = 32
}
