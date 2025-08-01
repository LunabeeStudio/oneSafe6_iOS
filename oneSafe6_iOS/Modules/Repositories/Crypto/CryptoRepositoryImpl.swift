//
//  CryptoRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Nicolas) on 05/12/2022 - 14:58.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Protocols
import CryptoKit
import Errors
import Storage
import CommonCrypto
import LocalAuthentication
import Combine

final class CryptoRepositoryImpl: CryptoRepository {
    private var isBiometryActivatedPublisher: CurrentValueSubject<Bool, Never> = .init(KeychainManager.shared.isBiometryActivated())

    func getMasterSalt() throws -> Data {
        guard let salt = try FileDirectoryManager.shared.masterSalt() else {
            throw AppError.cryptoNoMasterSalt
        }
        return salt
    }

    func getSearchIndexSalt() throws -> Data {
        guard let salt = try FileDirectoryManager.shared.searchIndexSalt() else {
            throw AppError.cryptoNoSearchIndexSalt
        }
        return salt
    }

    func saveMasterSalt(_ salt: Data) throws {
        try FileDirectoryManager.shared.save(masterSalt: salt)
    }

    func saveSearchIndexSalt(_ salt: Data) throws {
        try FileDirectoryManager.shared.save(searchIndexSalt: salt)
    }
}

// MARK: - Crypto token -
extension CryptoRepositoryImpl {
    func cryptoToken() throws -> Data? {
        try FileDirectoryManager.shared.cryptoToken()
    }

    func save(cryptoToken: Data) throws {
        try FileDirectoryManager.shared.save(cryptoToken: cryptoToken)
    }
}

// MARK: - Biometry -
extension CryptoRepositoryImpl {
    func isBiometryActivated() -> Bool {
        KeychainManager.shared.isBiometryActivated()
    }

    func observeIsBiometryActivated() -> CurrentValueSubject<Bool, Never> {
        isBiometryActivatedPublisher
    }

    func getMasterKey(context: LAContext) throws -> Data {
        try KeychainManager.shared.masterKey(context: context)
    }

    func getSearchIndexMasterKey(context: LAContext) throws -> Data {
        try KeychainManager.shared.searchIndexMasterKey(context: context)
    }

    func getEncBubblesMasterKey() throws -> Data {
        try KeychainManager.shared.bubblesMasterKey()
    }

    func save(masterKey: Data) throws {
        try KeychainManager.shared.save(masterKey: masterKey)
        isBiometryActivatedPublisher.value = KeychainManager.shared.isBiometryActivated()
    }

    func save(searchIndexMasterKey: Data) throws {
        try KeychainManager.shared.save(searchIndexMasterKey: searchIndexMasterKey)
    }

    func save(encBubblesMasterKey: Data) throws {
        try KeychainManager.shared.deleteBubblesMasterKey() // Need to delete before saving to avoid errSecDuplicateItem error.
        try KeychainManager.shared.save(bubblesMasterKey: encBubblesMasterKey)
    }

    func deleteBiometryMasterKeys() throws {
        try KeychainManager.shared.deleteBiometryMasterKeys()
        isBiometryActivatedPublisher.value = KeychainManager.shared.isBiometryActivated()
    }
}
