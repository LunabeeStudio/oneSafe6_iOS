//
//  UseCase+Discovery.swift
//  UseCases
//
//  Created by Lunabee Studio (Quentin Noblet) on 02/06/2023 - 12:05.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model
import Foundation
import CoreCrypto
import UIKit

// MARK: Create Discovery items
public extension UseCase {
    static func createDiscoveryItems(addFolders: Bool, addTutorialItems: Bool) async throws {
        var safeItemKeys: [SafeItemKey] = []
        var safeItems: [SafeItem] = []
        var safeItemFields: [SafeItemField] = []

        if addTutorialItems {
            let discovery: Discovery = try discoveryRepository.getTutorialItemsDiscovery()

            for (index, discoveryItem) in discovery.data.enumerated() {
                let (keys, items, fields): ([SafeItemKey], [SafeItem], [SafeItemField]) = try await createSafe(index: index, discoveryItem: discoveryItem, labels: discovery.labels)
                safeItemKeys += keys
                safeItems += items
                safeItemFields += fields
            }
        }

        if addFolders {
            let discovery: Discovery = try discoveryRepository.getFoldersDiscovery()

            for (index, discoveryItem) in discovery.data.enumerated() {
                let (keys, items, fields): ([SafeItemKey], [SafeItem], [SafeItemField]) = try await createSafe(index: index, discoveryItem: discoveryItem, labels: discovery.labels)
                safeItemKeys += keys
                safeItems += items
                safeItemFields += fields
            }
        }

        // Save Safe Items, Keys and fields
        try UseCase.saveSafeItemKeys(keys: safeItemKeys)
        try safeItemRepository.save(fields: safeItemFields)
        try await UseCase.updateItems(safeItems)
    }
}

private extension UseCase {
    static func createSafe(index: Int,
                           parentId: String? = nil,
                           discoveryItem: DiscoveryItem,
                           labels: [String: String]) async throws -> (itemKeys: [SafeItemKey], items: [SafeItem], fields: [SafeItemField]) {
        var safeItemKeys: [SafeItemKey] = []
        var safeItems: [SafeItem] = []
        var safeItemFields: [SafeItemField] = []

        let (item, key): (SafeItem, SafeItemKey) = try await createItem(discoveryItem: discoveryItem, parentId: parentId, position: Double(index), labels: labels)
        safeItemKeys.append(key)
        safeItems.append(item)

        if let discoveryFields = discoveryItem.fields {
            safeItemFields += try discoveryFields.map { discoveryField in
                try createField(discoveryField: discoveryField, itemId: item.id, key: key, labels: labels)
            }
        }

        // Recursive algorithm to manage children
        if let discoveryItems = discoveryItem.items {
            for (index, discoveryItem) in discoveryItems.enumerated() {
                let (keys, items, fields): ([SafeItemKey], [SafeItem], [SafeItemField]) = try await createSafe(index: index, parentId: item.id, discoveryItem: discoveryItem, labels: labels)
                safeItemKeys += keys
                safeItems += items
                safeItemFields += fields
            }
        }
        return (safeItemKeys, safeItems, safeItemFields)
    }

    static func createItem(discoveryItem: DiscoveryItem,
                           parentId: String? = nil,
                           position: Double,
                           labels: [String: String]) async throws -> (item: SafeItem, key: SafeItemKey) {
        var item: SafeItem = SafeItem(id: UUID().uuidStringV4,
                                      iconId: discoveryItem.iconId,
                                      parentId: parentId,
                                      isFavorite: discoveryItem.isFavorite.orFalse,
                                      position: position)
        let key: SafeItemKey = try UseCase.createSafeItemKey(itemId: item.id)
        let coreCrypto: CoreCrypto = .shared
        let keyValue: Data = try coreCrypto.decrypt(value: key.value)

        let itemName: String = labels[discoveryItem.title] ?? discoveryItem.title
        item.encName = try coreCrypto.encrypt(value: itemName, key: keyValue)

        // Manage website color and icon
        var color: String? = discoveryItem.color
        if let discoveryFieldUrl = discoveryItem.fields?.sorted(by: { $0.position < $1.position }).first(where: { $0.kind == SafeItemField.Kind.url.rawValue }) {
            let webSiteInfo: WebsiteInfo? = try await UseCase.fetchWebSiteInformation(for: labels[discoveryFieldUrl.value] ?? discoveryFieldUrl.value)
            if let urlIcon = webSiteInfo?.icon {
                item.iconId = try UseCase.saveSafeItemIcon(image: urlIcon, previousIconId: nil, key: key)
                if let iconColor = UseCase.getDominantColor(for: urlIcon) {
                    color = iconColor
                }
            }
        } else if let firstCharacter = itemName.first, firstCharacter.isEmoji {
            let icon: UIImage? = UseCase.imageFromEmoji(firstCharacter)
            color = UseCase.getDominantColor(for: icon)
        }

        if let color {
            item.encColor = try coreCrypto.encrypt(value: color, key: keyValue)
        }
        return (item, key)
    }

    static func createField(discoveryField: DiscoveryField,
                            itemId: String,
                            key: SafeItemKey,
                            labels: [String: String]) throws -> SafeItemField {
        var field: SafeItemField = SafeItemField(id: UUID().uuidStringV4,
                                                 position: Double(discoveryField.position),
                                                 itemId: itemId,
                                                 isSecured: discoveryField.isSecured)

        let coreCrypto: CoreCrypto = .shared
        let keyValue: Data = try coreCrypto.decrypt(value: key.value)

        field.encName = try coreCrypto.encrypt(value: labels[discoveryField.name] ?? discoveryField.name, key: keyValue)
        field.encPlaceholder = try coreCrypto.encrypt(value: labels[discoveryField.placeholder] ?? discoveryField.placeholder, key: keyValue)
        field.encValue = try coreCrypto.encrypt(value: labels[discoveryField.value] ?? discoveryField.value, key: keyValue)
        field.encKind = try coreCrypto.encrypt(value: discoveryField.kind, key: keyValue)
        field.isItemIdentifier = discoveryField.isItemIdentifier
        field.showPrediction = discoveryField.showPrediction
        if let formattingMask = discoveryField.formattingMask {
            field.encFormattingMask = try coreCrypto.encrypt(value: formattingMask, key: keyValue)
        }
        if let secureDisplayMask = discoveryField.secureDisplayMask {
            field.encSecureDisplayMask = try coreCrypto.encrypt(value: secureDisplayMask, key: keyValue)
        }
        return field
    }
}
