//
//  AppRepository.swift
//  Dependencies
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 10:56.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Combine
import Model

public protocol AppRepository {
    var itemsSortingOption: ItemsSortingOption { get }
    var itemsDisplayOption: ItemsDisplayOption { get }
    var itemsSortingOptionPublisher: AnyPublisher<ItemsSortingOption, Never> { get }
    var itemsDisplayOptionPublisher: AnyPublisher<ItemsDisplayOption, Never> { get }

    func updateItemsSortingOption(_ sortingOption: ItemsSortingOption)
    func updateItemsDisplayOption(_ displayOption: ItemsDisplayOption)

    func isFirstInstallDone() -> Bool
    func updateIsFirstInstallDone(_ value: Bool)
    func clearKeychain() throws

    func shouldPresentRemindShareAlert() -> Bool
    func dontRemindShareAlert()

    func shouldHideAutoBackupAdvice() -> Bool
    func observeShouldHideAutoBackupAdvice() -> AnyPublisher<Bool, Never>
    func hideAutoBackupAdvice()
    func canPresentAutoBackupAdvice() -> Bool

    func shouldPreventAutoLock() -> Bool
    func updateShouldPreventAutoLock(_ value: Bool)

    func getCurrentAppLanguage() -> String
    func setCurrentAppLanguage(_ language: String)
    func getAppLaunchCounterForTranslationHelp() -> Int
    func setAppLaunchCounterForTranslationHelp(_ newCount: Int)
    func getHelpTranslationBottomSheetHasBeenPresented() -> Bool
    func setHelpTranslationBottomSheetHasBeenPresented(_ newValue: Bool)

    func appLaunchCounterSinceLastSupportUsRequest() -> Int
    func observeAppLaunchCounterSinceLastSupportUsRequest() -> AnyPublisher<Int, Never>
    func updateAppLaunchCounterSinceLastSupportUsRequest(_ value: Int)
    func lastSupportUsRequestDate() -> Date?
    func updateLastSupportUsRequestDate(_ value: Date?)
    func userHasRateTheApp() -> Bool
    func updateUserHasRateTheApp(_ value: Bool)

    func userHasStartedUsingBubbles() -> Bool
    func updateUserHasStartedUsingBubbles(_ value: Bool)
    func observeUserHasStartedUsingBubbles() -> AnyPublisher<Bool, Never>
    func shouldHideDiscoverBubbles() -> Bool
    func hideDiscoverBubbles()
    func observeShouldHideDiscoverBubbles() -> AnyPublisher<Bool, Never>

    func getUnknownMessageSharingStatusAlertHasBeenPresented() -> Bool
    func updateUnknownMessageSharingStatusAlertHasBeenPresented(_ value: Bool)

    func safeMessagesOrderMigrated() -> Bool
    func updateSafeMessagesOrderMigrated(_ value: Bool)

    func migrateFromKeychainToFilesIfNeeded() throws

    // MARK: - TEMPORARY DEBUG STUFF THAT MUST NOT BE MERGED -
    func getAllExistingKeychainKeys() -> [String]
    func getAllExistingConfigurationFilesNames() throws -> [String]

    func observeLastNoBackupWarningDismissDate() -> AnyPublisher<Date, Never>
    func updateLastNoBackupWarningDismissDate(_ value: Date)
    func lastNoBackupWarningDismissDate() -> Date
    func observeLastNoPasswordVerificationWarningDismissDate() -> AnyPublisher<Date, Never>
    func updateLastNoPasswordVerificationWarningDismissDate(_ value: Date)
    func lastNoPasswordVerificationWarningDismissDate() -> Date
}
