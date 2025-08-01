//
//  UseCase+ForceUpgrade.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 31/03/2023 - 10:33.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit
import Model
import Extensions
import Combine

public extension UseCase {
    static func fetchForceUpgradeData() async throws {
        let info: ForceUpgradeInfo = try await forceUpgradeRepository.fetchInfo()
        if await info.requiredForceUpdateBuildOSVersion > UIDevice.current.systemVersion || info.forceUpdateBuildNumber > Bundle.main.buildNumber || info.softUpdateBuildNumber > Bundle.main.buildNumber {
            let stringsURL: String = info.languageFiles[Locale.current.identifier] ?? baseLocaleIdentifier.map { info.languageFiles[$0] ?? info.fallbackLanguageFile } ?? info.fallbackLanguageFile
            let strings: ForceUpgradeStrings = try await forceUpgradeRepository.fetchStrings(url: stringsURL)
            let data: ForceUpgradeData = .init(forceUpgradeBuildNumber: info.forceUpdateBuildNumber,
                                               softUpgradeBuildNumber: info.softUpdateBuildNumber,
                                               requiredForceUpdateBuildOSVersion: info.requiredForceUpdateBuildOSVersion,
                                               strings: strings)
            try forceUpgradeRepository.saveData(data)
        } else {
            forceUpgradeRepository.cleanData()
        }
    }

    private static var baseLocaleIdentifier: String? {
        let identifier: String = Locale.current.identifier
        guard identifier.contains("_") else { return nil }
        return identifier.components(separatedBy: "_").first
    }

    static func isForceUpgradeNecessary() -> Bool {
        guard let data = try? forceUpgradeRepository.getLastData() else { return false }
        return data.requiredForceUpdateBuildOSVersion > UIDevice.current.systemVersion || data.forceUpgradeBuildNumber > Bundle.main.buildNumber || data.softUpgradeBuildNumber > Bundle.main.buildNumber
    }

    static func observeForceUpgradeData() -> AnyPublisher<ForceUpgradeData?, Never> {
        forceUpgradeRepository.dataPublisher
    }
}
