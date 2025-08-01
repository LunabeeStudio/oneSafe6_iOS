//
//  SearchRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 17:57.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model
import Combine
import CoreSpotlight

public protocol SearchRepository: CSSearchableIndexDelegate {
    typealias Index = [String: [String]]
    typealias DecryptionBlock = (_ encData: Data) throws -> Data

    func reset()

    func getIndex(decrypt: @escaping DecryptionBlock) async throws -> Index
    func indexItem(id: String, keywords: [Data]) throws
    func unindexItem(id: String) throws
    func deleteAll() throws
    func updateLastSearchQueries(_ queries: [SearchQuery]) throws
    func getLastSearchQueries() throws -> [SearchQuery]

    func getAllIndexWordEntries() throws -> [IndexWordEntry]
    func save(indexWordEntries: [IndexWordEntry]) throws
    func getAllSearchQueries() throws -> [SearchQuery]
    func save(searchQueries: [SearchQuery]) throws

    func setSpotlightReindexingCallbacks(reindexAllSpotlightItems: @escaping () -> Void, reindexSpotlightItemsForIds: @escaping (_ itemsIds: [String]) -> Void)

    func saveSearchText(_ text: String) throws
    func getSavedSearchText() throws -> String?
    func deleteSavedSearchText() throws

    func observeLastSearchQueries() throws -> AnyPublisher<[SearchQuery], Never>
}
