//
//  CoreCrypto.swift
//  CoreCrypto
//
//  Created by Lunabee Studio (Nicolas) on 10/02/2023 - 14:29.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Combine
import Model
import CryptoKit
import CommonCrypto
import LocalAuthentication
import Errors
@preconcurrency import oneSafeKmp

public final class CoreCrypto {
    public enum AuthenticatedData: Hashable {
        case none
        case data(_ data: Data)
        case string(_ string: String)
    }

    public enum Scope {
        case main
        case searchIndex
        case bubbles
    }

    public enum MasterKeyScope {
        case main(masterKey: Data)
        case searchIndex(masterKey: Data)
        case bubbles(masterKey: Data)
    }

    public static let shared: CoreCrypto = .init()

    public var isLoaded: CurrentValueSubject<Bool, Never> = .init(false)

    public let randomKeyProvider: RandomKeyProvider = .init()

    private let cryptoQueue: DispatchQueue = .init(label: "coreCrypto", qos: .userInitiated)
    private var masterKey: Data? {
        didSet { updateIsLoadedIfNecessary() }
    }
    private var searchIndexMasterKey: Data? {
        didSet { updateIsLoadedIfNecessary() }
    }
    private var bubblesMasterKey: Data? {
        didSet { updateIsLoadedIfNecessary() }
    }

    private var beforeUnload: (() async -> Void)?

    private init() {}

    public func load(scope: MasterKeyScope) {
        switch scope {
        case let .main(masterKey):
            self.masterKey = masterKey
        case let .searchIndex(masterKey):
            self.searchIndexMasterKey = masterKey
        case let .bubbles(masterKey):
            self.bubblesMasterKey = masterKey
        }
    }

    public func unload() {
        Task(priority: .userInitiated) {
            await beforeUnload?()
            masterKey?.cptWipeData()
            masterKey = nil
            searchIndexMasterKey?.cptWipeData()
            searchIndexMasterKey = nil
            bubblesMasterKey?.cptWipeData()
            bubblesMasterKey = nil
        }
    }

    public func areCredentialsValid(_ password: String, salt: Data) throws -> Bool {
        let derivedPassword: Data = try derive(password: password, salt: salt)
        let isChecked: Bool = cryptoQueue.sync {
            Thread.sleep(forTimeInterval: 0.1)
            return masterKey == derivedPassword
        }
        return isChecked
    }

    public func executeBeforeUnload(_ block: @escaping () async -> Void) {
        beforeUnload = block
    }

    public func deleteBeforeUnloadBlock() {
        beforeUnload = nil
    }
}

// MARK: - Key derivation -
extension CoreCrypto {
    public func derive(password: Data, salt: Data, length: CryptoKeyLength = .bits256) throws -> Data {
        guard let password = String(data: password, encoding: .utf8) else { throw AppError.cryptoWrongPasswordFormat }
        return try derive(password: password, salt: salt, length: length)
    }

    public func derive(password: String, salt: Data, length: CryptoKeyLength = .bits256) throws -> Data {
        try pbkdf2(password: password, salt: salt, keyByteCount: length.bytesCount, rounds: 120_000)
    }

    private func pbkdf2(password: String, salt: Data, keyByteCount: Int, rounds: Int) throws -> Data {
        let passwordData: Data = Data(password.utf8)

        var derivedKeyData: Data = .init(repeating: 0, count: keyByteCount)
        let derivedCount: Int = derivedKeyData.count

        let derivationStatus: OSStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            let derivedKeyRawBytes: UnsafeMutablePointer<UInt8>? = derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress
            return salt.withUnsafeBytes { saltBytes in
                let rawBytes: UnsafePointer<UInt8>? = saltBytes.bindMemory(to: UInt8.self).baseAddress
                return CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                                            password,
                                            passwordData.count,
                                            rawBytes,
                                            salt.count,
                                            CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512),
                                            UInt32(rounds),
                                            derivedKeyRawBytes,
                                            derivedCount)
            }
        }
        if derivationStatus == kCCSuccess {
            return derivedKeyData
        } else {
            throw AppError.cryptoKeyDerivationError
        }
    }
}

// MARK: - Utils -
extension CoreCrypto {
    public func generateKey() -> Data {
        // Keeping these 2 functions separated as they're not semantically linked.
        SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
    }

    public func generateSalt() -> Data {
        // Keeping these 2 functions separated as they're not semantically linked.
        SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
    }

    public func hash(data: Data) -> String {
        SHA512.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Encryption/decryption functions -
extension CoreCrypto {
    public func encrypt(value: String, key: Data? = nil, scope: Scope = .main) throws -> Data {
        try encrypt(value: Data(value.utf8), key: key, scope: scope)
    }

    public func encrypt(value: Data, key: Data? = nil, scope: Scope = .main) throws -> Data {
        guard let key = key ?? masterKey(scope: scope) else { throw AppError.cryptoNoKeyForEncryption }
        return try encrypt(data: value, key: SymmetricKey(data: key))
    }

    public func decryptToString(value: Data, key: Data? = nil, scope: Scope = .main) throws -> String {
        let decryptedData: Data = try decrypt(value: value, key: key, scope: scope)
        return String(decoding: decryptedData, as: UTF8.self)
    }

    public func decrypt(value: Data, key: Data? = nil, scope: Scope = .main) throws -> Data {
        guard let key = key ?? masterKey(scope: scope) else { throw AppError.cryptoNoKeyForDecryption }
        return try decrypt(data: value, key: SymmetricKey(data: key))
    }

    private func masterKey(scope: Scope) -> Data? {
        switch scope {
        case .main:
            return masterKey
        case .searchIndex:
            return searchIndexMasterKey
        case .bubbles:
            return bubblesMasterKey
        }
    }
}

// MARK: Bubbles
extension CoreCrypto: BubblesCryptoEngine {
    public func bubblesDecrypt(cipherData: KotlinByteArray, key: KotlinByteArray, associatedData: KotlinByteArray?) -> KotlinByteArray? {
        try? decrypt(data: cipherData.toNSData(), key: SymmetricKey(data: key.toNSData())).toByteArray()
    }

    public func bubblesEncrypt(plainData: KotlinByteArray, key: KotlinByteArray, associatedData: KotlinByteArray?) -> KotlinByteArray? {
        try? encrypt(data: plainData.toNSData(), key: SymmetricKey(data: key.toNSData())).toByteArray()
    }
}

extension CoreCrypto {
    public func convertPrivateSec1DerToPKCS8Der(_ data: Data) throws -> Data {
        let privateKey: SecKey = try SecKey.privateKeyfromDerData(data)
        return try privateKey.toPrivatePKCS8Der()
    }
}

extension CoreCrypto: BubblesDataHashEngine {
    public func deriveKey(key: KotlinByteArray, salt: KotlinByteArray, size: Int32) -> KotlinByteArray {
        let symmetricKey: SymmetricKey = HKDF<SHA512>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: key.toNSData()),
            salt: salt.toNSData(),
            outputByteCount: Int(size)
        )
        return symmetricKey.withUnsafeBytes { Data($0) }.toByteArray()
    }
}

extension CoreCrypto: BubblesKeyExchangeEngine {
    public func createSharedSecret(publicKey: KotlinByteArray, privateKey: KotlinByteArray, size: Int32) -> KotlinByteArray {
        do {
            let publicSecKey: SecKey = try SecKey.publicKeyfromDerData(publicKey.toNSData())
            let privateSecKey: SecKey = try SecKey.privateKeyfromDerData(privateKey.toNSData())
            let parameters: [String: Any] = [
                SecKeyKeyExchangeParameter.requestedSize.rawValue as String: size
            ]

            var error: Unmanaged<CFError>?
            guard let sharedSecretData = SecKeyCopyKeyExchangeResult(privateSecKey, .ecdhKeyExchangeStandard, publicSecKey, parameters as CFDictionary, &error) as Data? else {
                fatalError("Couldn't get shared secret data")
            }
            return sharedSecretData.toByteArray()

        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public func generateKeyPair() -> BubblesKeyPair {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            fatalError("Couldn't create random private key")
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            fatalError("Couldn't create public key from private key")
        }

        do {
            return BubblesKeyPair(
                publicKey: try publicKey.toDer().toByteArray(),
                privateKey: try privateKey.toPrivateDer().toByteArray()
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

// MARK: - Low level cryptographic functions -
extension CoreCrypto {
    private func encrypt(string: String, key: SymmetricKey) throws -> String {
        guard let data = string.data(using: .utf8) else { throw AppError.cryptoBadUTF8String }
        return try encrypt(data: data, key: key).base64EncodedString()
    }

    private func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        try ChaChaPoly.seal(data, using: key).combined
    }

    private func decrypt(string: String, key: SymmetricKey) throws -> String {
        guard let data = Data(base64Encoded: string) else { throw AppError.cryptoBadUTF8String }
        let decryptedData: Data = try decrypt(data: data, key: key)
        return decryptedData.string(using: .utf8).orEmpty
    }

    private func decrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox: ChaChaPoly.SealedBox = try .init(combined: data)
        return try ChaChaPoly.open(sealedBox, using: key)
    }
}

// MARK: - AutoLock Keychain
public extension CoreCrypto {
    func persistMasterKeys() throws {
        guard let masterKey, let searchIndexMasterKey, let bubblesMasterKey else { throw AppError.cryptoNoMasterKeyLoaded }
        try saveInKeychain(data: masterKey, key: .autoLoginMasterKey)
        try saveInKeychain(data: searchIndexMasterKey, key: .autoLoginSearchIndexMasterKey)
        try saveInKeychain(data: bubblesMasterKey, key: .autoLoginBubblesMasterKey)
    }

    func deletePersistedMasterKeys() throws {
        try deleteAllDataInKeychain()
    }

    func loadPersistedMasterKeys() throws {
        masterKey = try getFromKeychain(key: .autoLoginMasterKey)
        searchIndexMasterKey = try getFromKeychain(key: .autoLoginSearchIndexMasterKey)
        bubblesMasterKey = try getFromKeychain(key: .autoLoginBubblesMasterKey)
    }
}

// MARK: - Utils
extension CoreCrypto {
    private func updateIsLoadedIfNecessary() {
        let currentValue: Bool = isLoaded.value
        let newValue: Bool = searchIndexMasterKey != nil && masterKey != nil && bubblesMasterKey != nil
        guard currentValue != newValue else { return }
        isLoaded.send(newValue)
    }

    private func saveInKeychain(data: Data, key: KeychainKey) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key.rawValue,
                                    kSecAttrService as String: Bundle.currentBundleIdentifier,
                                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    kSecValueData as String: data]

        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw AppError.cryptoAutoLoginMasterKeySaveError }
    }

    func getFromKeychain(key: KeychainKey) throws -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key.rawValue,
                                    kSecAttrService as String: Bundle.currentBundleIdentifier,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: true]

        var result: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw AppError.cryptoNoAutoLoginMasterKey }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw AppError.cryptoUnknown(userInfo: "KeychainManager getFromKeychain SecItemCopyMatching returned OSStatus \(status)")
        }
    }

    func deleteAllDataInKeychain() throws {
        let query: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                   kSecAttrService as String: Bundle.currentBundleIdentifier]
        let status: OSStatus = SecItemDelete(query)
        guard status == errSecSuccess else { throw AppError.cryptoAutoLoginMasterKeyDeletionError }
    }
}
