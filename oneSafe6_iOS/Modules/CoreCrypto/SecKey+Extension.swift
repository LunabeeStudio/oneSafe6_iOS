//
//  SecKey+Extension.swift
//  CoreCrypto
//
//  Created by Lunabee Studio (François Combe) on 26/07/2024 - 10:30.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import CryptoKit

internal extension SecKey {
    // 150 bytes
    static let derHeaderData: Data = Data([0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00])
    static let privateDerHeaderData: Data = Data([0x30, 0x81, 0x93, 0x02, 0x01, 0x00, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x04, 0x79, 0x30, 0x77, 0x02, 0x01, 0x01, 0x04, 0x20])

    static func publicKeyfromDerData(_ data: Data) throws -> SecKey {
        guard data.count > SecKey.derHeaderData.count else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Malformed der key data provided."]
            )
        }
        let keyData: Data = data[SecKey.derHeaderData.count..<data.count]
        let publicAttributes: CFDictionary = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                              kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                              kSecAttrKeySizeInBits: 256] as CFDictionary
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, publicAttributes, &error) else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "An unknown error occurred creating SecKey from provided data"]
            )
        }
        return secKey
    }

    static func privateKeyfromDerData(_ data: Data) throws -> SecKey {
        guard data.count > SecKey.privateDerHeaderData.count else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Malformed der key data provided."]
            )
        }
        let keyData: Data = data[SecKey.privateDerHeaderData.count..<data.count]
        let privateAttributes: CFDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits: 256
        ] as CFDictionary
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, privateAttributes, &error) else {
            return try privateKeyfromPKCS8Data(data)
        }
        return secKey
    }

    static func privateKeyfromPKCS8Data(_ data: Data) throws -> SecKey {
        let cryptoKey: P256.Signing.PrivateKey = try .init(derRepresentation: data)
        let keyData: Data = cryptoKey.x963Representation

        let privateAttributes: CFDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, privateAttributes, &error) else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "An unknown error occurred creating SecKey from provided data"]
            )
        }
        return secKey
    }

    func toDer() throws -> Data {
        var error: Unmanaged<CFError>?
        guard let keyDataSec1 = SecKeyCopyExternalRepresentation(self, &error) as Data? else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "An unknown error occurred exporting key data"]
            )
        }
        return SecKey.derHeaderData + keyDataSec1
    }

    func toPrivateDer() throws -> Data {
        var error: Unmanaged<CFError>?
        guard let keyDataSec1 = SecKeyCopyExternalRepresentation(self, &error) as Data? else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "An unknown error occurred exporting key data"]
            )
        }
        return SecKey.privateDerHeaderData + keyDataSec1
    }

    func toPrivatePKCS8Der() throws -> Data {
        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(self, &error) else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "An unknown error occurred exporting key data"]
            )
        }
        let keyDataX963: Data = keyData as Data
        let privateKeyP256: P256.Signing.PrivateKey = try .init(x963Representation: keyDataX963)
        let privateKeyPkcs8Der: Data = privateKeyP256.derRepresentation
        return privateKeyPkcs8Der
    }
}
