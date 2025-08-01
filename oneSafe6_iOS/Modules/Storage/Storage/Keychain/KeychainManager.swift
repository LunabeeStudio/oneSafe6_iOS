//
//  KeychainManager.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import KeychainAccess
import LocalAuthentication
import Errors
import Model
import Combine

public final class KeychainManager {
    public static let shared: KeychainManager = .init()
    private let keychain: Keychain = Keychain(service: Constant.Keychain.service, accessGroup: Constant.Keychain.accessGroup)
        .accessibility(.whenUnlocked)

    private init() {}

    public func deleteAll() throws {
        try keychain.removeAll()
    }

    public func getString(key: KeychainKey) -> String? {
        try? keychain.getString(key.rawValue)
    }

    public func getData(key: KeychainKey) -> Data? {
        try? keychain.getData(key.rawValue)
    }

    public func delete(key: KeychainKey) {
        try? keychain.remove(key.rawValue)
    }

    public func isObsoleteKeyStillExisting() -> Bool {
        var oldKeyRemains: Bool = false
        KeychainKey.obsoleteStringKeys.forEach { key in
            guard KeychainManager.shared.getString(key: key) != nil else { return }
            oldKeyRemains = true
        }
        KeychainKey.obsoleteDataKeys.forEach { key in
            guard KeychainManager.shared.getData(key: key) != nil else { return }
            oldKeyRemains = true
        }
        return oldKeyRemains
    }
}

// MARK: - MasterKey (only with biometry) -
public extension KeychainManager {
    func masterKey(context: LAContext? = nil) throws -> Data {
        guard let key = try getData(key: .masterKey, context: context) else { throw AppError.cryptoNoBiometryMasterKey }
        return key
    }

    func searchIndexMasterKey(context: LAContext? = nil) throws -> Data {
        guard let key = try getData(key: .searchIndexMasterKey, context: context) else { throw AppError.cryptoNoBiometryMasterKey }
        return key
    }

    func bubblesMasterKey() throws -> Data {
        guard let key = try getData(key: .bubblesMasterKey) else { throw AppError.cryptoNoBubblesMasterKey }
        return key
    }

    func save(masterKey: Data) throws {
        try save(data: masterKey, key: .masterKey, confirmUserPresence: true)
    }

    func save(searchIndexMasterKey: Data) throws {
        try save(data: searchIndexMasterKey, key: .searchIndexMasterKey, confirmUserPresence: true)
    }

    func save(bubblesMasterKey: Data) throws {
        try save(data: bubblesMasterKey, key: .bubblesMasterKey, confirmUserPresence: false)
    }

    func deleteBubblesMasterKey() throws {
        try keychain.remove(KeychainKey.bubblesMasterKey.rawValue)
    }

    func deleteBiometryMasterKeys() throws {
        try keychain.remove(KeychainKey.masterKey.rawValue)
        try keychain.remove(KeychainKey.searchIndexMasterKey.rawValue)
    }

    func isBiometryActivated() -> Bool {
        let context: LAContext = .init()
        context.interactionNotAllowed = true
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: KeychainKey.masterKey.rawValue,
                                    kSecAttrService as String: Constant.Keychain.service,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecReturnData as String: true]
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }
}

private extension KeychainManager {
    func save(data: Data, key: KeychainKey, confirmUserPresence: Bool) throws {
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key.rawValue,
                                    kSecAttrService as String: Constant.Keychain.service,
                                    kSecValueData as String: data]

        if confirmUserPresence {
            let access: SecAccessControl? = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, .userPresence, nil)
            query[kSecAttrAccessControl as String] = access as Any
        }

        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw AppError.cryptoBiometryMasterKeySaveError }
    }

    func getData(key: KeychainKey, context: LAContext? = nil) throws -> Data? {
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key.rawValue,
                                    kSecAttrService as String: Constant.Keychain.service,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: true]
        if let context {
            query[kSecUseAuthenticationContext as String] = context
        }
        var result: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw AppError.cryptoNoBiometryMasterKey }
            return data
        case errSecItemNotFound:
            return nil
        default:
            switch status {
            case -128, -25293:
                throw AppError.cryptoBiometryCancelled
            default:
                throw AppError.cryptoUnknown(userInfo: "KeychainManager getData SecItemCopyMatching returned OSStatus \(status)")
            }
        }
    }
}
