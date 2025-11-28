//
//  UseCase+Draft.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 11/07/2023 - 10:02.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import Repositories
import CoreCrypto
@preconcurrency import oneSafeKmp
import Errors

public extension UseCase {
    static func saveSafeItemDraft(_ draft: SafeItemEditionDraft, key: SafeItemKey) throws {
        let coreCrypto: CoreCrypto = .shared
        let data: Data = try JSONEncoder().encode(draft)
        let keyValue: Data = try coreCrypto.decrypt(value: key.value) // No master key loaded at this point 😭
        let encData: Data = try coreCrypto.encrypt(value: data, key: keyValue)
        try draftRepository.saveSafeItemDraft(encData: encData)
    }

    static func getCurrentSafeItemDraft(key: SafeItemKey) throws -> SafeItemEditionDraft? {
        guard let encData = try draftRepository.getCurrentSafeItemDraft() else { return nil }
        let coreCrypto: CoreCrypto = .shared
        let keyValue: Data = try coreCrypto.decrypt(value: key.value)
        let data: Data = try coreCrypto.decrypt(value: encData, key: keyValue)
        return try JSONDecoder().decode(SafeItemEditionDraft.self, from: data)
    }

    static func deleteSafeItemDraft() throws {
        try draftRepository.deleteSafeItemDraft()
    }

    static func saveBubblesInputMessageDraft(_ draft: String, key: Model.ContactLocalKey) throws {
        let coreCrypto: CoreCrypto = .shared
        guard let data: Data = draft.data(using: .utf8) else { return }
        let decryptedKey: Data = try coreCrypto.decrypt(value: key.encKey, scope: .bubbles)
        guard let encData = coreCrypto.bubblesEncrypt(plainData: data.toByteArray(), key: decryptedKey.toByteArray(), associatedData: nil)?.toNSData() else {
            throw AppError.cryptoUnknown()
        }
        try draftRepository.deleteBubblesInputMessageDraft()
        try draftRepository.saveBubblesInputMessageDraft(encData: encData)
    }

    static func getBubblesInputMessageDraft(key: Model.ContactLocalKey) throws -> String? {
        guard let encData = try draftRepository.getBubblesInputMessageDraft() else { return nil }
        try draftRepository.deleteBubblesInputMessageDraft()
        let coreCrypto: CoreCrypto = .shared
        let decryptedKey: Data = try coreCrypto.decrypt(value: key.encKey, scope: .bubbles)
        guard let data = coreCrypto.bubblesDecrypt(cipherData: encData.toByteArray(), key: decryptedKey.toByteArray(), associatedData: nil)?.toNSData() else {
            throw AppError.cryptoUnknown()
        }
        return data.string(using: .utf8)
    }

    static func deleteBubblesInputMessageDraft() throws {
        try draftRepository.deleteBubblesInputMessageDraft()
    }
}
