//
//  SafeItemEditionDraft.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 11/07/2023 - 09:30.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct SafeItemEditionDraft: Codable {
    public let name: String
    public let websiteName: String?
    public let colorCode: String?
    public let iconData: Data?
    public let websiteIconData: Data?
    public let fields: [String: Field]
    public let fieldsNames: [String: String]
    public let filesUrlsRenamingMapping: [URL: URL]

    public init(name: String,
                websiteName: String?,
                colorCode: String?,
                iconData: Data?,
                websiteIconData: Data?,
                fields: [String: Field],
                fieldsNames: [String: String],
                filesUrlsRenamingMapping: [URL: URL]) {
        self.name = name
        self.websiteName = websiteName
        self.colorCode = colorCode
        self.iconData = iconData
        self.websiteIconData = websiteIconData
        self.fields = fields
        self.fieldsNames = fieldsNames
        self.filesUrlsRenamingMapping = filesUrlsRenamingMapping
    }
}

public extension SafeItemEditionDraft {
    struct Field: Codable {
        public let value: String
        public let kind: String

        public init(value: String, kind: String) {
            self.value = value
            self.kind = kind
        }
    }
}
