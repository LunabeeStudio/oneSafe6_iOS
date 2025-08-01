//
//  ForceUpgradeServer.swift
//  Server
//
//  Created by Lunabee Studio (François Combe) on 30/03/2023 - 17:50.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Errors

public enum ForceUpgradeServer {
    private static let baseURL: String = "https://app-maintenance.lunabee.studio/oneSafe"

    private static var getInfoFileURL: URL? {
        URL(string: "\(baseURL)/prod/ios-info-force-upgrade.json")
    }

    public static func getUpgradeInfo() async throws -> Data {
        guard let getInfoFileURL else {
            throw AppError.cannotConvertToURL
        }
        let request: URLRequest = .init(url: getInfoFileURL)
        return try await URLSession(configuration: .ephemeral).data(for: request).0
    }

    public static func getStrings(url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw AppError.cannotConvertToURL
        }
        let request: URLRequest = .init(url: url)
        return try await URLSession(configuration: .ephemeral).data(for: request).0
    }
}
