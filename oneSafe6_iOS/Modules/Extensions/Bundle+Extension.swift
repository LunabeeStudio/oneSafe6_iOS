//
//  Bundle+Extension.swift
//  Crypto
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Bundle {
    static let mainBundleIdentifier: String = Bundle.main.bundleIdentifier.orEmpty
    static var isAutoFillCredentialsProvider: Bool { mainBundleIdentifier.hasSuffix("auto-fill-credential-provider") }

    var marketingVersion: String { (infoDictionary?["CFBundleShortVersionString"] as? String).orEmpty }
    var buildNumber: Int { Int(infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0 }
}
