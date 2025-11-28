//
//  RealmManager.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions
import Errors
import Realm
import RealmSwift
import Combine

public final class RealmManager {
    public static let shared: RealmManager = .init()
    private let publishersQueue: DispatchQueue = DispatchQueue(label: Bundle.stCurrentBundleIdentifier, qos: .userInitiated)
    private let cryptoKeyLength: Int = 64
    private let maximumDataBytesSize: Int = 500 * 1024 * 1024
    private let maximumKeysBytesSize: Int = 200 * 1024 * 1024
    private let maximumImportBytesSize: Int = 500 * 1024 * 1024
    private let maximumSearchBytesSize: Int = 500 * 1024 * 1024
    private let maximumBubblesBytesSize: Int = 500 * 1024 * 1024

    private var dataConfiguration: Realm.Configuration?
    private var importConfiguration: Realm.Configuration?
    private var searchConfiguration: Realm.Configuration?
    private var bubblesConfiguration: Realm.Configuration?

    private static var dataRealmVersion: UInt64 = 4
    private static var keysRealmVersion: UInt64 = 1
    private static var importRealmVersion: UInt64 = 2
    private static var searchRealmVersion: UInt64 = 3
    private static var bubblesRealmVersion: UInt64 = 3

    public var isLoaded: CurrentValueSubject<Bool, Never> = .init(false)

    private init() {}

    public func loadDatabases() throws {
        try loadDatabase()
        try loadImportDatabase()
        try loadSearchDatabase()
        try loadBubblesDatabase()
        isLoaded.send(true)
    }

    public func unloadDatabases() {
        dataConfiguration = nil
        importConfiguration = nil
        searchConfiguration = nil
        bubblesConfiguration = nil
        isLoaded.send(false)
    }

    func loadDatabase() throws {
        let configuration: Realm.Configuration = try createDataConfiguration()
        dataConfiguration = configuration
    }

    func loadImportDatabase() throws {
        let configuration: Realm.Configuration = try createImportConfiguration()
        importConfiguration = configuration
    }

    func loadSearchDatabase() throws {
        let configuration: Realm.Configuration = try createSearchConfiguration()
        searchConfiguration = configuration
    }

    func loadBubblesDatabase() throws {
        let configuration: Realm.Configuration = try createBubblesConfiguration()
        bubblesConfiguration = configuration
    }

    public func deleteDatabase() throws {
        unloadDatabases()
        let directoryUrl: URL = try directoryUrl(create: false)
        guard FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) else { return }
        try FileManager.default.removeItem(at: directoryUrl)
        try FileDirectoryManager.shared.deleteDatabaseName()
        try FileDirectoryManager.shared.deleteImportDatabaseName()
        try FileDirectoryManager.shared.deleteSearchDatabaseName()
        try FileDirectoryManager.shared.deleteBubblesDatabaseName()
    }
}

public extension RealmManager {
    func doesContain<AppModel: RealmStorable>(objectOfType: AppModel.Type) throws -> Bool {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        return !realm.objects(AppModel.RModel.self).isEmpty
    }

    func getLastID<AppModel: RealmStorable>(objectOfType: AppModel.Type) throws -> AppModel.RModel.ID? where AppModel.RModel.ID: _HasPersistedType, AppModel.RModel.ID.PersistedType: SortableType {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        return realm.objects(AppModel.RModel.self).sorted(by: \.id).last?.id
    }

    /// Get all objects of the given type stored in Realm.
    func getAll<AppModel: RealmStorable>(withFilter filter: ((Query<AppModel.RModel>) -> Query<Bool>)? = nil, sortingKeyPath: String? = nil, ascending: Bool = true) throws -> [AppModel] {
        try getAll(objectOfType: AppModel.self, withFilter: filter, sortingKeyPath: sortingKeyPath, ascending: ascending)
    }

    func getFirst<AppModel: RealmStorable>(_ type: AppModel.Type, where filter: (Query<AppModel.RModel>) -> Query<Bool>) throws -> AppModel? {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        return try realm.objects(AppModel.RModel.self).where(filter).first?.toAppModel()
    }

    /// Get all objects of the given type stored in Realm.
    func getAll<AppModel: RealmStorable>(objectOfType: AppModel.Type, withFilter filter: ((Query<AppModel.RModel>) -> Query<Bool>)? = nil, sortingKeyPath: String? = nil, ascending: Bool = true) throws -> [AppModel] {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        var results: Results<AppModel.RModel>
        if let filter {
            results = realm.objects(AppModel.RModel.self).where(filter)
        } else {
            results = realm.objects(AppModel.RModel.self)
        }
        if let sortingKeyPath {
            results = results.sorted(byKeyPath: sortingKeyPath, ascending: ascending)
        }
        let objects: [AppModel] = try results.compactMap { try $0.toAppModel() }
        return objects
    }

    /// Get the object using the primaryKey of the given type stored in Realm.
    func get<AppModel: RealmStorable>(_ id: AppModel.RModel.ID) throws -> AppModel? {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let object: AppModel? = try realm.object(ofType: AppModel.RModel.self, forPrimaryKey: id)?.toAppModel()
        return object
    }

    /// Get the object using the primaryKey of the given type stored in Realm.
    func get<AppModel: RealmStorable>(_ objectOfType: AppModel.Type = AppModel.self, id: AppModel.RModel.ID) throws -> AppModel? {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let object: AppModel? = try realm.object(ofType: AppModel.RModel.self, forPrimaryKey: id)?.toAppModel()
        return object
    }

    /// Saves the given object to Realm.
    func save<AppModel: RealmStorable>(_ object: AppModel?) throws {
        guard let object else { return }
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let objectToSave: AppModel.RModel = try .from(appModel: object)
        try realm.write { realm.add(objectToSave, update: .modified) }
    }

    /// Saves the given objects to Realm.
    func save<AppModel: RealmStorable>(_ objects: [AppModel]) throws {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let objectsToSave: [AppModel.RModel] = try objects.compactMap { try .from(appModel: $0) }
        try realm.write { realm.add(objectsToSave, update: .modified) }
    }

    func update<AppModel: RealmStorable, Value>(objectsOfType: AppModel.Type, value: Value, forKey: String, filter: ((Query<AppModel.RModel>) -> Query<Bool>)? = nil) throws {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let results: Results<AppModel.RModel>
        if let filter {
            results = realm.objects(AppModel.RModel.self).where(filter)
        } else {
            results = realm.objects(AppModel.RModel.self)
        }
        try realm.write {
            results.setValue(value, forKey: forKey)
        }
    }

    /// Delete the given object from Realm.
    func delete<AppModel: RealmStorable>(objectOfType: AppModel.Type, id: AppModel.RModel.ID) throws {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        guard let objectToDelete: AppModel.RModel = realm.object(ofType: AppModel.RModel.self, forPrimaryKey: id) else { return }
        try realm.write { realm.delete(objectToDelete) }
    }

    /// Delete the given objects from Realm.
    func delete<AppModel: RealmStorable>(objectsOfType: AppModel.Type, ids: [AppModel.RModel.ID]) throws {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let objectsToDelete: [AppModel.RModel] = ids.compactMap { realm.object(ofType: AppModel.RModel.self, forPrimaryKey: $0) }
        try realm.write { realm.delete(objectsToDelete) }
    }

    /// Delete all the objects of the given type from Realm.
    func deleteAll<AppModel: RealmStorable>(objectsOfType: AppModel.Type, withFilter filter: ((Query<AppModel.RModel>) -> Query<Bool>)? = nil) throws {
        let realm: Realm = try self.getRealm(for: AppModel.RModel.self)
        let objectsToDelete: Results<AppModel.RModel>
        if let filter {
            objectsToDelete = realm.objects(AppModel.RModel.self).where(filter)
        } else {
            objectsToDelete = realm.objects(AppModel.RModel.self)
        }
        try realm.write { realm.delete(objectsToDelete) }
    }

    func publisher<AppModel: RealmStorable>(objectsOfType: AppModel.Type, withFilter filter: ((Query<AppModel.RModel>) -> Query<Bool>)? = nil, sortingKeyPath: String? = nil, ascending: Bool = true) throws -> AnyPublisher<[AppModel], Never>  {
        let realm: Realm = try getRealm(for: objectsOfType.RModel)
        var objects: Results<AppModel.RModel>
        if let filter {
            objects = realm.objects(AppModel.RModel.self).where(filter)
        } else {
            objects = realm.objects(AppModel.RModel.self)
        }
        if let sortingKeyPath {
            objects = objects.sorted(byKeyPath: sortingKeyPath, ascending: ascending)
        }
        let publisher: AnyPublisher<[AppModel], Never> = objects
            .collectionPublisher
            .subscribe(on: self.publishersQueue)
            .threadSafeReference()
            .compactMap { collection in
                guard self.isLoaded.value else { return nil }
                return collection.compactMap { try? $0.toAppModel() }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
        return publisher
    }

    func publisher<AppModel: RealmStorable>(objectOfType: AppModel.Type, withPrimaryKey: AppModel.RModel.ID) throws -> AnyPublisher<AppModel?, Never>  {
        let realm: Realm = try getRealm(for: objectOfType.RModel)
        let objects: Results<AppModel.RModel> = realm.objects(AppModel.RModel.self)
        let publisher: AnyPublisher<AppModel?, Never> = objects
            .filter("id == %@", withPrimaryKey)
            .collectionPublisher
            .subscribe(on: self.publishersQueue)
            .threadSafeReference()
            .compactMap { collection in
                guard self.isLoaded.value else { return nil }
                return try? collection.first?.toAppModel()
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
        return publisher
    }

    func countPublisher<AppModel: RealmStorable>(objectsOfType: AppModel.Type, withFilter filter: ((Query<AppModel.RModel>) -> Query<Bool>)? = nil) throws -> AnyPublisher<Int, Never>  {
        let realm: Realm = try getRealm(for: objectsOfType.RModel)
        var objects: Results<AppModel.RModel>
        if let filter {
            objects = realm.objects(AppModel.RModel.self).where(filter)
        } else {
            objects = realm.objects(AppModel.RModel.self)
        }
        let publisher: AnyPublisher<Int, Never> = objects
            .collectionPublisher
            .subscribe(on: self.publishersQueue)
            .map { $0.freeze() }
            .buffer(size: 32, prefetch: .keepFull, whenFull: .dropOldest)
            .compactMap {
                guard self.isLoaded.value else { return nil }
                return $0.count
            }
            .replaceError(with: 0)
            .eraseToAnyPublisher()
        return publisher
    }
}

// MARK: - Database configuration -
private extension RealmManager {
    func createDataConfiguration() throws -> Realm.Configuration {
        let classes: [ObjectBase.Type] = [RSafeItem.self,
                                          RSafeItemField.self,
                                          RSafeItemKey.self]
        let databaseUrl: URL = try directoryUrl().appendingPathComponent(databaseName())
        let userConfig: Realm.Configuration = Realm.Configuration(fileURL: databaseUrl, schemaVersion: Self.dataRealmVersion, migrationBlock: { _, _ in }, shouldCompactOnLaunch: { [weak self] totalBytes, usedBytes in
            guard let self else { return false }
            return totalBytes > self.maximumDataBytesSize && Double(usedBytes) / Double(totalBytes) < 0.5
        }, objectTypes: classes)
        return userConfig
    }

    func createImportConfiguration() throws -> Realm.Configuration {
        let classes: [ObjectBase.Type] = [RSafeItemImport.self,
                                          RSafeItemFieldImport.self,
                                          RSafeItemKeyImport.self,
                                          RContactImport.self,
                                          RContactLocalKeyImport.self,
                                          RSafeMessageImport.self,
                                          REncConversationImport.self]
        let databaseUrl: URL = try directoryUrl().appendingPathComponent(importDatabaseName())
        let userConfig: Realm.Configuration = Realm.Configuration(fileURL: databaseUrl, schemaVersion: Self.importRealmVersion, migrationBlock: { _, _ in }, shouldCompactOnLaunch: { [weak self] totalBytes, usedBytes in
            guard let self else { return false }
            return totalBytes > self.maximumImportBytesSize && Double(usedBytes) / Double(totalBytes) < 0.5
        }, objectTypes: classes)
        return userConfig
    }

    func createSearchConfiguration() throws -> Realm.Configuration {
        let classes: [ObjectBase.Type] = [RIndexWordEntry.self, RSearchQuery.self]
        let databaseUrl: URL = try directoryUrl().appendingPathComponent(searchDatabaseName())
        let userConfig: Realm.Configuration = Realm.Configuration(fileURL: databaseUrl, schemaVersion: Self.searchRealmVersion, migrationBlock: { _, _ in }, shouldCompactOnLaunch: { [weak self] totalBytes, usedBytes in
            guard let self else { return false }
            return totalBytes > self.maximumSearchBytesSize && Double(usedBytes) / Double(totalBytes) < 0.5
        }, objectTypes: classes)
        return userConfig
    }

    func createBubblesConfiguration() throws -> Realm.Configuration {
        let classes: [ObjectBase.Type] = [RContact.self,
                                          RContactLocalKey.self,
                                          REncConversation.self,
                                          REncDoubleRatchetKey.self,
                                          REncHandShakeData.self,
                                          REnqueuedMessage.self,
                                          RSafeMessage.self,
                                          RSentMessage.self]
        let databaseUrl: URL = try directoryUrl().appendingPathComponent(bubblesDatabaseName())
        let userConfig: Realm.Configuration = Realm.Configuration(fileURL: databaseUrl, schemaVersion: Self.bubblesRealmVersion, migrationBlock: { _, _ in }, shouldCompactOnLaunch: { [weak self] totalBytes, usedBytes in
            guard let self else { return false }
            return totalBytes > self.maximumBubblesBytesSize && Double(usedBytes) / Double(totalBytes) < 0.5
        }, objectTypes: classes)
        return userConfig
    }

    func directoryUrl(create: Bool = true) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appendingPathComponent("db")
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}

// MARK: - Database selector -
private extension RealmManager {
    func getRealm(for objectType: ObjectBase.Type) throws -> Realm {
        let loadedConfigurations: [Realm.Configuration] = [dataConfiguration, importConfiguration, searchConfiguration, bubblesConfiguration].compactMap { $0 }
        guard let configuration = loadedConfigurations.first(where: { $0.objectTypes?.contains { $0 == objectType } == true }) else { throw AppError.storageNoDatabaseConfigurationLoaded }
        return try Realm(configuration: configuration)
    }
}

// MARK: - Database names -
private extension RealmManager {
    func databaseName() -> String {
        do {
            return try FileDirectoryManager.shared.databaseName() ?? FileDirectoryManager.shared.createNewDatabaseName()
        } catch {
            return "db"
        }
    }

    func importDatabaseName() -> String {
        do {
            return try FileDirectoryManager.shared.importDatabaseName() ?? FileDirectoryManager.shared.createNewImportDatabaseName()
        } catch {
            return "idb"
        }
    }

    func searchDatabaseName() -> String {
        do {
            return try FileDirectoryManager.shared.searchDatabaseName() ?? FileDirectoryManager.shared.createNewSearchDatabaseName()
        } catch {
            return "srch"
        }
    }

    func bubblesDatabaseName() -> String {
        do {
            return try FileDirectoryManager.shared.bubblesDatabaseName() ?? FileDirectoryManager.shared.createNewBubblesDatabaseName()
        } catch {
            return "bbls"
        }
    }
}
