//
//  SearchRepositoryImpl.swift
//  oneSafe
//
//  Created by Lunabee Studio (Francois Beta) on 29/07/2022 - 15:32.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Combine
import Protocols
import Model
import Storage
import RealmSwift
import RegexBuilder
import CoreSpotlight

final class SearchRepositoryImpl: NSObject, SearchRepository {
    private let database: RealmManager = .shared
    private let cacheDuration: Double = 20.0

    private var isCacheUpToDate: Bool = false

    private var cache: Index = [:] {
        didSet { isCacheUpToDate = true }
    }
    private var cacheTimer: Timer?

    private var reindexAllSpotlightItems: (() -> Void)?
    private var reindexSpotlightItemsForIds: ((_ itemsIds: [String]) -> Void)?

    func reset() {
        stopCacheTimer()
        clearCache()
    }

    func getIndex(decrypt: @escaping DecryptionBlock) async throws -> Index {
        if isCacheUpToDate {
            startCacheTimer()
            return cache
        } else {
            let newCache: Index = try await generateSearchIndexCache(decrypt: decrypt)
            cache = newCache
            startCacheTimer()
            return newCache
        }
    }

    func indexItem(id: String, keywords: [Data]) throws {
        let entries: [IndexWordEntry] = keywords.map { .init(encWord: $0, match: id) }
        try database.save(entries)
        isCacheUpToDate = false
    }

    func unindexItem(id: String) throws {
        try database.deleteAll(objectsOfType: IndexWordEntry.self) { $0.match == id }
        isCacheUpToDate = false
    }

    func deleteAll() throws {
        try database.deleteAll(objectsOfType: IndexWordEntry.self)
        isCacheUpToDate = false
    }

    func updateLastSearchQueries(_ queries: [SearchQuery]) throws {
        try database.deleteAll(objectsOfType: SearchQuery.self)
        try database.save(queries)
    }

    func getLastSearchQueries() throws -> [SearchQuery] {
        try database.getAll()
            .sorted(by: { $0.date > $1.date })
    }

    func getAllIndexWordEntries() throws -> [IndexWordEntry] {
        try database.getAll()
    }

    func save(indexWordEntries: [IndexWordEntry]) throws {
        try database.save(indexWordEntries)
    }

    func getAllSearchQueries() throws -> [SearchQuery] {
        try database.getAll()
    }

    func save(searchQueries: [SearchQuery]) throws {
        try database.save(searchQueries)
    }

    func observeLastSearchQueries() throws -> AnyPublisher<[SearchQuery], Never> {
        try database.publisher(
            objectsOfType: SearchQuery.self,
            sortingKeyPath: "date",
            ascending: false
        )
    }
}

    // MARK: - Autolock -
    // Save the content of the search bar in the keychain to discard it when autolocking the app.
extension SearchRepositoryImpl {
    func saveSearchText(_ text: String) throws {
        try FileDirectoryManager.shared.save(searchText: text)
    }

    func getSavedSearchText() throws -> String? {
        try FileDirectoryManager.shared.savedSearchText()
    }

    func deleteSavedSearchText() throws {
        try FileDirectoryManager.shared.deleteSavedSearchText()
    }
}

extension SearchRepositoryImpl {
    func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void) {
        reindexAllSpotlightItems?()
    }

    func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        reindexSpotlightItemsForIds?(identifiers)
    }

    func setSpotlightReindexingCallbacks(reindexAllSpotlightItems: @escaping () -> Void, reindexSpotlightItemsForIds: @escaping (_ itemsIds: [String]) -> Void) {
        self.reindexAllSpotlightItems = reindexAllSpotlightItems
        self.reindexSpotlightItemsForIds = reindexSpotlightItemsForIds
    }
}

// MARK: - Cache management -
private extension SearchRepositoryImpl {
    func startCacheTimer() {
        stopCacheTimer()
        let timer: Timer = .init(timeInterval: cacheDuration, repeats: false) { [weak self] _ in
            self?.clearCache()
        }
        cacheTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopCacheTimer() {
        cacheTimer?.invalidate()
        cacheTimer = nil
    }

    func clearCache() {
        cache = [:]
        isCacheUpToDate = false
    }

    func generateSearchIndexCache(decrypt: @escaping DecryptionBlock) async throws -> SearchRepository.Index {
        let groupedResults: SearchRepository.Index = try await withThrowingTaskGroup(of: (String, String)?.self,
                                                                                     returning: SearchRepository.Index.self) { taskGroup in
            let indexWordEntries: [IndexWordEntry] = try database.getAll()

            for entry in indexWordEntries {
                taskGroup.addTask {
                    let wordData: Data = try decrypt(entry.encWord)
                    guard let word = String(data: wordData, encoding: .utf8) else { return nil }
                    return (word, entry.match)
                }
            }

            var results: SearchRepository.Index = [:]
            for try await result in taskGroup {
                guard let result else { continue }
                results[result.0] = (results[result.0] ?? []) + [result.1]
            }
            return results
        }

        return groupedResults
    }
}
