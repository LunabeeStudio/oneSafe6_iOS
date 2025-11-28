//
//  UseCase+App.swift
//  oneSafe
//
//  Created by Lunabee Studio (Alexandre Cools) on 05/01/2023 - 4:28 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers
import Combine
import Model

public extension UseCase {
    static func isFirstInstallDone() -> Bool {
        appRepository.isFirstInstallDone()
    }

    static func updateIsFirstInstallDone(_ value: Bool) {
        appRepository.updateIsFirstInstallDone(value)
    }

    static func clearKeychainDataOnFirstInstallIfNeeded() throws {
        guard !appRepository.isFirstInstallDone() else { return }
        try appRepository.clearKeychain()
    }

    static func copy(_ text: String) {
        if let clearPasteBoardDuration = settingsRepository.getClearPasteboardOption().durationInSeconds {
            UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: text]], options: [.expirationDate: Date(timeIntervalSinceNow: clearPasteBoardDuration), .localOnly: NSNumber(booleanLiteral: false)])
        } else {
            UIPasteboard.general.string = text
        }
    }

    static func shouldPresentRemindShareAlert() -> Bool {
        appRepository.shouldPresentRemindShareAlert()
    }

    static func dontRemindShareAlert() {
        appRepository.dontRemindShareAlert()
    }

    static func shouldPresentAutoBackupAdvice() -> Bool {
        (try? safeItemRepository.getAllItems().count) ?? 0 > 0 && !settingsRepository.isAutoBackupEnabled() && !appRepository.shouldHideAutoBackupAdvice() && appRepository.canPresentAutoBackupAdvice()
    }

    static func observeShouldPresentAutoBackupAdvice() throws -> AnyPublisher<Bool, Never> {
        try safeItemRepository.observeSafeItems(sortingKeyPath: nil, ascending: nil)
            .combineLatest(settingsRepository.observeIsAutoBackupEnabled(), appRepository.observeShouldHideAutoBackupAdvice())
            .map { safeItems, isAutoBackupEnabled, shouldHideAutoBackupAdvice in
                safeItems.count > 0 && !isAutoBackupEnabled && !shouldHideAutoBackupAdvice && appRepository.canPresentAutoBackupAdvice()
            }
            .eraseToAnyPublisher()
    }

    static func hideAutoBackupAdvice() {
        appRepository.hideAutoBackupAdvice()
    }

    static func updateShouldPreventAutoLock(_ value: Bool) {
        appRepository.updateShouldPreventAutoLock(value)
    }

    static func shouldPreventAutoLock() -> Bool {
        appRepository.shouldPreventAutoLock()
    }

    static func isHelpNeedForTranslation() -> Bool {
        !Constant.TranslationHelp.notGeneratedTranslationLanguages.contains(appRepository.getCurrentAppLanguage())
    }

    static func shouldPresentTranslationHelpBottomSheet() -> Bool {
        guard !appRepository.getHelpTranslationBottomSheetHasBeenPresented() else { return false }
        guard !Constant.TranslationHelp.notGeneratedTranslationLanguages.contains(appRepository.getCurrentAppLanguage()) else { return false }
        return appRepository.getAppLaunchCounterForTranslationHelp() >= Constant.TranslationHelp.appLaunchCountForTranslationHelpBottomSheet
    }

    static func setTranslationHelpBottomSheetHasBeenPresented() {
        appRepository.setHelpTranslationBottomSheetHasBeenPresented(true)
    }

    static func setupTranslationHelp() {
        guard let languageCode = Locale.current.language.languageCode?.identifier else { return }
        let lastLanguageCode: String = appRepository.getCurrentAppLanguage()
        if languageCode == lastLanguageCode {
            guard !Constant.TranslationHelp.notGeneratedTranslationLanguages.contains(languageCode) else { return }
            let currentLaunchCounter: Int = appRepository.getAppLaunchCounterForTranslationHelp()
            appRepository.setAppLaunchCounterForTranslationHelp(currentLaunchCounter + 1)
        } else {
            appRepository.setCurrentAppLanguage(languageCode)
            appRepository.setHelpTranslationBottomSheetHasBeenPresented(false)
            appRepository.setAppLaunchCounterForTranslationHelp(1)
        }
    }

    /// Use case used ony for dev purpose.
    static func resetApplication() async throws {
        try deleteAllItems()
        try await deleteAllSearchIndex()
        try databaseRepository.deleteDatabase()
        try clearKeychainDataOnFirstInstallIfNeeded()
        UseCase.clearKeychainLeftoversIfNeeded()
        logout()
        updateIsFirstInstallDone(false)
        fatalError("App needs to be restarted.")
    }

    static func observeItemsSortingOption() -> AnyPublisher<ItemsSortingOption, Never> {
        appRepository.itemsSortingOptionPublisher
    }

    static func getItemsSortingOption() -> ItemsSortingOption {
        appRepository.itemsSortingOption
    }

    static func updateItemsSortingOption(_ sortingOption: ItemsSortingOption) {
        appRepository.updateItemsSortingOption(sortingOption)
    }

    static func observeItemsDisplayOption() -> AnyPublisher<ItemsDisplayOption, Never> {
        appRepository.itemsDisplayOptionPublisher
    }

    static func getItemsDisplayOption() -> ItemsDisplayOption {
        appRepository.itemsDisplayOption
    }

    static func updateItemsDisplayOption(_ displayOption: ItemsDisplayOption) {
        appRepository.updateItemsDisplayOption(displayOption)
    }

    static func userHasStartedUsingBubbles() -> Bool {
        appRepository.userHasStartedUsingBubbles()
    }

    static func setUserHasStartedUsingBubbles() {
        appRepository.updateUserHasStartedUsingBubbles(true)
    }

    static func unknownMessageSharingStatusAlertHasBeenPresented() -> Bool {
        appRepository.getUnknownMessageSharingStatusAlertHasBeenPresented()
    }

    static func setUnknownMessageSharingStatusAlertHasBeenPresented() {
        appRepository.updateUnknownMessageSharingStatusAlertHasBeenPresented(true)
    }

    static func safeMessagesOrderMigrated() -> Bool {
        appRepository.safeMessagesOrderMigrated()
    }

    static func setSafeMessagesOrderMigrated() {
        appRepository.updateSafeMessagesOrderMigrated(true)
    }
}

// MARK: Support Us
public extension UseCase {
    static func incrementAppLaunchCounterSinceLastSupportUsRequest() {
        appRepository.updateAppLaunchCounterSinceLastSupportUsRequest(appRepository.appLaunchCounterSinceLastSupportUsRequest() + 1)
    }

    static func shouldPresentSupportUsRequest() -> Bool {
        guard appRepository.appLaunchCounterSinceLastSupportUsRequest() > Constant.SupportUs.numberOfAppLaunchBetweenRequests else { return false }
        if appRepository.userHasRateTheApp() {
            return abs((appRepository.lastSupportUsRequestDate() ?? .distantPast).timeIntervalSinceNow) > Constant.SupportUs.timeIntervalBetweenRequestsAfterApproval
        } else {
            return abs((appRepository.lastSupportUsRequestDate() ?? .distantPast).timeIntervalSinceNow) > Constant.SupportUs.timeIntervalBetweenRequestsAfterRefusal
        }
    }

    static func observeShouldPresentSupportUsRequest() -> AnyPublisher<Bool, Never> {
        // We only use the app launch counter because we only use this observer to observe when it becomes false after a refusal (which set the app launch counter to 0).
        appRepository.observeAppLaunchCounterSinceLastSupportUsRequest()
            .map { launchCounter in
                launchCounter > Constant.SupportUs.numberOfAppLaunchBetweenRequests
            }
            .eraseToAnyPublisher()
    }

    static func supportUsRequestHasBeenDenied() {
        resetSupportUsRequestProperties()
        appRepository.updateUserHasRateTheApp(false)
    }

    static func supportUsRequestHasBeenAccepted() {
        resetSupportUsRequestProperties()
        appRepository.updateUserHasRateTheApp(true)
    }

    private static func resetSupportUsRequestProperties() {
        appRepository.updateLastSupportUsRequestDate(Date())
        appRepository.updateAppLaunchCounterSinceLastSupportUsRequest(0)
    }
}

// MARK: Discover Bubbles
public extension UseCase {
    static func shouldPresentDiscoverBubbles() -> Bool {
        !appRepository.userHasStartedUsingBubbles() && !appRepository.shouldHideDiscoverBubbles()
    }

    static func hideDiscoverBubbles() {
        appRepository.hideDiscoverBubbles()
    }

    static func observeShouldPresentDiscoverBubbles() -> AnyPublisher<Bool, Never> {
        appRepository.observeUserHasStartedUsingBubbles()
            .combineLatest(appRepository.observeShouldHideDiscoverBubbles())
            .map { userHasStartedUsingBubbles, shouldHideDiscoverBubbles in
                !userHasStartedUsingBubbles && !shouldHideDiscoverBubbles
            }
            .eraseToAnyPublisher()
    }
}

// MARK: Warnings
public extension UseCase {
    static func lastNoBackupWarningDismissDate() -> Date {
        appRepository.lastNoBackupWarningDismissDate()
    }

    static func observeLastNoPasswordVerificationWarningDismissDate() -> AnyPublisher<Date, Never> {
        appRepository.observeLastNoPasswordVerificationWarningDismissDate()
    }

    static func lastNoPasswordVerificationWarningDismissDate() -> Date {
        appRepository.lastNoPasswordVerificationWarningDismissDate()
    }

    static func observeLastNoBackupWarningDismissDate() -> AnyPublisher<Date, Never> {
        appRepository.observeLastNoBackupWarningDismissDate()
    }

    static func updateLastNoPasswordVerificationWarningDismissDate(_ date: Date) {
        appRepository.updateLastNoPasswordVerificationWarningDismissDate(date)
    }

    static func updateLastNoBackupWarningDismissDate(_ date: Date) {
        appRepository.updateLastNoBackupWarningDismissDate(date)
    }

    static func dismissNoPasswordVerificationWarning() {
        appRepository.updateLastNoPasswordVerificationWarningDismissDate(.now)
    }

    static func dismissNoRecentBackupWarning() {
        appRepository.updateLastNoBackupWarningDismissDate(.now)
    }
}

// MARK: - Migrate data from Keychain to files -
public extension UseCase {
    static func migrateFromKeychainToFilesIfNeeded() throws {
        try appRepository.migrateFromKeychainToFilesIfNeeded()
    }

    static func getAllExistingConfigurationFilesNames() throws -> [String] {
        try appRepository.getAllExistingConfigurationFilesNames()
    }
}

// MARK: - TEMPORARY DEBUG STUFF THAT MUST NOT BE MERGED -
public extension UseCase {
    static func getAllExistingKeychainKeys() -> [String] {
        appRepository.getAllExistingKeychainKeys()
    }
}

private extension Constant {
    static let minNumberOfDaysBetweenWarningAppearance: Int = 30
    static let minNumberOfDaysSinceLastBackupToShowWarning: Int = 30
}
