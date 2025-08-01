//
//  WebContentServer.swift
//  Server
//
//  Created by Lunabee Studio (Nicolas) on 17/03/2023 - 15:46.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum WebContentServer {
    public static func getExistingTopLevelDomains() async -> [String] {
        let request: URLRequest = .init(url: URL(string: "https://data.iana.org/TLD/tlds-alpha-by-domain.txt")!, timeoutInterval: Constant.FavIcon.RequestTimeout.topLevelDomains)
        guard let data = try? await session().data(for: request).0 else { return [] }
        return String(data: data, encoding: .utf8)?.lowercased().components(separatedBy: "\n").filter { !$0.hasPrefix("#") } ?? []
    }

    public static func getHtmlForUrl(_ url: URL) async throws -> (String, URL)? {
        try Task.checkCancellation()
        var request: URLRequest = .init(url: url, timeoutInterval: Constant.FavIcon.RequestTimeout.htmlFetch)
        request.addValue(Constant.FavIcon.userAgent, forHTTPHeaderField: "User-Agent")
        guard let data = try? await session().data(for: request).0 else { return nil }
        return String(data: data, encoding: .utf8).map { ($0, url) }
    }

    public static func getData(at url: URL) async throws -> Data {
        try await session().data(from: url).0
    }
}

private extension WebContentServer {
    static func session() -> URLSession {
        let session: URLSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        session.configuration.httpShouldUsePipelining = true
        return session
    }
}
