//
//  SafeItemImportRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 27/02/2023 - 10:51.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model

public protocol SafeItemImportRepository {
    func getAllDataToImport(progress: Progress) async throws -> (items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey])
    func getAllItems() throws -> [SafeItemImport]
    func getRootItems() throws -> [SafeItemImport]
    func save(items: [SafeItemImport]) throws
    func getAllFields() throws -> [SafeItemFieldImport]
    func save(fields: [SafeItemFieldImport]) throws
    func deleteAllItems() throws
    func getAllKeys() throws -> [SafeItemKeyImport]
    func save(keys: [SafeItemKeyImport]) throws
    func deleteAllKeys() throws
}
