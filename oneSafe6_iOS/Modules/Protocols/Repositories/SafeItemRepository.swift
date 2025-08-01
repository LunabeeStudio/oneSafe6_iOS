//
//  SafeItemRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 17:21.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model
import Combine

public protocol SafeItemRepository {
    func getAllItems() throws -> [SafeItem]
    func getItems(parentId: String?) throws -> [SafeItem]
    func getAllNotDeletedItems() throws -> [SafeItem]
    func getNotAlphabeticallySortedItems() throws -> [SafeItem]
    func getNotConsultedAtSortedItems() throws -> [SafeItem]
    func getNotCreatedAtSortedItems() throws -> [SafeItem]
    func getAllDeletedItems() throws -> [SafeItem]
    func getDeletedItems(deletedParentId: String?) throws -> [SafeItem]
    func getItem(id: String) throws -> SafeItem?
    func getItems(ids: [String]) throws -> [SafeItem]
    func itemHasDeletedSubItems(id: String) throws -> Bool
    func itemHasNotDeletedSubItems(id: String) throws -> Bool
    func itemHasFields(id: String) throws -> Bool
    func save(items: [SafeItem]) throws
    func deleteItem(id: String) throws
    func deleteItems(ids: [String]) throws
    func deleteAllItems() throws

    func observeSafeItems(sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never>
    func observeFavoriteSafeItems(sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never>
    func observeSafeItem(id: String) throws -> AnyPublisher<SafeItem?, Never>
    func observeLastConsultedItems() throws -> AnyPublisher<[SafeItem], Never>
    func observeDeletedSafeItems() throws -> AnyPublisher<[SafeItem], Never>
    func observeDeletedSafeItems(deletedParentId: String?, sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never>
    func observeDeletedSafeItemsCount(deletedParentId: String?) throws -> AnyPublisher<Int, Never>
    func observeDeletedSafeItemsCount() throws -> AnyPublisher<Int, Never>
    func observeNotDeletedSafeItems(sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never>
    func observeNotDeletedSafeItems(parentId: String?, sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never>
    func safeItemsCount() throws -> Int
    func observeSafeItemsCount() throws -> AnyPublisher<Int, Never>
    func observeNotDeletedSafeItemsCount(parentId: String?) throws -> AnyPublisher<Int, Never>
    func observeNotDeletedSafeItemsCount() throws -> AnyPublisher<Int, Never>


// MARK: - Fields -
    func getAllFields() throws -> [SafeItemField]
    func getFields(for itemId: String) throws -> [SafeItemField]
    func getFields(for itemsIds: [String]) async throws -> [SafeItemField]
    func update(fields: [SafeItemField], for itemId: String) async throws
    func save(fields: [SafeItemField]) throws
    func deleteFields(ids: [String]) throws

    func observeSafeItemFields(itemId: String) throws -> AnyPublisher<[SafeItemField], Never>
    func observeSafeItemField(fieldId: String) throws -> AnyPublisher<SafeItemField?, Never>

// MARK: - Keys -
    func getAllKeys() throws -> [SafeItemKey]
    func getKey(for itemId: String) throws -> SafeItemKey?
    func getKeys(for itemsIds: [String]) async throws -> [SafeItemKey]
    func save(key: SafeItemKey) throws
    func save(keys: [SafeItemKey]) throws
}
