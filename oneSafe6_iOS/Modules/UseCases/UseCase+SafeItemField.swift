//
//  UseCase+SafeItemField.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 18/11/2022 - 14:56.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Model
import CoreCrypto
import Combine

public extension UseCase {
    static func createSafeItemField(itemId: String, position: Double, kind: SafeItemField.Kind, isSecured: Bool, name: String, placeholder: String, key: SafeItemKey, isItemIdentifier: Bool = false, initialValue: String? = nil) async throws -> SafeItemField {
        let coreCrypto: CoreCrypto = .shared
        var field: SafeItemField = SafeItemField(id: UUID().uuidStringV4, position: position, itemId: itemId, isItemIdentifier: isItemIdentifier, isSecured: isSecured)

        let keyValue: Data = try coreCrypto.decrypt(value: key.value)

        field.encName = try coreCrypto.encrypt(value: name, key: keyValue)
        field.encPlaceholder = try coreCrypto.encrypt(value: placeholder, key: keyValue)
        field.encKind = try coreCrypto.encrypt(value: kind.rawValue, key: keyValue)
        if let initialValue {
            field.encValue = try coreCrypto.encrypt(value: initialValue, key: keyValue)
        }
        return field
    }

    static func createSafeItemFileField(itemId: String, position: Double, kind: SafeItemField.Kind, fileUrl: URL, key: SafeItemKey) throws -> SafeItemField {
        let fileName: String = fileUrl.lastPathComponent
        let fileExtension: String = fileName.components(separatedBy: ".").dropFirst().joined(separator: ".")
        let fileId: String = "\(UUID().uuidStringV4)|\(fileExtension)"

        var field: SafeItemField = .init(id: UUID().uuidStringV4, position: position, itemId: itemId, isSecured: false)
        field.encName = try getEncryptedDataFromString(value: fileName, key: key)
        field.encValue = try getEncryptedDataFromString(value: fileId, key: key)
        field.encKind = try getEncryptedDataFromString(value: kind.rawValue, key: key)
        return field
    }

    static func updateItemFields(fields: [SafeItemField], itemId: String) async throws {
        try await safeItemRepository.update(fields: fields, for: itemId)
    }

    static func getSafeItemFields(itemId: String) throws -> [SafeItemField] {
        try safeItemRepository.getFields(for: itemId)
    }

    static func observeSafeItemFields(itemId: String) throws -> AnyPublisher<[SafeItemField], Never> {
        try safeItemRepository.observeSafeItemFields(itemId: itemId)
            .removeDuplicates()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
    }

    static func observeSafeItemField(fieldId: String) throws -> AnyPublisher<SafeItemField?, Never> {
        try safeItemRepository.observeSafeItemField(fieldId: fieldId)
    }
}
