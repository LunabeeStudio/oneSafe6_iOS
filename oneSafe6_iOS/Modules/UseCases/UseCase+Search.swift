//
//  UseCase+Search.swift
//  UseCases
//
//  Created by Lunabee Studio (Alexandre Cools) on 13/10/2022 - 2:18 PM.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Model
import CoreCrypto
import Protocols
import Combine
import MobileCoreServices
import Extensions
import TLDExtractSwift

public extension UseCase {
    static func getSearchDelayValue() -> Int {
        Constant.Delay.search
    }

    static func shouldStartSearch(for text: String) -> Bool {
        text.count >= 2
    }

    static func sortResultsForSearchByUpdatedAt(_ results: [SafeItem]) -> [SafeItem] {
        results.sorted { $0.updatedAt == $1.updatedAt ? $0.position < $1.position : $0.updatedAt > $1.updatedAt }
    }

    static func sortResultsForSearchByConsultedAt(_ results: [SafeItem]) -> [SafeItem] {
        results.sorted { $0.consultedAt == $1.consultedAt ? $0.position < $1.position : ($0.consultedAt ?? .distantPast) > ($1.consultedAt ?? .distantPast) }
    }

    static func resetSearchCache() async {
        searchRepository.reset()
    }

    static func search(_ query: String) async throws -> [SafeItem] {
        guard !query.isEmpty else { return [] }

        let coreCrypto: CoreCrypto = .shared

        let cache: SearchRepository.Index = try await searchRepository.getIndex { encData in
            try coreCrypto.decrypt(value: encData, scope: .searchIndex)
        }

        let queryKeywords: [String] = .init(Set<String>(query.keywords))
        let matchingIds: [String: KeywordsMatchingInfo] = try await withThrowingTaskGroup(of: [String: KeywordsMatchingInfo].self) { taskGroup in
            for (word, ids) in cache {
                taskGroup.addTask {
                    var queryKeywordsMatchingCountById: [String: KeywordsMatchingInfo] = [:]
                    queryKeywords.forEach { queryKeyWord in
                        let isWordMatching: Bool = word.contains(queryKeyWord)
                        if isWordMatching {
                            ids.forEach { id in
                                var currentMatchingKeywords: KeywordsMatchingInfo = queryKeywordsMatchingCountById[id] ?? (.init(), 0)
                                currentMatchingKeywords.matchedKeywords.insert(queryKeyWord)
                                currentMatchingKeywords.totalMatchesCount += 1
                                queryKeywordsMatchingCountById[id] = currentMatchingKeywords
                            }
                        }
                    }
                    return queryKeywordsMatchingCountById
                }
            }
            return try await taskGroup.collect().reduce([:]) {
                $0.merging($1) {
                    var result: KeywordsMatchingInfo = $0
                    result.matchedKeywords.formUnion($1.matchedKeywords)
                    result.totalMatchesCount += $1.totalMatchesCount
                    return result
                }
            }
        }

        let resultsItems: [SafeItem] = try await withThrowingTaskGroup(of: SafeItem?.self) { taskGroup in
            for id in Set(matchingIds.keys) {
                taskGroup.addTask {
                    try safeItemRepository.getItem(id: id)
                }
            }
            return try await taskGroup.collect().compactMap { $0 }
        }

        let sortedResultsItems: [SafeItem] = resultsItems.sorted {
            // Getting keywords info values.
            // Count of different keywords matching for the current item.
            let firstElementDifferentKeywordsMatchCount: Int = matchingIds[$0.id]?.matchedKeywords.count ?? 0
            let secondElementDifferentKeywordsMatchCount: Int = matchingIds[$1.id]?.matchedKeywords.count ?? 0

            // Count of total maches of the current item (e.g. if searching "apple" and the item contains this word 3 times,
            // this count will be 3.
            let firstElementScore: Int = matchingIds[$0.id]?.totalMatchesCount ?? 0
            let secondElementScore: Int = matchingIds[$1.id]?.totalMatchesCount ?? 0

            // Calculating items relative position based on all needed criterias.
            let hasFirstElementMatchingKeywordsCountHigher: Bool = firstElementDifferentKeywordsMatchCount > secondElementDifferentKeywordsMatchCount
            let isSameMatchingKeywordsCount: Bool = firstElementDifferentKeywordsMatchCount == secondElementDifferentKeywordsMatchCount

            let isFirstElementScoreHigher: Bool = firstElementScore > secondElementScore
            let isSameScore: Bool = firstElementScore == secondElementScore

            let isSameUpdatedAt: Bool = $0.updatedAt == $1.updatedAt
            let isFirstElementPositionLower: Bool = $0.position < $1.position
            let isFirstElementMoreRecent: Bool = $0.consultedAt ?? $0.updatedAt > $1.consultedAt ?? $1.updatedAt

            let isFirstElementMoreRecentOrAtLowerPosition: Bool = isSameUpdatedAt ? isFirstElementPositionLower : isFirstElementMoreRecent

            return isSameMatchingKeywordsCount ? (isSameScore ? isFirstElementMoreRecentOrAtLowerPosition : isFirstElementScoreHigher) : hasFirstElementMatchingKeywordsCountHigher
        }

        return sortedResultsItems
    }

    static func canRunSearch(for url: String) -> Bool {
        let urlString: String = url.contains("://") ? url : "https://\(url)"
        guard let urlComponents = URLComponents(string: urlString) else { return false }
        return urlComponents.host != nil
    }

    static func searchKeywords(for url: String) async throws -> [String] {
        let extractor: TLDExtract = try .init()
        guard let result: TLDResult = extractor.parse(url) else { return [] }
        let fullDomain: String = [result.subDomain, result.rootDomain].compactMap { $0 }.joined(separator: ".")
        return [String](Set([result.secondLevelDomain, result.rootDomain, fullDomain].compactMap { $0 }))
    }

    static func updateConsultedDate(itemId: String) throws {
        guard let item = try safeItemRepository.getItem(id: itemId) else { return }
        guard item.deletedAt == nil else { return }
        var itemToSave: SafeItem = item
        itemToSave.consultedAt = .now
        itemToSave.consultedAtPosition = try getConsultedAtItemIndex(item: itemToSave)
        try safeItemRepository.save(items: [itemToSave])
    }

    static func updateLastSearchQuery(_ query: String, date: Date) throws {
        guard !query.isEmpty else { return }
        let coreCrypto: CoreCrypto = .shared
        let encQuery: Data = try coreCrypto.encrypt(value: query, scope: .searchIndex)
        let queryToAdd: SearchQuery = .init(id: UUID().uuidStringV4, encQuery: encQuery, date: date)

        let uniqueQueries: [SearchQuery] = try getLastSearchQueries().filter {
            let decryptedQuery: String? = try getStringFromEncryptedData(data: $0.encQuery, scope: .searchIndex)
            return decryptedQuery != query
        }
        let updatedQueries: [SearchQuery] = uniqueQueries + [queryToAdd]

        let maxQueryToSave: Int = Constant.Search.numberOfLastSearchQueries
        if updatedQueries.count > maxQueryToSave {
            var updatedQueriesSorted: [SearchQuery] = updatedQueries.sorted(by: { $0.date > $1.date })
            updatedQueriesSorted.removeLast()
            try searchRepository.updateLastSearchQueries(updatedQueriesSorted)
        } else {
            try searchRepository.updateLastSearchQueries(updatedQueries)
        }
    }

    static func getLastSearchQueries() throws -> [SearchQuery] {
        try searchRepository.getLastSearchQueries()
    }

    static func saveSearchText(_ text: String) throws {
        try searchRepository.saveSearchText(text)
    }

    static func getSavedSearchText() throws -> String? {
        try searchRepository.getSavedSearchText()
    }

    static func deleteSavedSearchText() throws {
        try searchRepository.deleteSavedSearchText()
    }

    static func observeLastSearchQueries() throws -> AnyPublisher<[SearchQuery], Never> {
        try searchRepository.observeLastSearchQueries()
            .removeDuplicates()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
    }
}

private extension UseCase {
    typealias KeywordsMatchingInfo = (matchedKeywords: Set<String>, totalMatchesCount: Int)
}
