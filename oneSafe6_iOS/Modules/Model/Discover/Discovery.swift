//
//  Discovery.swift
//  Model
//
//  Created by Lunabee Studio (Quentin Noblet) on 02/06/2023 - 11:28.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct Discovery: Decodable {
    public let labels: [String: String]
    public let data: [DiscoveryItem]

    enum CodingKeys: CodingKey {
        case labels
        case data
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([DiscoveryItem].self, forKey: .data)
        let defaultLanguageCode: String = "en"
        let languageCode: String = Locale.current.language.languageCode?.identifier ?? defaultLanguageCode
        let languageScript: String = languageCode == "zh" ? (Locale.current.language.script?.identifier ?? "") : ""
        let appLanguage: String = [languageCode, languageScript].filter { !$0.isEmpty }.joined(separator: "-")
        let discoveryLabels: [String: [String: String]] = try container.decode([String: [String: String]].self, forKey: .labels)
        self.labels = discoveryLabels[appLanguage] ?? discoveryLabels[defaultLanguageCode] ?? [:]
    }
}
