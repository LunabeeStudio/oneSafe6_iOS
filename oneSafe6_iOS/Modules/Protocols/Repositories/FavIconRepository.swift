//
//  FavIconRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Nicolas) on 17/03/2023 - 17:06.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public protocol FavIconRepository {
    func initializeTopLevelDomainsCache() async
    func getExistingTopLevelDomains() async -> [String]
    func getHtmlForUrl(_ url: URL) async throws -> (String, URL)?
    func getData(at url: URL) async throws -> Data
}
