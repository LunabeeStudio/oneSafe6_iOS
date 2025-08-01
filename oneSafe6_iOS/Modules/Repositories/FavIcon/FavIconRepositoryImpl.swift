//
//  FavIconRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 07/11/2022 - 4:12 PM.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import UIKit
import Protocols
import Model
import RegexBuilder
import Server

final class FavIconRepositoryImpl: FavIconRepository {
    private var cachedTopLevelDomains: [String] = []

    func initializeTopLevelDomainsCache() async {
        guard cachedTopLevelDomains.isEmpty else { return }
        cachedTopLevelDomains = await WebContentServer.getExistingTopLevelDomains()
    }

    func getExistingTopLevelDomains() async -> [String] {
        var existingTopLevelDomains: [String] = cachedTopLevelDomains
        if existingTopLevelDomains.isEmpty {
            existingTopLevelDomains = await WebContentServer.getExistingTopLevelDomains()
            cachedTopLevelDomains = existingTopLevelDomains
        }
        return existingTopLevelDomains
    }

    func getHtmlForUrl(_ url: URL) async throws -> (String, URL)? {
        try await WebContentServer.getHtmlForUrl(url)
    }

    func getData(at url: URL) async throws -> Data {
        try await WebContentServer.getData(at: url)
    }
}
