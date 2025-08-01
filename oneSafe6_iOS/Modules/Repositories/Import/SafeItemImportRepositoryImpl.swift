//
//  SafeItemImportRepositoryImpl.swift
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

final class SafeItemImportRepositoryImpl: SafeItemImportRepository {
    private let database: RealmManager = .shared

    func getAllDataToImport(progress: Progress) async throws -> (items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey]) {
        let importItems: [SafeItemImport] = try getAllItems()
        let importFields: [SafeItemFieldImport] = try getAllFields()
        let importKeys: [SafeItemKeyImport] = try getAllKeys()

        let worker: ProgressWorker = .init(progress: progress)
        worker.progress.totalUnitCount = Int64(importItems.count + importFields.count + importKeys.count)

        async let items: [SafeItem] = try withThrowingTaskGroup(of: SafeItem.self) { taskGroup in
            for item in importItems {
                taskGroup.addTask {
                    await worker.increment(1)
                    return item.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let fields: [SafeItemField] = try withThrowingTaskGroup(of: SafeItemField.self) { taskGroup in
            for field in importFields {
                taskGroup.addTask {
                    await worker.increment(1)
                    return field.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }

        async let keys: [SafeItemKey] = try withThrowingTaskGroup(of: SafeItemKey.self) { taskGroup in
            for key in importKeys {
                taskGroup.addTask {
                    await worker.increment(1)
                    return key.toAppModel()
                }
            }
            return try await taskGroup.collect()
        }
        return try await (items, fields, keys)
    }
}

// MARK: - Items -
extension SafeItemImportRepositoryImpl {
    func getAllItems() throws -> [SafeItemImport] {
        try database.getAll()
    }

    func getRootItems() throws -> [SafeItemImport] {
        try database.getAll { $0.parentId == nil }
    }

    func save(items: [SafeItemImport]) throws {
        try database.save(items)
    }
}

// MARK: - Fields -
extension SafeItemImportRepositoryImpl {
    func getAllFields() throws -> [SafeItemFieldImport] {
        try database.getAll()
    }

    func save(fields: [SafeItemFieldImport]) throws {
        try database.save(fields)
    }

    func deleteAllItems() throws {
        try database.deleteAll(objectsOfType: SafeItemImport.self)
        try database.deleteAll(objectsOfType: SafeItemFieldImport.self)
    }
}

// MARK: - Keys -
extension SafeItemImportRepositoryImpl {
    func getAllKeys() throws -> [SafeItemKeyImport] {
        try database.getAll()
    }

    func save(keys: [SafeItemKeyImport]) throws {
        try database.save(keys)
    }

    func deleteAllKeys() throws {
        try database.deleteAll(objectsOfType: SafeItemKeyImport.self)
    }
}

// MARK: - Model conversion -
private extension SafeItemImport {
    func toAppModel() -> SafeItem {
        .init(id: id,
              encName: encName,
              encColor: encColor,
              iconId: iconId,
              parentId: parentId,
              deletedParentId: deletedParentId,
              isFavorite: isFavorite,
              createdAt: createdAt,
              updatedAt: updatedAt,
              deletedAt: deletedAt,
              position: position)
    }
}

private extension SafeItemFieldImport {
    func toAppModel() -> SafeItemField {
        .init(id: id,
              encName: encName,
              position: position,
              itemId: itemId,
              encPlaceholder: encPlaceholder,
              encValue: encValue,
              showPrediction: showPrediction,
              encKind: encKind,
              createdAt: createdAt,
              updatedAt: updatedAt,
              isItemIdentifier: isItemIdentifier,
              encFormattingMask: encFormattingMask,
              encSecureDisplayMask: encSecureDisplayMask,
              isSecured: isSecured)
    }
}

private extension SafeItemKeyImport {
    func toAppModel() -> SafeItemKey {
        .init(id: id, value: value)
    }
}
