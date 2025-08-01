//
//  UseCase+Indexing.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 30/06/2023 - 10:42.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import CoreSpotlight
import CoreCrypto
import Extensions

// MARK: Indexing
public extension UseCase {
    static func isSpotlightAuthorized() -> Bool {
        settingsRepository.isSpotlightAuthorized()
    }

    static func updateSpotlightAuthorized(_ value: Bool) {
        settingsRepository.updateIsSpotlightAuthorized(value)
        Task {
            try await reindexSpotlight()
        }
    }

    static func showSpotlightItemIdentifier() -> Bool {
        settingsRepository.showSpotlightItemIdentifier()
    }

    static func updateShowSpotlightItemIdentifier(_ value: Bool) {
        settingsRepository.updateShowSpotlightItemIdentifier(value)
        Task {
            try await reindexSpotlight()
        }
    }

    static func clearSpotlightIndex() async throws {
        try await CSSearchableIndex.default().deleteAllSearchableItems()
    }

    static func indexItem(_ item: SafeItem, onlySpotlight: Bool = false) async throws {
        let keywords: [Data] = try await hashedEncryptedKeywords(for: item.id)
        if !onlySpotlight {
            try searchRepository.indexItem(id: item.id, keywords: keywords)
            var updatedItem: SafeItem = item
            updatedItem.alphabeticalPosition = try getAlphabeticalItemIndex(item: item)
            updatedItem.createdAtPosition = try getCreatedAtItemIndex(item: item)
            try safeItemRepository.save(items: [updatedItem])
        }
        try await indexItemInSpotlight(item, encKeywords: keywords)
    }

    static func indexItems(_ items: [SafeItem], onlySpotlight: Bool = false) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    try await indexItem(item, onlySpotlight: onlySpotlight)
                }
            }
            try await taskGroup.waitForAll()
        }
    }

    static func indexItems(_ items: [SafeItem], progress: Progress) async throws {
        let worker: ProgressWorker = .init(progress: progress)
        worker.progress.totalUnitCount = Int64(items.count)
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    try await indexItem(item)
                    await worker.increment(1)
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    static func unindexItem(id: String) async throws {
        try searchRepository.unindexItem(id: id)
        try await removeItemFromSpotlight(itemId: id)
    }

    static func deleteAllSearchIndex() async throws {
        try searchRepository.deleteAll()
        try await deleteAllSpotlightIndex()
    }
}

// MARK: - Alphabetical sorting indexing -
public extension UseCase {
    static func needsItemsAlphabeticalSortingIndexing() throws -> Bool {
        try !safeItemRepository.getNotAlphabeticallySortedItems().isEmpty
    }

    static func reindexItemsForAlphabeticalSorting() async throws {
        let allItems: [SafeItem] = try getAllSafeItems()
        let itemsById: [String: SafeItem] = .init(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        var itemsTitles: [(itemId: String, itemTitle: String)] = try await withThrowingTaskGroup(of: (itemId: String, itemTitle: String)?.self) { taskGroup in
            for item in allItems {
                taskGroup.addTask {
                    guard let key = try? getSafeItemKey(itemId: item.id) else { return nil }
                    guard let title = try? UseCase.getStringFromEncryptedData(data: item.encName, key: key) else { return nil }
                    return (
                        item.id,
                        title.removingEmojis().localizedLowercase.folding(options: .diacriticInsensitive, locale: nil)
                    )
                }
            }
            return try await taskGroup.collect().compactMap()
        }
        itemsTitles.sort {
            $0.itemTitle.compare($1.itemTitle, options: [.numeric]) == .orderedAscending
        }
        let updatedItems: [SafeItem] = itemsTitles.enumerated().compactMap {
            guard let item = itemsById[$1.itemId] else { return nil }
            var updateItem: SafeItem = item
            updateItem.alphabeticalPosition = Double($0)
            return updateItem
        }
        try safeItemRepository.save(items: updatedItems)
    }

    static func getAlphabeticalItemIndex(item: SafeItem) throws -> Double? {
        guard let key = try getSafeItemKey(itemId: item.id) else { return nil }
        guard let itemName = try getStringFromEncryptedData(data: item.encName, key: key) else { return nil }
        let allItems: [SafeItem] = try getAllSafeItems()
            .filter { $0.id != item.id }
            .sorted { $0.alphabeticalPosition ?? 0.0 < $1.alphabeticalPosition ?? 0.0 }
        return try startAlphabeticalPositionBinarySearch(itemName: itemName, items: allItems)
    }
}

// MARK: - ConsultedAt sorting indexing -
public extension UseCase {
    static func needsItemsConsultedAtSortingIndexing() throws -> Bool {
        try !safeItemRepository.getNotConsultedAtSortedItems().isEmpty
    }

    static func reindexItemsForConsultedAtSorting() async throws {
        let allItems: [SafeItem] = try getAllSafeItems()
        let itemsById: [String: SafeItem] = .init(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        var itemsDates: [(itemId: String, itemConsultedAt: Date)] = allItems.map { ($0.id, $0.consultedAt ?? .distantPast) }
        itemsDates.sort { $0.itemConsultedAt > $1.itemConsultedAt }
        let updatedItems: [SafeItem] = itemsDates.enumerated().compactMap {
            guard let item = itemsById[$1.itemId] else { return nil }
            var updateItem: SafeItem = item
            updateItem.consultedAtPosition = Double($0)
            return updateItem
        }
        try safeItemRepository.save(items: updatedItems)
    }

    static func getConsultedAtItemIndex(item: SafeItem) throws -> Double? {
        let allItems: [SafeItem] = try getAllSafeItems()
            .filter { $0.id != item.id }
            .sorted { $0.consultedAtPosition ?? 0.0 < $1.consultedAtPosition ?? 0.0 }
        return try startConsultedAtPositionBinarySearch(itemConsultedAt: item.consultedAt ?? .distantPast, items: allItems)
    }
}

// MARK: - CreatedAt sorting indexing -
public extension UseCase {
    static func needsItemsCreatedAtSortingIndexing() throws -> Bool {
        try !safeItemRepository.getNotConsultedAtSortedItems().isEmpty
    }

    static func reindexItemsForCreatedAtSorting() async throws {
        let allItems: [SafeItem] = try getAllSafeItems()
        let itemsById: [String: SafeItem] = .init(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        var itemsDates: [(itemId: String, itemCreatedAt: Date)] = allItems.map { ($0.id, $0.createdAt) }
        itemsDates.sort { $0.itemCreatedAt > $1.itemCreatedAt }
        let updatedItems: [SafeItem] = itemsDates.enumerated().compactMap {
            guard let item = itemsById[$1.itemId] else { return nil }
            var updateItem: SafeItem = item
            updateItem.createdAtPosition = Double($0)
            return updateItem
        }
        try safeItemRepository.save(items: updatedItems)
    }

    static func getCreatedAtItemIndex(item: SafeItem) throws -> Double? {
        let allItems: [SafeItem] = try getAllSafeItems()
            .filter { $0.id != item.id }
            .sorted { $0.createdAtPosition ?? 0.0 < $1.createdAtPosition ?? 0.0 }
        return try startCreatedAtPositionBinarySearch(itemCreatedAt: item.createdAt, items: allItems)
    }
}

public extension UseCase {
    static func setupSpotlight() {
        searchRepository.setSpotlightReindexingCallbacks {
            Task {
                try await reindexSpotlight()
            }
        } reindexSpotlightItemsForIds: { itemsIds in
            Task {
                let itemsToReindex: [SafeItem] = try safeItemRepository.getItems(ids: itemsIds)
                try await reindexSpotlight(items: itemsToReindex)
            }
        }
    }
}

private extension UseCase {
    static func indexItemInSpotlight(_ item: SafeItem, encKeywords: [Data]) async throws {
        guard settingsRepository.isSpotlightAuthorized() else { return }
        guard CSSearchableIndex.isIndexingAvailable() else { return }
        guard let key = try getSafeItemKey(itemId: item.id) else { return }
        let attributeSet: CSSearchableItemAttributeSet = .init(contentType: .data)
        attributeSet.title = try getStringFromEncryptedData(data: item.encName, key: key)
        attributeSet.creator = Constant.Search.spolightItemCreator
        if settingsRepository.showSpotlightItemIdentifier() {
            attributeSet.contentDescription = try getStringFromEncryptedData(data: itemIdentifier(for: item)?.encValue, key: key)
        }
        if let iconId = item.iconId, let encIconData = try safeItemIconRepository.getEncryptedIconData(id: iconId) {
            let keyValue: Data = try CoreCrypto.shared.decrypt(value: key.value, scope: .main)
            let iconData: Data = try CoreCrypto.shared.decrypt(value: encIconData, key: keyValue)
            attributeSet.thumbnailData = iconData
        }
        let clearKeywords: [String] = try encKeywords.compactMap { try getStringFromEncryptedData(data: $0, scope: .searchIndex) }
        attributeSet.keywords = clearKeywords
        let indexItem: CSSearchableItem = .init(uniqueIdentifier: item.id,
                                                domainIdentifier: Bundle.mainBundleIdentifier,
                                                attributeSet: attributeSet)
        indexItem.expirationDate = .distantFuture
        try await CSSearchableIndex.default().indexSearchableItems([indexItem])
    }

    static func removeItemFromSpotlight(itemId: String) async throws {
        try await CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [itemId])
    }

    static func reindexSpotlight(items: [SafeItem]? = nil) async throws {
        if let items {
            try await deleteSpotlightIndexFor(ids: items.map { $0.id })
        } else {
            try await deleteAllSpotlightIndex()
        }
        let items: [SafeItem] = try items ?? getAllSafeItems()
        try await indexItems(items, onlySpotlight: true)
    }

    static func deleteAllSpotlightIndex() async throws {
        try await CSSearchableIndex.default().deleteAllSearchableItems()
    }

    static func deleteSpotlightIndexFor(ids: [String]) async throws {
        try await CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ids)
    }
}

private extension UseCase {
    static func hashedEncryptedKeywords(for itemId: String) async throws -> [Data] {
        let coreCrypto: CoreCrypto = .shared

        guard let key: SafeItemKey = try safeItemRepository.getKey(for: itemId) else { return [] }
        guard let item: SafeItem = try safeItemRepository.getItem(id: itemId) else { return [] }
        let fields: [SafeItemField] = try safeItemRepository.getFields(for: itemId)

        let keyValue: Data = try coreCrypto.decrypt(value: key.value)

        guard let nameData = try item.encName.map({ try coreCrypto.decrypt(value: $0, key: keyValue) }) else { return [] }
        guard let name = String(data: nameData, encoding: .utf8) else { return [] }

        let itemNameWords: [Data] = try await name.hashedEncryptedKeywords { try coreCrypto.encrypt(value: $0, scope: .searchIndex) }
        let fieldsWords: [Data] = try await withThrowingTaskGroup(of: [Data].self) { taskGroup in
            for field in fields {
                taskGroup.addTask {
                    guard !field.isSecured else { return [] }
                    guard let valueData = try field.encValue.map({ try coreCrypto.decrypt(value: $0, key: keyValue) }) else { return [] }
                    guard let value = String(data: valueData, encoding: .utf8) else { return [] }
                    return try await value.hashedEncryptedKeywords { try coreCrypto.encrypt(value: $0, scope: .searchIndex) }
                }
            }
            return try await taskGroup.collect().reduce([], +)
        }
        return itemNameWords + fieldsWords
    }
}

private extension UseCase {
    static func startAlphabeticalPositionBinarySearch(itemName: String, items: [SafeItem]) throws -> Double? {
        if items.isEmpty {
            return 0.0
        } else {
            guard let firstItemkey = try getSafeItemKey(itemId: items.first?.id ?? "") else { return nil }
            guard let firstItemName = try getStringFromEncryptedData(data: items.first?.encName, key: firstItemkey)?.removingEmojis() else { return nil }
            let firstItemPosition: Double = items.first?.alphabeticalPosition ?? 0.0

            guard let lastItemkey = try getSafeItemKey(itemId: items.last?.id ?? "") else { return nil }
            guard let lastItemName = try getStringFromEncryptedData(data: items.last?.encName, key: lastItemkey)?.removingEmojis() else { return nil }
            let lastItemPosition: Double = items.last?.alphabeticalPosition ?? 0.0

            let cleanedItemName: String = itemName.removingEmojis()
            if cleanedItemName.compare(firstItemName, options: [.numeric, .diacriticInsensitive, .caseInsensitive]) == .orderedAscending {
                return firstItemPosition - 1.0
            } else if cleanedItemName.compare(lastItemName, options: [.numeric, .diacriticInsensitive, .caseInsensitive]) == .orderedDescending {
                return lastItemPosition + 1.0
            } else {
                return try findAlphabeticalPositionOfItemInItems(cleanedItemName: cleanedItemName, items: items)
            }
        }
    }

    static func findAlphabeticalPositionOfItemInItems(cleanedItemName: String, items: [SafeItem]) throws -> Double? {
        if items.count == 1 {
            guard let itemkey = try getSafeItemKey(itemId: items[0].id) else { return nil }
            guard let itemName = try getStringFromEncryptedData(data: items[0].encName, key: itemkey) else { return nil }

            if cleanedItemName.compare(itemName.removingEmojis(), options: [.numeric, .diacriticInsensitive, .caseInsensitive]) == .orderedAscending {
                return (items[0].alphabeticalPosition ?? 0.0) - 1.0
            } else {
                return (items[0].alphabeticalPosition ?? 0.0) + 1.0
            }
        } else if items.count == 2 {
            return ((items[0].alphabeticalPosition ?? 0.0) + (items[1].alphabeticalPosition ?? 0.0)) / 2.0
        } else {
            let middleIndex: Int = items.count / 2
            let middleItem: SafeItem = items[middleIndex]

            guard let middleItemkey = try getSafeItemKey(itemId: middleItem.id) else { return nil }
            guard let middleItemName = try getStringFromEncryptedData(data: middleItem.encName, key: middleItemkey) else { return nil }

            if cleanedItemName.compare(middleItemName.removingEmojis(), options: [.numeric, .diacriticInsensitive, .caseInsensitive]) == .orderedAscending {
                return try findAlphabeticalPositionOfItemInItems(cleanedItemName: cleanedItemName, items: [SafeItem](items[...middleIndex]))
            } else {
                return try findAlphabeticalPositionOfItemInItems(cleanedItemName: cleanedItemName, items: [SafeItem](items[middleIndex...]))
            }
        }
    }

    static func startConsultedAtPositionBinarySearch(itemConsultedAt: Date, items: [SafeItem]) throws -> Double? {
        if items.isEmpty {
            return 0.0
        } else {
            let firstItemPosition: Double = items.first?.consultedAtPosition ?? 0.0
            let lastItemPosition: Double = items.last?.consultedAtPosition ?? 0.0
            if itemConsultedAt > items.first?.consultedAt ?? .distantPast {
                return firstItemPosition - 1.0
            } else if itemConsultedAt < items.last?.consultedAt ?? .distantPast {
                return lastItemPosition + 1.0
            } else {
                return try findConsultedAtPositionOfItemInItems(itemConsultedAt: itemConsultedAt, items: items)
            }
        }
    }

    static func findConsultedAtPositionOfItemInItems(itemConsultedAt: Date, items: [SafeItem]) throws -> Double? {
        if items.count == 1 {
            if itemConsultedAt > (items[0].consultedAt ?? .distantPast) {
                return (items[0].consultedAtPosition ?? 0.0) - 1.0
            } else {
                return (items[0].consultedAtPosition ?? 0.0) + 1.0
            }
        } else if items.count == 2 {
            return ((items[0].consultedAtPosition ?? 0) + (items[1].consultedAtPosition ?? 0)) / 2.0
        } else {
            let middleIndex: Int = items.count / 2
            let middleItem: SafeItem = items[middleIndex]

            if itemConsultedAt > middleItem.consultedAt ?? .distantPast {
                return try findConsultedAtPositionOfItemInItems(itemConsultedAt: itemConsultedAt, items: [SafeItem](items[...middleIndex]))
            } else {
                return try findConsultedAtPositionOfItemInItems(itemConsultedAt: itemConsultedAt, items: [SafeItem](items[middleIndex...]))
            }
        }
    }

    static func startCreatedAtPositionBinarySearch(itemCreatedAt: Date, items: [SafeItem]) throws -> Double? {
        if items.isEmpty {
            return 0.0
        } else {
            let firstItemPosition: Double = items.first?.createdAtPosition ?? 0.0
            let lastItemPosition: Double = items.last?.createdAtPosition ?? 0.0
            if itemCreatedAt > items.first?.createdAt ?? .distantPast {
                return firstItemPosition - 1.0
            } else if itemCreatedAt < items.last?.createdAt ?? .distantPast {
                return lastItemPosition + 1.0
            } else {
                return try findCreatedAtPositionOfItemInItems(itemCreatedAt: itemCreatedAt, items: items)
            }
        }
    }

    static func findCreatedAtPositionOfItemInItems(itemCreatedAt: Date, items: [SafeItem]) throws -> Double? {
        if items.count == 1 {
            if itemCreatedAt > items[0].createdAt {
                return (items[0].createdAtPosition ?? 0.0) - 1.0
            } else {
                return (items[0].createdAtPosition ?? 0.0) + 1.0
            }
        } else if items.count == 2 {
            return ((items[0].createdAtPosition ?? 0) + (items[1].createdAtPosition ?? 0)) / 2.0
        } else {
            let middleIndex: Int = items.count / 2
            let middleItem: SafeItem = items[middleIndex]

            if itemCreatedAt > middleItem.createdAt {
                return try findCreatedAtPositionOfItemInItems(itemCreatedAt: itemCreatedAt, items: [SafeItem](items[...middleIndex]))
            } else {
                return try findCreatedAtPositionOfItemInItems(itemCreatedAt: itemCreatedAt, items: [SafeItem](items[middleIndex...]))
            }
        }
    }
}

private extension String {
    func hashedEncryptedKeywords(encryptionBlock: @escaping (_ keyword: String) async throws -> Data) async rethrows -> [Data] {
        try await withThrowingTaskGroup(of: Data.self) { taskGroup in
            let words: [String] = components(separatedBy: CharacterSet(charactersIn: ", "))
            for word in words {
                guard word.count > 1 else { continue }
                taskGroup.addTask {
                    try await encryptionBlock(word.cleanedForSearch)
                }
            }
            return try await taskGroup.collect()
        }
    }
}
