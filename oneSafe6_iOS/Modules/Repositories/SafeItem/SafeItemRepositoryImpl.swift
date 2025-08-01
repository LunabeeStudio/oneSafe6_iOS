//
//  SafeItemRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Francois Beta) on 29/07/2022 - 15:32.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Protocols
import Model
import Storage
import Combine
import RealmSwift
import Algorithms

final class SafeItemRepositoryImpl: SafeItemRepository {
    private let database: RealmManager = .shared
}

// MARK: - Items -
extension SafeItemRepositoryImpl {
    func getAllItems() throws -> [SafeItem] {
        try database.getAll()
    }

    func getItems(ids: [String]) throws -> [SafeItem] {
        try database.getAll { $0.id.in(ids) }
    }

    func getItems(parentId: String?) throws -> [SafeItem] {
        try database.getAll { $0.parentId == parentId }
    }

    func getAllNotDeletedItems() throws -> [SafeItem] {
        try database.getAll { $0.deletedAt == nil }
    }

    func getNotAlphabeticallySortedItems() throws -> [SafeItem] {
        try database.getAll { $0.alphabeticalPosition == nil }
    }

    func getNotConsultedAtSortedItems() throws -> [SafeItem] {
        try database.getAll { $0.consultedAtPosition == nil }
    }

    func getNotCreatedAtSortedItems() throws -> [SafeItem] {
        try database.getAll { $0.createdAtPosition == nil }
    }

    func getAllDeletedItems() throws -> [SafeItem] {
        try database.getAll { $0.deletedAt != nil }
    }

    func getDeletedItems(deletedParentId: String?) throws -> [SafeItem] {
        try database.getAll { $0.deletedAt != nil && $0.deletedParentId == deletedParentId }
    }

    func getItem(id: String) throws -> SafeItem? {
        try database.get(id)
    }

    func save(items: [SafeItem]) throws {
        try database.save(items)
    }

    func deleteItem(id: String) throws {
        try database.delete(objectOfType: SafeItem.self, id: id)
        try database.delete(objectOfType: SafeItemKey.self, id: id)
        try database.deleteAll(objectsOfType: SafeItemField.self, withFilter: { $0.itemId == id })
    }

    func deleteItems(ids: [String]) throws {
        try database.delete(objectsOfType: SafeItem.self, ids: ids)
        try database.delete(objectsOfType: SafeItemKey.self, ids: ids)
        let fieldsToDelete: [SafeItemField] = try database.getAll { $0.itemId.in(ids) }
        try database.delete(objectsOfType: SafeItemField.self, ids: fieldsToDelete.map { $0.id })
    }

    func deleteAllItems() throws {
        try database.deleteAll(objectsOfType: SafeItem.self)
        try database.deleteAll(objectsOfType: SafeItemField.self)
        try database.deleteAll(objectsOfType: SafeItemKey.self)
    }

    func itemHasNotDeletedSubItems(id: String) throws -> Bool {
        try database.getFirst(SafeItem.self, where: { item in
            item.parentId == id && item.deletedAt == nil
        }) != nil
    }

    func itemHasDeletedSubItems(id: String) throws -> Bool {
        try database.getFirst(SafeItem.self, where: { item in
            item.parentId == id && item.deletedAt != nil
        }) != nil
    }

    func observeSafeItems(sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(
            objectsOfType: SafeItem.self,
            sortingKeyPath: sortingKeyPath,
            ascending: ascending ?? true
        )
    }

    func observeFavoriteSafeItems(sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(
            objectsOfType: SafeItem.self,
            withFilter: { item in item.isFavorite },
            sortingKeyPath: sortingKeyPath,
            ascending: ascending ?? true
        )
    }

    func observeSafeItem(id: String) throws -> AnyPublisher<SafeItem?, Never> {
        try database.publisher(objectOfType: SafeItem.self, withPrimaryKey: id)
    }

    func observeLastConsultedItems() throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(
            objectsOfType: SafeItem.self,
            withFilter: { $0.consultedAt != nil && $0.deletedAt == nil },
            sortingKeyPath: "consultedAt",
            ascending: false
        )
    }

    func observeDeletedSafeItems() throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(objectsOfType: SafeItem.self, withFilter: { $0.deletedAt != nil })
    }

    func observeNotDeletedSafeItems(sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(
            objectsOfType: SafeItem.self,
            withFilter: { $0.deletedAt == nil },
            sortingKeyPath: sortingKeyPath,
            ascending: ascending ?? true
        )
    }

    func observeDeletedSafeItems(deletedParentId: String?, sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(
            objectsOfType: SafeItem.self,
            withFilter: { $0.deletedParentId == deletedParentId && $0.deletedAt != nil },
            sortingKeyPath: sortingKeyPath,
            ascending: ascending ?? true
        )
    }

    func observeDeletedSafeItemsCount(deletedParentId: String?) throws -> AnyPublisher<Int, Never> {
        try database.countPublisher(objectsOfType: SafeItem.self) { $0.deletedParentId == deletedParentId && $0.deletedAt != nil }
    }

    func observeNotDeletedSafeItems(parentId: String?, sortingKeyPath: String?, ascending: Bool?) throws -> AnyPublisher<[SafeItem], Never> {
        try database.publisher(
            objectsOfType: SafeItem.self,
            withFilter: { $0.parentId == parentId && $0.deletedAt == nil },
            sortingKeyPath: sortingKeyPath,
            ascending: ascending ?? true
        )
    }

    func safeItemsCount() throws -> Int {
        try database.getAll(objectOfType: SafeItem.self).count
    }

    func observeSafeItemsCount() throws -> AnyPublisher<Int, Never> {
        try database.countPublisher(objectsOfType: SafeItem.self)
    }

    func observeNotDeletedSafeItemsCount(parentId: String?) throws -> AnyPublisher<Int, Never> {
        try database.countPublisher(objectsOfType: SafeItem.self) { $0.parentId == parentId && $0.deletedAt == nil }
    }

    func observeDeletedSafeItemsCount() throws -> AnyPublisher<Int, Never> {
        try database.countPublisher(objectsOfType: SafeItem.self) { $0.deletedAt != nil }
    }

    func observeNotDeletedSafeItemsCount() throws -> AnyPublisher<Int, Never> {
        try database.countPublisher(objectsOfType: SafeItem.self) { $0.deletedAt == nil }
    }
}

// MARK: - Fields -
extension SafeItemRepositoryImpl {
    func getAllFields() throws -> [SafeItemField] {
        try database.getAll()
    }

    func getFields(for itemId: String) throws -> [SafeItemField] {
        try database.getAll { $0.itemId == itemId }
    }

    func getFields(for itemsIds: [String]) async throws -> [SafeItemField] {
        let allFields: [SafeItemField] = try database.getAll()
        var fieldsByItemId: [String: [SafeItemField]] = .init(grouping: allFields, by: \.itemId)
        let idsToDelete: [String] = [String](Set(fieldsByItemId.keys).subtracting(Set(itemsIds)))
        idsToDelete.forEach { fieldsByItemId[$0] = nil }
        return fieldsByItemId.values.joined { _, _ in [] }
    }

    func update(fields: [SafeItemField], for itemId: String) async throws {
        var fieldsToSave: [SafeItemField] = []
        fields.forEach { field in
            var fieldWithUpdatedAt: SafeItemField = field
            fieldWithUpdatedAt.updatedAt = Date()
            fieldsToSave.append(fieldWithUpdatedAt)
        }

        let currentFieldsIds: Set<String> = .init(try database.getAll(objectOfType: SafeItemField.self) { $0.itemId == itemId }.map(\.id))
        let fieldsIds: Set<String> = .init(fields.map(\.id))
        let fieldsIdsToDelete: [String] = [String](currentFieldsIds.subtracting(fieldsIds))
        try database.save(fieldsToSave)
        try database.delete(objectsOfType: SafeItemField.self, ids: fieldsIdsToDelete)
    }

    func save(fields: [SafeItemField]) throws {
        try database.save(fields)
    }

    func deleteFields(ids: [String]) throws {
        try database.delete(objectsOfType: SafeItemField.self, ids: ids)
    }

    func observeSafeItemFields(itemId: String) throws -> AnyPublisher<[SafeItemField], Never> {
        try database.publisher(objectsOfType: SafeItemField.self, withFilter: { $0.itemId == itemId })
    }

    func observeSafeItemField(fieldId: String) throws -> AnyPublisher<SafeItemField?, Never> {
        try database.publisher(objectOfType: SafeItemField.self, withPrimaryKey: fieldId)
    }

    func itemHasFields(id: String) throws -> Bool {
        try database.getFirst(SafeItemField.self, where: { field in
            field.itemId == id
        }) != nil
    }
}

// MARK: - Keys -
extension SafeItemRepositoryImpl {
    func getAllKeys() throws -> [SafeItemKey] {
        try database.getAll()
    }

    func getKey(for itemId: String) throws -> SafeItemKey? {
        try database.get(itemId)
    }

    func getKeys(for itemsIds: [String]) async throws -> [SafeItemKey] {
        try await withThrowingTaskGroup(of: SafeItemKey?.self) { taskGroup in
            for itemId in itemsIds {
                taskGroup.addTask { [weak self] in
                    try self?.database.get(itemId)
                }
            }
            return try await taskGroup.collect().compactMap { $0 }
        }
    }

    func save(key: SafeItemKey) throws {
        try database.save(key)
    }

    func save(keys: [SafeItemKey]) throws {
        try database.save(keys)
    }
}
