//
//  ForceUpgradeInfo.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 30/03/2023 - 17:56.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public struct ForceUpgradeInfo: Decodable {
    public let forceUpdateBuildNumber: Int
    public let softUpdateBuildNumber: Int
    public let requiredForceUpdateBuildOSVersion: String
    public let languageFiles: [String: String]
    public let fallbackLanguageFile: String
}
