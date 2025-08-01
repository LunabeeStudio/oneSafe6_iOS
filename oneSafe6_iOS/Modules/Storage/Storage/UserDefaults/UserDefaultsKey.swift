//
//  UserDefaultsKey.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case isFirstInstallDone
    case firstInstallDoneDate

    case passwordGenerationUppercaseRequired
    case passwordGenerationLowercaseRequired
    case passwordGenerationNumberRequired
    case passwordGenerationSymbolRequired
    case passwordGenerationLengthRequired

    case fetchIconLabelIsEnabled
    case forceUpgradeData

    case dontRemindShareAlert

    case isSpotlightAuthorized
    case showSpotlightItemIdentifier

    case isFileSystemIcloudBackupAuthorized

    case autoBackupIsEnabled
    case autoBackupICloudIsEnabled
    case autoBackupLocalIsEnabled
    case autoBackupFrequency
    case lastAutoBackupDate
    case hideAutoBackupAdvice
    case lastManualBackupDate

    case currentAppLanguage
    case appLaunchCounterForTranslationHelp
    case helpTranslationBottomSheetHasBeenPresented

    case appLaunchCounterSinceLastSupportUsRequest
    case lastSupportUsRequestDate
    case userHasRateTheApp

    case itemsSortingOption
    case itemsDisplayOption

    case proximityLockSnackBarDisplayCount

    case isHapticEnabled

    case userHasStartedUsingBubbles
    case hideDiscoverBubbles
    case bubblesResendMessageDelay
    case messageEncryptionPreviewEnabled
    case bubblesMessageQueue
    case unknownMessageSharingStatusAlertHasBeenPresented
    case safeMessagesOrderMigrated

    case lastNoBackupWarningDismissDate
    case lastNoPasswordVerificationWarningDismissDate

    case createItemFromPastboardOptionEnabled
}
