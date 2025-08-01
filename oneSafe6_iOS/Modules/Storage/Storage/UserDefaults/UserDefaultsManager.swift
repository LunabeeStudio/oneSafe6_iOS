//
//  UserDefaultsManager.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions
import Model
import Combine

// swiftlint:disable redundant_optional_initialization
public final class UserDefaultsManager {
    public static let shared: UserDefaultsManager = .init()
    private init() {}

    private static let userDefaults: UserDefaults = UserDefaults(suiteName: "Storage")!

    @UserDefault(key: UserDefaultsKey.isFirstInstallDone.rawValue, userDefaults: userDefaults)
    public var isFirstInstallDone: Bool = false

    @UserDefault(key: UserDefaultsKey.isSpotlightAuthorized.rawValue, userDefaults: userDefaults)
    public var isSpotlightAuthorized: Bool = false

    @UserDefault(key: UserDefaultsKey.showSpotlightItemIdentifier.rawValue, userDefaults: userDefaults)
    public var showSpotlightItemIdentifier: Bool = false

    @UserDefault(key: UserDefaultsKey.firstInstallDoneDate.rawValue, userDefaults: userDefaults)
    public var firstInstallDoneDate: Date? = nil

    @UserDefault(key: UserDefaultsKey.passwordGenerationUppercaseRequired.rawValue, userDefaults: userDefaults)
    public var passwordGenerationUppercaseRequired: Bool = true

    @UserDefault(key: UserDefaultsKey.passwordGenerationLowercaseRequired.rawValue, userDefaults: userDefaults)
    public var passwordGenerationLowercaseRequired: Bool = true

    @UserDefault(key: UserDefaultsKey.passwordGenerationNumberRequired.rawValue, userDefaults: userDefaults)
    public var passwordGenerationNumberRequired: Bool = true

    @UserDefault(key: UserDefaultsKey.passwordGenerationSymbolRequired.rawValue, userDefaults: userDefaults)
    public var passwordGenerationSymbolRequired: Bool = true

    @UserDefault(key: UserDefaultsKey.passwordGenerationLengthRequired.rawValue, userDefaults: userDefaults)
    public var passwordGenerationLengthRequired: Int = Constant.PasswordGeneration.defaultLength

    @UserDefault(key: UserDefaultsKey.fetchIconLabelIsEnabled.rawValue, userDefaults: userDefaults)
    public var fetchIconLabelIsEnabled: Bool = true

    @UserDefault(key: UserDefaultsKey.forceUpgradeData.rawValue, userDefaults: userDefaults)
    public var forceUpgradeData: Data? = nil

    @UserDefault(key: UserDefaultsKey.dontRemindShareAlert.rawValue, userDefaults: userDefaults)
    public var dontRemindShareAlert: Bool = false

    @UserDefault(key: UserDefaultsKey.isFileSystemIcloudBackupAuthorized.rawValue, userDefaults: userDefaults)
    public var isFileSystemIcloudBackupAuthorized: Bool = true

    // MARK: Auto backup

    @UserDefault(key: UserDefaultsKey.autoBackupIsEnabled.rawValue, userDefaults: userDefaults)
    public var autoBackupIsEnabled: Bool = false

    @UserDefault(key: UserDefaultsKey.autoBackupICloudIsEnabled.rawValue, userDefaults: userDefaults)
    public var autoBackupICloudIsEnabled: Bool = false

    @UserDefault(key: UserDefaultsKey.autoBackupLocalIsEnabled.rawValue, userDefaults: userDefaults)
    public var autoBackupLocalIsEnabled: Bool = false

    @UserDefault(key: UserDefaultsKey.autoBackupFrequency.rawValue, userDefaults: userDefaults)
    public var autoBackupFrequencyIdentifier: String = ""

    @UserDefault(key: UserDefaultsKey.proximityLockSnackBarDisplayCount.rawValue, userDefaults: userDefaults)
    public var proximityLockSnackBarDisplayCount: Int = 0

    @UserDefault(key: UserDefaultsKey.lastAutoBackupDate.rawValue, userDefaults: userDefaults)
    public var lastAutoBackupDate: Date? = nil

    @UserDefault(key: UserDefaultsKey.hideAutoBackupAdvice.rawValue, userDefaults: userDefaults)
    public var hideAutoBackupAdvice: Bool = false

    // MARK: Help translation
    @UserDefault(key: UserDefaultsKey.currentAppLanguage.rawValue, userDefaults: userDefaults)
    public var currentAppLanguage: String = ""

    @UserDefault(key: UserDefaultsKey.appLaunchCounterForTranslationHelp.rawValue, userDefaults: userDefaults)
    public var appLaunchCounterForTranslationHelp: Int = 0

    @UserDefault(key: UserDefaultsKey.helpTranslationBottomSheetHasBeenPresented.rawValue, userDefaults: userDefaults)
    public var helpTranslationBottomSheetHasBeenPresented: Bool = false

    @UserDefault(key: UserDefaultsKey.appLaunchCounterSinceLastSupportUsRequest.rawValue, userDefaults: userDefaults)
    public var appLaunchCounterSinceLastSupportUsRequest: Int = 0

    @UserDefault(key: UserDefaultsKey.lastSupportUsRequestDate.rawValue, userDefaults: userDefaults)
    public var lastSupportUsRequestDate: Date? = nil

    @UserDefault(key: UserDefaultsKey.userHasRateTheApp.rawValue, userDefaults: userDefaults)
    public var userHasRateTheApp: Bool = false

    @UserDefault(key: UserDefaultsKey.itemsSortingOption.rawValue, userDefaults: userDefaults)
    public var itemsSortingOption: String = ItemsSortingOption.alphabetical.rawValue

    @UserDefault(key: UserDefaultsKey.itemsDisplayOption.rawValue, userDefaults: userDefaults)
    public var itemsDisplayOption: String = ItemsDisplayOption.grid.rawValue

    @UserDefault(key: UserDefaultsKey.isHapticEnabled.rawValue, userDefaults: userDefaults)
    public var isHapticEnabled: Bool = true

    @UserDefault(key: UserDefaultsKey.userHasStartedUsingBubbles.rawValue, userDefaults: userDefaults)
    public var userHasStartedUsingBubbles: Bool = false

    @UserDefault(key: UserDefaultsKey.hideDiscoverBubbles.rawValue, userDefaults: userDefaults)
    public var hideDiscoverBubbles: Bool = false

    @UserDefault(key: UserDefaultsKey.bubblesResendMessageDelay.rawValue, userDefaults: userDefaults)
    public var bubblesResendMessageDelay: Int64? = nil

    @UserDefault(key: UserDefaultsKey.messageEncryptionPreviewEnabled.rawValue, userDefaults: userDefaults)
    public var messageEncryptionPreviewEnabled: Bool = false

    @UserDefault(key: UserDefaultsKey.bubblesMessageQueue.rawValue, userDefaults: userDefaults)
    public var bubblesMessageQueue: Data? = nil

    @UserDefault(key: UserDefaultsKey.unknownMessageSharingStatusAlertHasBeenPresented.rawValue, userDefaults: userDefaults)
    public var unknownMessageSharingStatusAlertHasBeenPresented: Bool = false

    @UserDefault(key: UserDefaultsKey.safeMessagesOrderMigrated.rawValue, userDefaults: userDefaults)
    public var safeMessagesOrderMigrated: Bool = false

    // MARK: Warnings
    @UserDefault(key: UserDefaultsKey.lastNoBackupWarningDismissDate.rawValue, userDefaults: userDefaults)
    public var lastNoBackupWarningDismissDate: Date = Constant.initialLastDismissWarningDate

    @UserDefault(key: UserDefaultsKey.lastNoPasswordVerificationWarningDismissDate.rawValue, userDefaults: userDefaults)
    public var lastNoPasswordVerificationWarningDismissDate: Date = Constant.initialLastDismissWarningDate

    @UserDefault(key: UserDefaultsKey.lastManualBackupDate.rawValue, userDefaults: userDefaults)
    public var lastManualBackupDate: Date = .distantPast

    @UserDefault(key: UserDefaultsKey.createItemFromPastboardOptionEnabled.rawValue, userDefaults: userDefaults)
    public var createItemFromPastboardOptionEnabled: Bool = false
}
// swiftlint:enable redundant_optional_initialization

private extension Constant {
    /// Equals to `minNumberOfDaysBetweenWarningAppearance` - 10 days
    static let initialLastDismissWarningDate: Date = Calendar.current.date(byAdding: .day, value: -20, to: .now) ?? .distantPast
}
