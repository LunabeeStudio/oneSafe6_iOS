//
//  UseCase+Crypto.swift
//  UseCases
//
//  Created by Lunabee Studio (Alexandre Cools) on 13/10/2022 - 2:18 PM.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Protocols
import Errors
import Model
import CoreCrypto
import LocalAuthentication

public extension UseCase {
    static func clearKeychainLeftoversIfNeeded() {
        if !LAContext.isBiometryAvailable {
            try? cryptoRepository.deleteBiometryMasterKeys()
        }
    }

    static func areCredentialsValid(_ password: String) throws -> Bool {
        updateShouldPreventAutoLock(true)
        defer { updateShouldPreventAutoLock(false) }
        let coreCrypto: CoreCrypto = .shared
        let masterSalt: Data = try cryptoRepository.getMasterSalt()
        let masterKey: Data = try coreCrypto.derive(password: password, salt: masterSalt)
        guard let cryptoToken = try cryptoRepository.cryptoToken() else { throw AppError.cryptoNoCryptoToken }
        let token: String = try coreCrypto.decryptToString(value: cryptoToken, key: masterKey)

        let result: Bool = UUID(uuidString: token) != nil
        if result {
            try? passwordVerificationRepository.updateLastPasswordEnterWithSuccessDate()
        }
        return result
    }

    /// Save the master keys in the keychain to use it for auto login later.
    /// Does nothing if the master keys are not loaded yet.
    static func persistMasterKeysBeforeAutoLock() throws {
        try CoreCrypto.shared.persistMasterKeys()
    }

    static func clearPersistedMasterKeys() throws {
        try CoreCrypto.shared.deletePersistedMasterKeys()
    }

    /// Stop the observation of the SafeItemRepository before unloading the databases and the master keys.
    /// Once done no item can be deciphered.
    static func logout() {
        messageRepository.stopObserving()
        contactRepository.stopObserving()
        databaseRepository.unloadDatabases()
        searchRepository.reset()
        CoreCrypto.shared.unload()
    }

    /// Try to login using the master keys persisted in the core crypto keychain.
    static func autoLogin() throws {
        let coreCrypto: CoreCrypto = .shared
        try databaseRepository.loadDatabases()
        try messageRepository.startObserving()
        try contactRepository.startObserving()

        do {
            try coreCrypto.loadPersistedMasterKeys()
            try? coreCrypto.deletePersistedMasterKeys()
        } catch {
            messageRepository.stopObserving()
            contactRepository.stopObserving()
            databaseRepository.unloadDatabases()
            throw error
        }
    }

    static func executeBeforeUnload(_ block: @escaping () async -> Void) {
        CoreCrypto.shared.executeBeforeUnload(block)
    }

    static func deleteBeforeUnloadBlock() {
        CoreCrypto.shared.deleteBeforeUnloadBlock()
    }

    static func changePassword(newPassword: String) throws {
        let coreCrypto: CoreCrypto = .shared

        let newMasterSalt: Data = coreCrypto.generateSalt()
        let newSearchIndexSalt: Data = coreCrypto.generateSalt()

        let newMasterKey: Data = try coreCrypto.derive(password: Data(newPassword.utf8), salt: newMasterSalt)
        let newSearchMasterKey: Data = try coreCrypto.derive(password: Data(newPassword.utf8), salt: newSearchIndexSalt)

        let safeItemKeys: [SafeItemKey] = try safeItemRepository.getAllKeys()
        let reencryptedSafeItemKeys: [SafeItemKey] = try safeItemKeys.map {
            let encryptedValue: Data = $0.value
            let value: Data = try coreCrypto.decrypt(value: encryptedValue)
            let reencryptedValue: Data = try coreCrypto.encrypt(value: value, key: newMasterKey)
            return .init(id: $0.id, value: reencryptedValue)
        }

        let indexEntries: [IndexWordEntry] = try searchRepository.getAllIndexWordEntries()
        let reencryptedIndexEntries: [IndexWordEntry] = try indexEntries.map {
            let encryptedValue: Data = $0.encWord
            let value: Data = try coreCrypto.decrypt(value: encryptedValue, scope: .searchIndex)
            let reencryptedValue: Data = try coreCrypto.encrypt(value: value, key: newSearchMasterKey)
            return .init(id: $0.id, encWord: reencryptedValue, match: $0.match)
        }

        let searchQueries: [SearchQuery] = try searchRepository.getAllSearchQueries()
        let reencryptedSearchQueries: [SearchQuery] = try searchQueries.map {
            let encryptedValue: Data = $0.encQuery
            let value: Data = try coreCrypto.decrypt(value: encryptedValue, scope: .searchIndex)
            let reencryptedValue: Data = try coreCrypto.encrypt(value: value, key: newSearchMasterKey)
            return .init(id: $0.id, encQuery: reencryptedValue, date: $0.date)
        }

        try cryptoRepository.saveMasterSalt(newMasterSalt)
        try cryptoRepository.saveSearchIndexSalt(newSearchIndexSalt)

        let token: String = UUID().uuidString
        let cryptoToken: Data = try coreCrypto.encrypt(value: token, key: newMasterKey)
        try cryptoRepository.save(cryptoToken: cryptoToken)

        if UseCase.isBiometryActivated() {
            try cryptoRepository.deleteBiometryMasterKeys()
            try cryptoRepository.save(masterKey: newMasterKey)
            try cryptoRepository.save(searchIndexMasterKey: newSearchMasterKey)
        }

        let encBubblesMasterKey: Data = try cryptoRepository.getEncBubblesMasterKey()
        // decrypt the bubbles master key using the global master which can only be accessed in core crypto
        let bubblesMasterKey: Data = try coreCrypto.decrypt(value: encBubblesMasterKey, scope: .main)
        // reencrypt the bubbles master key using the new master key
        let newEncBubblesMasterKey: Data = try coreCrypto.encrypt(value: bubblesMasterKey, key: newMasterKey)
        try cryptoRepository.save(encBubblesMasterKey: newEncBubblesMasterKey)

        try safeItemRepository.save(keys: reencryptedSafeItemKeys)
        try searchRepository.save(indexWordEntries: reencryptedIndexEntries)
        try searchRepository.save(searchQueries: reencryptedSearchQueries)

        coreCrypto.load(scope: .main(masterKey: newMasterKey))
        coreCrypto.load(scope: .searchIndex(masterKey: newSearchMasterKey))
    }
}

// MARK: - Data encryption/decryption -
public extension UseCase {
    static func getStringFromEncryptedData(data: Data?, key: SafeItemKey) throws -> String? {
        let coreCrypto: CoreCrypto = .shared

        guard let encData = data else { return nil }

        let key: Data = try coreCrypto.decrypt(value: key.value)

        let data: Data = try coreCrypto.decrypt(value: encData, key: key)
        return String(data: data, encoding: .utf8)
    }

    static func getDataFromEncryptedData(data: Data?, key: SafeItemKey) throws -> Data? {
        let coreCrypto: CoreCrypto = .shared

        guard let encData = data else { return nil }

        let key: Data = try coreCrypto.decrypt(value: key.value)

        return try coreCrypto.decrypt(value: encData, key: key)
    }

    static func getEncryptedDataFromString(value: String?, key: SafeItemKey) throws -> Data? {
        let coreCrypto: CoreCrypto = .shared

        guard let data = value?.data(using: .utf8) else { return nil }

        let key: Data = try coreCrypto.decrypt(value: key.value)

        return try coreCrypto.encrypt(value: data, key: key)
    }

    static func getEncryptedDataFromData(data: Data?, key: SafeItemKey) throws -> Data? {
        let coreCrypto: CoreCrypto = .shared

        guard let data = data else { return nil }

        let key: Data = try coreCrypto.decrypt(value: key.value)

        return try coreCrypto.encrypt(value: data, key: key)
    }

    static func getStringFromEncryptedData(data: Data?, scope: CoreCrypto.Scope) throws -> String? {
        let coreCrypto: CoreCrypto = .shared

        guard let encData = data else { return nil }

        let data: Data = try coreCrypto.decrypt(value: encData, scope: scope)
        return String(data: data, encoding: .utf8)
    }

    static func getEncryptedDataFromString(value: String?, scope: CoreCrypto.Scope) async throws -> Data? {
        let coreCrypto: CoreCrypto = .shared

        guard let data = value?.data(using: .utf8) else { return nil }

        return try coreCrypto.encrypt(value: data, scope: scope)
    }
}

// MARK: - Utils -
public extension UseCase {
    static func isSafeItemCorrupted(safeItem: SafeItem?, key: SafeItemKey?) -> Bool {
        guard let safeItem else { return true }
        guard let key else { return true }
        return (try? getStringFromEncryptedData(data: safeItem.encName, key: key)) == nil
    }
}
