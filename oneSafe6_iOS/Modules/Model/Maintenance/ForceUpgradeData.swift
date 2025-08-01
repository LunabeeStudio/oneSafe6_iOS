//
//  ForceUpgradeData.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 31/03/2023 - 09:54.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public struct ForceUpgradeData: Codable {
    public let forceUpgradeBuildNumber: Int
    public let softUpgradeBuildNumber: Int
    public let requiredForceUpdateBuildOSVersion: String
    public let strings: ForceUpgradeStrings

    public init(forceUpgradeBuildNumber: Int, softUpgradeBuildNumber: Int, requiredForceUpdateBuildOSVersion: String, strings: ForceUpgradeStrings) {
        self.forceUpgradeBuildNumber = forceUpgradeBuildNumber
        self.softUpgradeBuildNumber = softUpgradeBuildNumber
        self.requiredForceUpdateBuildOSVersion = requiredForceUpdateBuildOSVersion
        self.strings = strings
    }
}
