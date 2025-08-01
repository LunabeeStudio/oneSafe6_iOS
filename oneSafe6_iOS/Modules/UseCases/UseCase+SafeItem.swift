//
//  UseCase+SafeItem.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 18/11/2022 - 15:02.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import Repositories
import Combine
import SwiftUI
import LBFoundationKit
import Assets
import Errors
import ThumbnailsCaching

// MARK: Observe
public extension UseCase {
    /// This observer will be scheduled on the global queue with User-initiated as quality-of-service class, this queue is concurrent so keep in mind that if you need to do some work that is not thread safe you should schedule it on a serial queue. If not, keep as it is.
    /// Schedule this observer on the main thread if you need to modify the UI
    static func observeSafeItem(id: String) throws -> AnyPublisher<SafeItem?, Never> {
        try safeItemRepository.observeSafeItem(id: id)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeAllSafeItems() throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeSafeItems(sortingKeyPath: nil, ascending: nil)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeAllSafeItems(sortingKeyPath: String, ascending: Bool = true) throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeSafeItems(sortingKeyPath: sortingKeyPath, ascending: ascending)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeRootSafeItems(sortingKeyPath: String, ascending: Bool = true) throws -> AnyPublisher<[SafeItem], Never> {
        try observeNotDeletedSafeItems(parentId: nil, sortingKeyPath: sortingKeyPath, ascending: ascending)
    }
    static func observeNotDeletedSafeItems(parentId: String?, sortingKeyPath: String? = nil, ascending: Bool? = nil) throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeNotDeletedSafeItems(parentId: parentId, sortingKeyPath: sortingKeyPath, ascending: ascending)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeNotDeletedSafeItemsCount(parentId: String?) throws -> AnyPublisher<Int, Never> {
        try safeItemRepository.observeNotDeletedSafeItemsCount(parentId: parentId)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeNotDeletedSafeItems(sortingKeyPath: String? = nil, ascending: Bool? = nil) throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeNotDeletedSafeItems(sortingKeyPath: sortingKeyPath, ascending: ascending)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeNotDeletedSafeItemsCount() throws -> AnyPublisher<Int, Never> {
        try safeItemRepository.observeNotDeletedSafeItemsCount()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeDeletedSafeItems() throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeDeletedSafeItems()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeDeletedSafeItemsCount() throws -> AnyPublisher<Int, Never> {
        try safeItemRepository.observeDeletedSafeItemsCount()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeDeletedSafeItems(deletedParentId: String?, sortingKeyPath: String? = nil, ascending: Bool? = true) throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeDeletedSafeItems(deletedParentId: deletedParentId, sortingKeyPath: sortingKeyPath, ascending: ascending)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeDeletedSafeItemsCount(deletedParentId: String?) throws -> AnyPublisher<Int, Never> {
        try safeItemRepository.observeDeletedSafeItemsCount(deletedParentId: deletedParentId)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    static func observeLastConsultedItems() throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeLastConsultedItems()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

// MARK: Get
public extension UseCase {
    static func getSafeItem(for id: String) throws -> SafeItem? {
        try safeItemRepository.getItem(id: id)
    }

    static func getSafeItems(for ids: [String]) throws -> [SafeItem] {
        try safeItemRepository.getItems(ids: ids)
    }

    static func getAllSafeItems() throws -> [SafeItem] {
        try safeItemRepository.getAllItems()
    }

    static func getNotDeletedSafeItems() throws -> [SafeItem] {
        try safeItemRepository.getAllNotDeletedItems()
    }

    static func getNotDeletedSafeItems(parentId: String?) throws -> [SafeItem] {
        try safeItemRepository.getItems(parentId: parentId).filter { $0.deletedAt == nil }
    }

    static func getDeletedSafeItems(parentId: String?) throws -> [SafeItem] {
        try safeItemRepository.getDeletedItems(deletedParentId: parentId)
    }

    static func getSafeItemWithKey(for id: String) throws -> SafeItemWithKey? {
        guard let item = try safeItemRepository.getItem(id: id) else { return nil }
        let itemKey: SafeItemKey? = try safeItemRepository.getKey(for: id)
        return .init(item: item, key: itemKey)
    }

    static func getSafeItemWithKey(item: SafeItem) throws -> SafeItemWithKey {
        let itemKey: SafeItemKey? = try safeItemRepository.getKey(for: item.id)
        return .init(item: item, key: itemKey)
    }

    static func itemIdentifier(for safeItem: SafeItem) -> SafeItemField? {
        try? safeItemRepository.getFields(for: safeItem.id).sorted { $0.position < $1.position }.first(where: { $0.isItemIdentifier && $0.encValue != nil })
    }

    static func itemHasSubitems(_ item: SafeItem) -> Bool {
        let hasSubtItems: Bool?
        if item.deletedAt != nil {
            hasSubtItems = try? safeItemRepository.itemHasDeletedSubItems(id: item.id)
        } else {
            hasSubtItems = try? safeItemRepository.itemHasNotDeletedSubItems(id: item.id)
        }
        return hasSubtItems ?? false
    }

    static func itemHasFields(_ item: SafeItem) -> Bool {
        (try? safeItemRepository.itemHasFields(id: item.id)) ?? false
    }

    static func itemHasNotEmptyFields(_ item: SafeItem) throws -> Bool {
        try !safeItemRepository.getFields(for: item.id).filter { $0.encValue != nil }.isEmpty
    }
}

// MARK: Create and Save
public extension UseCase {
    static func createSafeItem(parentId: String? = nil, fieldTemplates: [SafeItemFieldToCreate], color: Color? = nil, isFavorite: Bool = false, itemCreationOption: SafeItemBundle.CreationOption?, fromFilesUrls: [URL] = []) async throws -> SafeItemBundle {
        let position: Double = getNextAvailableChildrenPosition(parentId: parentId)
        let newItem: SafeItem = SafeItem(parentId: parentId, isFavorite: isFavorite, position: position)
        let newItemKey: SafeItemKey = try UseCase.createSafeItemKey(itemId: newItem.id)
        let fields: [SafeItemField] = try await fieldTemplates.asyncMap {
            try await UseCase.createSafeItemField(itemId: newItem.id, position: $0.position, kind: $0.kind, isSecured: $0.isSecured, name: $0.name, placeholder: $0.placeholder, key: newItemKey, isItemIdentifier: $0.isItemIdentifier, initialValue: $0.initialValue)
        }
        return SafeItemBundle(item: newItem, fields: fields, key: newItemKey, defaultColor: color, itemCreationOption: itemCreationOption, fromFilesUrls: fromFilesUrls)
    }

    static func updateItem(_ item: SafeItem) async throws {
        let itemToSave: SafeItem = try setupItemToUpdate(item: item)
        try safeItemRepository.save(items: [itemToSave])
        try await indexItem(itemToSave)
    }

    static func updateItems(_ items: [SafeItem]) async throws {
        let itemsToSave: [SafeItem] = try await withThrowingTaskGroup(of: SafeItem.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    try setupItemToUpdate(item: item)
                }
            }
            return try await taskGroup.collect()
        }
        try safeItemRepository.save(items: itemsToSave)
        try await indexItems(itemsToSave)
    }

    private static func setupItemToUpdate(item: SafeItem) throws -> SafeItem {
        var itemToSave: SafeItem = item
        itemToSave.updatedAt = Date()
        return itemToSave
    }
}

// MARK: Move items
public extension UseCase {
    static func move(item: SafeItem, in newParent: SafeItem?) async throws {
        var updatedItem: SafeItem = item
        updatedItem.parentId = newParent?.id
        try await updateItem(updatedItem)
    }
}

// MARK: Duplicate items
public extension UseCase {
    private static func setupDuplicatedField(_ field: SafeItemField, safeItemKey: SafeItemKey, duplicateItemId: String, duplicateItemKey: SafeItemKey) throws -> (SafeItemField, URL?) {
        var duplicateField: SafeItemField = SafeItemField(id: UUID().uuidStringV4, position: field.position, itemId: duplicateItemId, isSecured: field.isSecured)
        guard let fieldName: String = try getStringFromEncryptedData(data: field.encName, key: safeItemKey) else { throw AppError.duplicationFailed }
        duplicateField.encName = try getEncryptedDataFromString(value: fieldName, key: duplicateItemKey)

        if let encPlaceholder = field.encPlaceholder {
            guard let fieldPlaceholder: String = try getStringFromEncryptedData(data: encPlaceholder, key: safeItemKey) else { throw AppError.duplicationFailed }
            duplicateField.encPlaceholder = try getEncryptedDataFromString(value: fieldPlaceholder, key: duplicateItemKey)
        }

        guard let fieldKind: String = try getStringFromEncryptedData(data: field.encKind, key: safeItemKey) else { throw AppError.duplicationFailed }
        duplicateField.encKind = try getEncryptedDataFromString(value: fieldKind, key: duplicateItemKey)

        var duplicatedFileUrl: URL?
        if let encValue = field.encValue {
            guard let fieldValue: String = try getStringFromEncryptedData(data: encValue, key: safeItemKey) else { throw AppError.duplicationFailed }

            if let kind = SafeItemField.Kind(rawValue: fieldKind), [.photo, .video, .file].contains(kind) {
                let fileId: String = fieldValue.components(separatedBy: "|")[0]
                let fileUrl: URL = try fileRepository.getEncryptedFileUrlInStorage(fileId: fileId)

                let encFileData: Data = try Data(contentsOf: fileUrl, options: .alwaysMapped)
                guard let fileData = try getDataFromEncryptedData(data: encFileData, key: safeItemKey) else { throw AppError.duplicationFailed }
                guard let newEncFileData = try getEncryptedDataFromData(data: fileData, key: duplicateItemKey) else { throw AppError.duplicationFailed }
                duplicatedFileUrl = try safeItemFileDuplicateRepository.writeEncryptedFileDataToDuplicateDirectory(newEncFileData, fileId: fileId)
            }

            duplicateField.encValue = try getEncryptedDataFromString(value: fieldValue, key: duplicateItemKey)
        }

        duplicateField.showPrediction = field.showPrediction

        duplicateField.createdAt = Date()
        duplicateField.updatedAt = Date()

        duplicateField.isItemIdentifier = field.isItemIdentifier

        if let encFormattingMask = field.encFormattingMask {
            guard let fieldFormattingMask: String = try getStringFromEncryptedData(data: encFormattingMask, key: safeItemKey) else { throw AppError.duplicationFailed }
            duplicateField.encFormattingMask = try getEncryptedDataFromString(value: fieldFormattingMask, key: duplicateItemKey)
        }

        if let encSecureDisplayMask = field.encSecureDisplayMask {
            guard let fieldSecureDisplayMask: String = try getStringFromEncryptedData(data: encSecureDisplayMask, key: safeItemKey) else { throw AppError.duplicationFailed }
            duplicateField.encSecureDisplayMask = try getEncryptedDataFromString(value: fieldSecureDisplayMask, key: duplicateItemKey)
        }

        return (duplicateField, duplicatedFileUrl)
    }

    private static func setupDuplicatedSafeItem(_ originalSafeItem: SafeItem, originalSafeItemKey: SafeItemKey? = nil, isRootDuplicateItem: Bool = false) async throws -> (SafeItem, [(SafeItemField, URL?)], SafeItemIconDuplicate?, SafeItemKey) {
        guard let originalSafeItemKey = try originalSafeItemKey ?? getSafeItemKey(itemId: originalSafeItem.id) else { throw AppError.duplicationFailed }

        var duplicateItem: SafeItem = originalSafeItem
        let duplicateItemID: String = duplicateItem.id
        let duplicateItemKey: SafeItemKey = try UseCase.createSafeItemKey(itemId: duplicateItemID)

        guard let safeItemName: String = try getStringFromEncryptedData(data: originalSafeItem.encName, key: originalSafeItemKey) else { throw AppError.duplicationFailed }

        let newName: String = isRootDuplicateItem ? Strings.SafeItem.defaultDuplicatedName(safeItemName) : safeItemName
        duplicateItem.encName = try getEncryptedDataFromString(value: newName, key: duplicateItemKey)

        if let encColor = originalSafeItem.encColor {
            guard let safeItemColor: String = try getStringFromEncryptedData(data: encColor, key: originalSafeItemKey) else { throw AppError.duplicationFailed }
            duplicateItem.encColor = try getEncryptedDataFromString(value: safeItemColor, key: duplicateItemKey)
        }

        var duplicateIcon: SafeItemIconDuplicate?
        if let iconId = originalSafeItem.iconId {
            guard let safeItemIconData: Data = try getSafeItemImageDataFromIconId(iconId, key: originalSafeItemKey) else { throw AppError.duplicationFailed }
            guard let encryptedSafeItemIconData: Data = try getEncryptedDataFromData(data: safeItemIconData, key: duplicateItemKey) else { throw AppError.duplicationFailed }
            duplicateIcon = .init(id: iconId, data: encryptedSafeItemIconData)
        }

        let originalFields: [SafeItemField] = try safeItemRepository.getFields(for: originalSafeItem.id)
        let duplicateFields: [(SafeItemField, URL?)] = try originalFields.map {
            try setupDuplicatedField($0, safeItemKey: originalSafeItemKey, duplicateItemId: duplicateItemID, duplicateItemKey: duplicateItemKey)
        }

        duplicateItem.createdAt = Date()
        duplicateItem.updatedAt = Date()
        duplicateItem.consultedAt = nil
        duplicateItem.isFavorite = false
        duplicateItem.position = isRootDuplicateItem ? getNextPositionBeforeSibling(originalPosition: duplicateItem.position, parentId: originalSafeItem.parentId) : originalSafeItem.position

        return (duplicateItem, duplicateFields, duplicateIcon, duplicateItemKey)
    }

    static func duplicate(item: SafeItem, key: SafeItemKey) async throws -> String {
        do {
            let childrenToDuplicate: [SafeItem] = try await getAllSubItemsRecursively(item: item).filter { $0.deletedAt == nil }
            var duplicatedObjects: [(SafeItem, [(SafeItemField, URL?)], SafeItemIconDuplicate?, SafeItemKey)] = []
            duplicatedObjects.append(try await setupDuplicatedSafeItem(item, originalSafeItemKey: key, isRootDuplicateItem: true))
            duplicatedObjects.append(contentsOf: try await withThrowingTaskGroup(of: (SafeItem, [(SafeItemField, URL?)], SafeItemIconDuplicate?, SafeItemKey).self) { taskGroup in
                for item in childrenToDuplicate {
                    taskGroup.addTask {
                        try await setupDuplicatedSafeItem(item)
                    }
                }
                return try await taskGroup.collect()
            })
            let allDuplicatedSafeItems: [SafeItem] = duplicatedObjects.map { $0.0 }
            let allDuplicatedSafeItemFields: [(SafeItemField, URL?)] = duplicatedObjects.flatMap { $0.1 }
            let allDuplicatedSafeItemIcon: [SafeItemIconDuplicate] = duplicatedObjects.compactMap { $0.2 }
            let allDuplicatedSafeItemKeys: [SafeItemKey] = duplicatedObjects.map { $0.3 }

            try allDuplicatedSafeItemIcon.forEach {
                try safeItemIconDuplicateRepository.saveIconData($0.data, iconId: $0.id)
            }

            let finalDuplicateIconsUrls: [URL] = try safeItemIconDuplicateRepository.allDuplicateIconsUrls()
            let finalDuplicateFilesUrls: [URL] = try safeItemFileDuplicateRepository.allDuplicateFilesUrls()

            let updatedData: (items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], filesUrls: [URL]) = try await regenerateItemsIds(items: allDuplicatedSafeItems, fields: allDuplicatedSafeItemFields.map { $0.0 }, keys: allDuplicatedSafeItemKeys, iconsUrls: finalDuplicateIconsUrls, filesUrls: finalDuplicateFilesUrls, defaultRootId: item.parentId)

            try await safeItemIconDuplicateRepository.processIconsDuplicate()
            try await safeItemFileDuplicateRepository.processFilesDuplicate()
            try safeItemRepository.save(keys: updatedData.keys)
            try safeItemRepository.save(fields: updatedData.fields)
            try safeItemRepository.save(items: updatedData.items)
            try await indexItems(updatedData.items)

            guard let duplicateItemId = updatedData.items.first?.id else { throw AppError.duplicationFailed }
            try clearDuplicateData()
            return duplicateItemId
        } catch {
            try clearDuplicateData()
            throw error
        }
    }

    static func clearDuplicateData() throws {
        try safeItemIconDuplicateRepository.deleteAllDuplicateIcons()
        try safeItemFileDuplicateRepository.deleteAllDuplicateFiles()
    }
}

// MARK: Favorite
public extension UseCase {
    static func addSafeItemToFavorites(safeItem: SafeItem) async throws {
        var itemToSave: SafeItem = safeItem
        itemToSave.isFavorite = true
        try safeItemRepository.save(items: [itemToSave])
    }

    static func removeSafeItemFromFavorites(safeItem: SafeItem) async throws {
        var itemToSave: SafeItem = safeItem
        itemToSave.isFavorite = false
        try safeItemRepository.save(items: [itemToSave])
    }

    static func getFavoritesSafeItems() throws -> [SafeItem] {
        try safeItemRepository.getAllItems()
            .filter { $0.isFavorite }
    }

    static func observeFavoritesSafeItems(sortingKeyPath: String? = nil, ascending: Bool? = nil) throws -> AnyPublisher<[SafeItem], Never> {
        try safeItemRepository.observeFavoriteSafeItems(sortingKeyPath: sortingKeyPath, ascending: ascending)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

// MARK: Bin
public extension UseCase {
    static var deletionDelay: TimeInterval { Constant.deletionDelay }

    static func restoreSafeItem(item: SafeItem) async throws {
        var parentItemToRestore: SafeItem = item
        parentItemToRestore.parentId = try findNearestNonDeletedParent(for: item)?.id

        let itemsToRestore: [SafeItem] = try await getAllSubItemsRecursively(item: item) + [parentItemToRestore]
        let itemsToSave: [SafeItem] = try await withThrowingTaskGroup(of: SafeItem.self) { taskGroup in
            for item in itemsToRestore {
                taskGroup.addTask {
                    var itemToSave: SafeItem = item
                    itemToSave.deletedAt = nil
                    itemToSave.deletedParentId = nil
                    return itemToSave
                }
            }
            return try await taskGroup.collect()
        }
        try safeItemRepository.save(items: itemsToSave)
    }

    static func moveSafeItemToBin(item: SafeItem) async throws {
        let itemsToSave: [SafeItem]

            let subItemsToDelete: [SafeItem] = try await getAllSubItemsRecursively(item: item).filter { $0.deletedAt == nil }
            itemsToSave = try await withThrowingTaskGroup(of: SafeItem.self) { taskGroup in
                taskGroup.addTask {
                    setupItemToMoveToBin(item: item, deletedParentId: nil)
                }
                for subItem in subItemsToDelete {
                    taskGroup.addTask {
                        setupItemToMoveToBin(item: subItem, deletedParentId: subItem.parentId)
                    }
                }
                return try await taskGroup.collect()
            }

        try safeItemRepository.save(items: itemsToSave)
    }

    private static func setupItemToMoveToBin(item: SafeItem, deletedParentId: String?) -> SafeItem {
        var itemToDelete: SafeItem = item
        itemToDelete.deletedAt = Date()
        itemToDelete.isFavorite = false
        itemToDelete.deletedParentId = deletedParentId
        return itemToDelete
    }

    static func deleteSafeItemFromBin(item: SafeItem) async throws {
        let itemsToDelete: [SafeItem] = try await getAllSubItemsRecursively(item: item) + [item]
        try await withThrowingTaskGroup(of: Void.self, body: { taskGroup in
            taskGroup.addTask {
                try await deleteItems(itemsToDelete)
            }
            try await taskGroup.waitForAll()
        })
    }

    static func clearDeletedSafeItems(delay: TimeInterval? = nil) async throws {
        let delay: TimeInterval = delay ?? Constant.deletionDelay
        let itemsToDelete: [SafeItem] = try getExpiredDeletedSafeItems(delay: delay)
        try await deleteItems(itemsToDelete)
    }

    static func deleteAllSafeItemsFromBin() async throws {
        let itemsToDelete: [SafeItem] = try safeItemRepository.getAllDeletedItems()
        try await deleteItems(itemsToDelete)
    }

    static func deleteAllItems() throws {
        try safeItemRepository.deleteAllItems()
        try safeItemIconRepository.deleteAllIcons()
        try fileRepository.deleteAllFileDataFromStorage()
        Thumbnails.deleteAll()
    }
}

public extension UseCase {
    static func parent(of safeItem: SafeItem) async -> SafeItemWithKey? {
        guard let parentItem = try? findNearestNonDeletedParent(for: safeItem) else { return nil }
        let parentKey: SafeItemKey? = try? UseCase.getSafeItemKey(itemId: safeItem.id)
        return .init(item: parentItem, key: parentKey)
    }

    static func findPath(to item: SafeItem?) async -> [SafeItem] {
        guard let item else { return [] }
        var items: [SafeItem] = [item]

        var currentItem: SafeItem? = item
        while currentItem != nil {
            let parent: SafeItem? = try? findNearestNonDeletedParent(for: currentItem!)

            if let parent {
                items.append(parent)
            }

            currentItem = parent
        }

        return items.reversed()
    }
    static func sortedItemsWithCurrentSortingOption(_ items: [SafeItemWithKey]) -> [SafeItemWithKey] {
        items.sorted {
            switch getItemsSortingOption() {
            case .creationDate:
                $0.item.createdAtPosition ?? 0 < $1.item.createdAtPosition ?? 0
            case .alphabetical:
                $0.item.alphabeticalPosition ?? 0 < $1.item.alphabeticalPosition ?? 0
            case .consultationDate:
                $0.item.consultedAtPosition ?? 0 < $1.item.consultedAtPosition ?? 0
            }
        }
    }

    static func sortedItemsWithCurrentSortingOption(_ items: [SafeItem]) -> [SafeItem] {
        items.sorted {
            switch getItemsSortingOption() {
            case .creationDate:
                $0.createdAtPosition ?? 0 < $1.createdAtPosition ?? 0
            case .alphabetical:
                $0.alphabeticalPosition ?? 0 < $1.alphabeticalPosition ?? 0
            case .consultationDate:
                $0.consultedAtPosition ?? 0 < $1.consultedAtPosition ?? 0
            }
        }
    }
}

// MARK: Helpers
extension UseCase {
    static func findNearestNonDeletedParent(for item: SafeItem) throws -> SafeItem? {
        let parentId: String? = item.parentId

        if let parentId {
            if let parentItem = try safeItemRepository.getItem(id: parentId) {
                if parentItem.deletedAt == nil {
                    return parentItem
                } else {
                    return try findNearestNonDeletedParent(for: parentItem)
                }
            } else {
                return nil // Parent not found, default on nil to show the item in home section.
            }
        } else {
            return nil
        }
    }

    static func getAllSubItemsRecursively(item: SafeItem) async throws -> [SafeItem] {
        let directSubItems: [SafeItem] = try getDirectSubItemsOf(item: item)
        guard !directSubItems.isEmpty else { return [] }

        return try await withThrowingTaskGroup(of: [SafeItem].self) { taskGroup in
            for subItem in directSubItems {
                taskGroup.addTask {
                    try await getAllSubItemsRecursively(item: subItem)
                }
            }
            return try await directSubItems + taskGroup.collect().flatMap { $0 }
        }
    }

    static func getDirectSubItemsOf(item: SafeItem) throws -> [SafeItem] {
        if item.deletedAt == nil {
            return try safeItemRepository.getItems(parentId: item.id).filter { $0.deletedAt == nil }
        } else {
            return try safeItemRepository.getDeletedItems(deletedParentId: item.id)
        }
    }

    // position → (original position + next sibling item position) / 2 (if no next sibling, original position + 1)
    static func getNextPositionBeforeSibling(originalPosition: Double, parentId: String?) -> Double {
        guard let items = try? safeItemRepository.getItems(parentId: parentId).filter({ $0.deletedAt == nil }).sorted(by: \.position) else { return 0 }
        return (items.filter( { $0.position > originalPosition }).first != nil) ? (originalPosition + items.filter( { $0.position > originalPosition })[0].position) / 2 : originalPosition + 1
    }

    static func getNextAvailableChildrenPosition(parentId: String?) -> Double {
        guard let items = try? safeItemRepository.getItems(parentId: parentId).filter({ $0.deletedAt == nil }) else { return 0 }
        return (items.max(by: { $0.position < $1.position })?.position).map { $0 + 1 } ?? 0.0
    }

    static func getExpiredDeletedSafeItems(delay: TimeInterval) throws -> [SafeItem] {
        try safeItemRepository.getAllDeletedItems().filter { item in
            guard let deletedDate = item.deletedAt else { return false }
            return deletedDate.addingTimeInterval(delay) < .now
        }
    }

    static func deleteItems(_ items: [SafeItem]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    try await deleteItem(item)
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    static func deleteItem(_ item: SafeItem) async throws {
        if let iconId = item.iconId {
            try? safeItemIconRepository.deleteIconData(iconId: iconId)
        }
        if let itemKey = try safeItemRepository.getKey(for: item.id) {
            let itemFields: [SafeItemField] = try safeItemRepository.getFields(for: item.id)
            try itemFields.forEach {
                let kind: SafeItemField.Kind? = try getStringFromEncryptedData(data: $0.encKind, key: itemKey).flatMap { .init(rawValue: $0) }
                guard [.photo, .video, .file].contains(kind) else { return }
                try removeFileFromStorage(field: $0, safeItemKey: itemKey)
            }
        }
        try safeItemRepository.deleteItem(id: item.id)
        try await unindexItem(id: item.id)
    }
}

// MARK: Ids regeneration
extension UseCase {
    static func regenerateItemsIds(items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], filesUrls: [URL], defaultRootId: String? = nil, progress: Progress? = nil) async throws -> (items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], filesUrls: [URL]) {
        // First, we gather all the already used ids.
        let existingItemsIds: Set<String> = .init(try safeItemRepository.getAllItems().map { $0.id })
        let existingFieldsIds: Set<String> = .init(try safeItemRepository.getAllFields().map { $0.id })
        let existingIconsIds: Set<String> = .init(try safeItemIconRepository.getAllIconsUrls().map { $0.deletingPathExtension().lastPathComponent })
        let existingFilesIds: Set<String> = .init(try fileRepository.getAllEncryptedFileUrlInStorage().map { $0.deletingPathExtension().lastPathComponent })

        // We declare all its dictionaries indicating a mapping between an old id and its new value.
        var newItemIdsByOldItemIds: [String: String] = [:]
        var newKeyIdsByOldKeyIds: [String: String] = [:]
        var newIconIdsByOldIconIds: [String: String] = [:]
        var newFileIdsByOldFileIds: [String: String] = [:]

        // We need to quickly find any key from its ids for file url migration so we use a dictionary for that
        let keysByIds: [String: SafeItemKey] = .init(uniqueKeysWithValues: keys.map { ($0.id, $0) })

        let worker: ProgressWorker? = progress != nil ? .init(progress: progress!) : nil
        if worker != nil {
            worker!.progress.totalUnitCount = Int64(3 * items.count + fields.count + keys.count + iconsUrls.count)
        }
        // We iterate over all the items.
        var migratedItems: [SafeItem] = try await withThrowingTaskGroup(of: (item: SafeItem,
                                                                             itemIds: (String, String),
                                                                             keyIds: (String, String),
                                                                             iconIds: (String, String)?).self,
                                                                        returning: [SafeItem].self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    var item: SafeItem = item
                    let oldItemId: String = item.id

                    // We generate a new item id which was never used.
                    var newItemId: String = UUID().uuidStringV4
                    while existingItemsIds.contains(newItemId) { newItemId = UUID().uuidStringV4 }
                    item.id = newItemId

                    // We store it into the mapping dictionary.
                    let itemIds: (String, String) = (oldItemId, newItemId)

                    let oldKeyId: String = oldItemId
                    let newKeyId: String = newItemId
                    // We store the old and new ids into the mapping dictionary.
                    let keyIds: (String, String) = (oldKeyId, newKeyId)

                    var iconIds: (String, String)?
                    // We check if we have to manage an icon id migration.
                    if let oldIconId = item.iconId {
                        // We create the new icon id.
                        var newIconId: String = UUID().uuidStringV4
                        while existingIconsIds.contains(newIconId) { newIconId = UUID().uuidStringV4 }
                        // We store the new icon id into the item.
                        item.iconId = newIconId
                        // We store the old and new ids into the mapping dictionary.
                        iconIds = (oldIconId, newIconId)
                    }
                    await incrementWorker(worker)
                    return (item, itemIds, keyIds, iconIds)
                }
            }
            var results: [SafeItem] = []
            for try await result in taskGroup {
                results.append(result.item)
                newItemIdsByOldItemIds[result.itemIds.0] = result.itemIds.1
                newKeyIdsByOldKeyIds[result.keyIds.0] = result.keyIds.1
                guard let iconIds = result.iconIds else {
                    await incrementWorker(worker)
                    continue
                }
                newIconIdsByOldIconIds[iconIds.0] = iconIds.1
                await incrementWorker(worker)
            }
            return results
        }

        // We iterate over all items a second time to migrate all the items parent id based on the ids migration dictionary previously generated.
        migratedItems = try await withThrowingTaskGroup(of: SafeItem.self) { taskGroup in
            var udpatedItems: [SafeItem] = []
            for item in migratedItems {
                guard let parentId = item.parentId else {
                    udpatedItems.append(item)
                    await incrementWorker(worker)
                    continue
                }
                guard let newParentId = newItemIdsByOldItemIds[parentId] else {
                    // On old android version the exported items always contained their parent id even if the parent wasn't part of the export. This leads to saving an item with a parent id not associated with any item. So the imported item will not appear in the app except through search.
                    udpatedItems.append(item)
                    await incrementWorker(worker)
                    continue
                }
                taskGroup.addTask {
                    var item: SafeItem = item
                    item.parentId = newParentId
                    await incrementWorker(worker)
                    return item
                }
            }
            try await udpatedItems.append(contentsOf: taskGroup.collect())
            return udpatedItems
        }

        // We iterate over all fields.
        let migratedFields: [SafeItemField] = try await withThrowingTaskGroup(of: (field: SafeItemField?,
                                                                                   fileIds: (old: String, new: String)?).self,
                                                                              returning: [SafeItemField].self) { taskGroup in
            for field in fields {
                let newItemId: String? = newItemIdsByOldItemIds[field.itemId]
                taskGroup.addTask {
                    if let newItemId {
                        var field: SafeItemField = field
                        guard let key = keysByIds[field.itemId] else { throw AppError.cryptoNoKeyForDecryption }

                        var newFieldId: String = UUID().uuidStringV4
                        while existingFieldsIds.contains(newFieldId) { newFieldId = UUID().uuidStringV4 }
                        field.id = newFieldId
                        field.itemId = newItemId

                        guard let kind = try SafeItemField.Kind(rawValue: getStringFromEncryptedData(data: field.encKind, key: key) ?? "") else { throw AppError.appUnknown }
                        if [.file, .photo, .video].contains(kind) {
                            guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.appUnknown }
                            guard let fileExtension = fileIdAndExtension.components(separatedBy: "|").last else { throw AppError.appUnknown }
                            guard let oldFileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.appUnknown }
                            var newFileId: String = UUID().uuidStringV4
                            while existingFilesIds.contains(newFieldId) { newFileId = UUID().uuidStringV4 }
                            field.encValue = try getEncryptedDataFromString(value: [newFileId, fileExtension].joined(separator: "|"), key: key)
                            await incrementWorker(worker)
                            return (field, (oldFileId, newFileId))
                        } else {
                            await incrementWorker(worker)
                            return (field, nil)
                        }
                    } else {
                        await incrementWorker(worker)
                        return (nil, nil)
                    }
                }
            }
            var results: [SafeItemField] = []
            for try await result in taskGroup {
                results.append(result.field)
                if let fileIds = result.fileIds {
                    newFileIdsByOldFileIds[fileIds.old] = fileIds.new
                }
                await incrementWorker(worker)
            }
            return results
        }

        // We iterate over all keys.
        let migratedKeys: [SafeItemKey] = try await withThrowingTaskGroup(of: SafeItemKey?.self) { taskGroup in
            for key in keys {
                let newKeyId: String? = newKeyIdsByOldKeyIds[key.id]
                taskGroup.addTask {
                    if let newKeyId {
                        let key: SafeItemKey = .init(id: newKeyId, value: key.value)
                        await incrementWorker(worker)
                        return key
                    } else {
                        await incrementWorker(worker)
                        return nil
                    }
                }
            }
            return try await taskGroup.collect().compactMap { $0 }
        }

        // We iterate over all the icons urls to rename them using the new icons ids.
        let migratedIconsUrls: [URL] = try await withThrowingTaskGroup(of: URL.self) { taskGroup in
            for oldIconUrl in iconsUrls {
                let oldIconId: String = oldIconUrl.deletingPathExtension().lastPathComponent
                guard let newIconId = newIconIdsByOldIconIds[oldIconId] else {
                    await incrementWorker(worker)
                    continue
                }
                taskGroup.addTask {
                    let iconExtension: String = oldIconUrl.pathExtension
                    let iconDirectory: URL = oldIconUrl.deletingLastPathComponent()
                    let newIconUrl: URL = iconDirectory.appending(path: newIconId).appendingPathExtension(iconExtension)
                    try FileManager.default.moveItem(at: oldIconUrl, to: newIconUrl)
                    await incrementWorker(worker)
                    return newIconUrl
                }
            }
            return try await taskGroup.collect()
        }

        let migratedFilesUrls: [URL] = try await withThrowingTaskGroup(of: URL.self, body: { taskGroup in
            for oldFileUrl in filesUrls {
                let oldFileId: String = oldFileUrl.lastPathComponent
                guard let newFileId = newFileIdsByOldFileIds[oldFileId] else {
                    await incrementWorker(worker)
                    continue
                }
                taskGroup.addTask {
                    let fileDirectory: URL = oldFileUrl.deletingLastPathComponent()
                    let newFileUrl: URL = fileDirectory.appending(path: newFileId)
                    try FileManager.default.moveItem(at: oldFileUrl, to: newFileUrl)
                    await incrementWorker(worker)
                    return newFileUrl
                }
            }
            return try await taskGroup.collect()
        })

        // Finally we return all the migrated objects.
        return (migratedItems, migratedFields, migratedKeys, migratedIconsUrls, migratedFilesUrls)
    }
}
