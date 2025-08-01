//
//  ForceUpgradeStrings.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 31/03/2023 - 09:56.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public struct ForceUpgradeStrings: Codable {
    public struct StringSet: Codable {
        public let title: String
        public let description: String
        public let buttonLabel: String
    }

    public let forceUpgrade: StringSet
    public let softUpgrade: StringSet
    public let needOSUpdate: StringSet
}
