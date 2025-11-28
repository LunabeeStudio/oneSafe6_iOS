//
//  AppRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 05/01/2023 - 4:29 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage
import Combine
import Model

final class AppRepositoryImpl: AppRepository {
    private var _shouldPreventAutoLock: Bool = false

    @Published var itemsSortingOption: ItemsSortingOption = .init(rawValue: UserDefaultsManager.shared.itemsSortingOption) ?? .alphabetical
    var itemsSortingOptionPublisher: AnyPublisher<ItemsSortingOption, Never> { $itemsSortingOption.eraseToAnyPublisher() }

    @Published var itemsDisplayOption: ItemsDisplayOption = .init(rawValue: UserDefaultsManager.shared.itemsDisplayOption) ?? .grid
    var itemsDisplayOptionPublisher: AnyPublisher<ItemsDisplayOption, Never> { $itemsDisplayOption.eraseToAnyPublisher() }

    func updateItemsSortingOption(_ sortingOption: ItemsSortingOption) {
        itemsSortingOption = sortingOption
        UserDefaultsManager.shared.itemsSortingOption = sortingOption.rawValue
    }

    func updateItemsDisplayOption(_ displayOption: ItemsDisplayOption) {
        itemsDisplayOption = displayOption
        UserDefaultsManager.shared.itemsDisplayOption = displayOption.rawValue
    }

    func isFirstInstallDone() -> Bool {
        UserDefaultsManager.shared.isFirstInstallDone
    }

    func updateIsFirstInstallDone(_ value: Bool) {
        if value {
            setFirstInstallDoneDate()
        } else {
            clearFirstInstallDoneDate()
        }
        UserDefaultsManager.shared.isFirstInstallDone = value
    }

    func canPresentAutoBackupAdvice() -> Bool {
        guard let installDoneDate = UserDefaultsManager.shared.firstInstallDoneDate else { return false }

        // Create a new date by subtracting 24 hours from the current date
        guard let modifiedDate = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) else {
            return false
        }

        // Compare the modified date and the other date
        return installDoneDate < modifiedDate
    }

    func clearKeychain() throws {
        try KeychainManager.shared.deleteAll()
    }

    func dontRemindShareAlert() {
        UserDefaultsManager.shared.dontRemindShareAlert = true
    }

    func shouldPresentRemindShareAlert() -> Bool {
        !UserDefaultsManager.shared.dontRemindShareAlert
    }

    func shouldHideAutoBackupAdvice() -> Bool {
        UserDefaultsManager.shared.hideAutoBackupAdvice
    }

    func observeShouldHideAutoBackupAdvice() -> AnyPublisher<Bool, Never> {
        UserDefaultsManager.shared.$hideAutoBackupAdvice
            .eraseToAnyPublisher()
    }

    func hideAutoBackupAdvice() {
        UserDefaultsManager.shared.hideAutoBackupAdvice = true
    }

    func shouldPreventAutoLock() -> Bool {
        _shouldPreventAutoLock
    }

    func updateShouldPreventAutoLock(_ value: Bool) {
        _shouldPreventAutoLock = value
    }

    // MARK: Translation Help
    func getCurrentAppLanguage() -> String {
        UserDefaultsManager.shared.currentAppLanguage
    }

    func setCurrentAppLanguage(_ language: String) {
        UserDefaultsManager.shared.currentAppLanguage = language
    }

    func getAppLaunchCounterForTranslationHelp() -> Int {
        UserDefaultsManager.shared.appLaunchCounterForTranslationHelp
    }

    func setAppLaunchCounterForTranslationHelp(_ newCount: Int) {
        UserDefaultsManager.shared.appLaunchCounterForTranslationHelp = newCount
    }

    func getHelpTranslationBottomSheetHasBeenPresented() -> Bool {
        UserDefaultsManager.shared.helpTranslationBottomSheetHasBeenPresented
    }

    func setHelpTranslationBottomSheetHasBeenPresented(_ newValue: Bool) {
        UserDefaultsManager.shared.helpTranslationBottomSheetHasBeenPresented = newValue
    }

    func appLaunchCounterSinceLastSupportUsRequest() -> Int {
        UserDefaultsManager.shared.appLaunchCounterSinceLastSupportUsRequest
    }

    func observeAppLaunchCounterSinceLastSupportUsRequest() -> AnyPublisher<Int, Never> {
        UserDefaultsManager.shared.$appLaunchCounterSinceLastSupportUsRequest.eraseToAnyPublisher()
    }

    func updateAppLaunchCounterSinceLastSupportUsRequest(_ value: Int) {
        UserDefaultsManager.shared.appLaunchCounterSinceLastSupportUsRequest = value
    }

    func lastSupportUsRequestDate() -> Date? {
        UserDefaultsManager.shared.lastSupportUsRequestDate
    }

    func updateLastSupportUsRequestDate(_ value: Date?) {
        UserDefaultsManager.shared.lastSupportUsRequestDate = value
    }

    func userHasRateTheApp() -> Bool {
        UserDefaultsManager.shared.userHasRateTheApp
    }

    func updateUserHasRateTheApp(_ value: Bool) {
        UserDefaultsManager.shared.userHasRateTheApp = value
    }

    func userHasStartedUsingBubbles() -> Bool {
        UserDefaultsManager.shared.userHasStartedUsingBubbles
    }

    func updateUserHasStartedUsingBubbles(_ value: Bool) {
        UserDefaultsManager.shared.userHasStartedUsingBubbles = value
    }

    func observeUserHasStartedUsingBubbles() -> AnyPublisher<Bool, Never> {
        UserDefaultsManager.shared.$userHasStartedUsingBubbles
            .eraseToAnyPublisher()
    }

    func shouldHideDiscoverBubbles() -> Bool {
        UserDefaultsManager.shared.hideDiscoverBubbles
    }

    func hideDiscoverBubbles() {
        UserDefaultsManager.shared.hideDiscoverBubbles = true
    }

    func observeShouldHideDiscoverBubbles() -> AnyPublisher<Bool, Never> {
        UserDefaultsManager.shared.$hideDiscoverBubbles
            .eraseToAnyPublisher()
    }

    func getUnknownMessageSharingStatusAlertHasBeenPresented() -> Bool {
        UserDefaultsManager.shared.unknownMessageSharingStatusAlertHasBeenPresented
    }

    func updateUnknownMessageSharingStatusAlertHasBeenPresented(_ value: Bool) {
        UserDefaultsManager.shared.unknownMessageSharingStatusAlertHasBeenPresented = value
    }

    func safeMessagesOrderMigrated() -> Bool {
        UserDefaultsManager.shared.safeMessagesOrderMigrated
    }

    func updateSafeMessagesOrderMigrated(_ value: Bool) {
        UserDefaultsManager.shared.safeMessagesOrderMigrated = value
    }

    func observeLastNoBackupWarningDismissDate() -> AnyPublisher<Date, Never> {
        UserDefaultsManager.shared.$lastNoBackupWarningDismissDate
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func updateLastNoBackupWarningDismissDate(_ value: Date) {
        UserDefaultsManager.shared.lastNoBackupWarningDismissDate = value
    }

    func lastNoBackupWarningDismissDate() -> Date {
        UserDefaultsManager.shared.lastNoBackupWarningDismissDate
    }

    func observeLastNoPasswordVerificationWarningDismissDate() -> AnyPublisher<Date, Never> {
        UserDefaultsManager.shared.$lastNoPasswordVerificationWarningDismissDate
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func updateLastNoPasswordVerificationWarningDismissDate(_ value: Date) {
        UserDefaultsManager.shared.lastNoPasswordVerificationWarningDismissDate = value
    }

    func lastNoPasswordVerificationWarningDismissDate() -> Date {
        UserDefaultsManager.shared.lastNoPasswordVerificationWarningDismissDate
    }
}

// MARK: - Migrate data from Keychain to files -
extension AppRepositoryImpl {
    func migrateFromKeychainToFilesIfNeeded() throws {
        guard KeychainManager.shared.isObsoleteKeyStillExisting() else { return }
        try KeychainKey.obsoleteStringKeys.forEach { key in
            guard let string = KeychainManager.shared.getString(key: key) else { return }
            guard let fileKey = FileKey(rawValue: key.rawValue) else { return }
            try FileDirectoryManager.shared.save(string: string, key: fileKey)
            KeychainManager.shared.delete(key: key)
        }
        try KeychainKey.obsoleteDataKeys.forEach { key in
            guard let data = KeychainManager.shared.getData(key: key) else { return }
            guard let fileKey = FileKey(rawValue: key.rawValue) else { return }
            try FileDirectoryManager.shared.save(data: data, key: fileKey)
            KeychainManager.shared.delete(key: key)
        }
    }
}

// MARK: - TEMPORARY DEBUG STUFF THAT MUST NOT BE MERGED -
extension AppRepositoryImpl {
    func getAllExistingKeychainKeys() -> [String] {
        guard KeychainManager.shared.isObsoleteKeyStillExisting() else { return [] }
        var existingKeys: [String] = []
        KeychainKey.obsoleteStringKeys.forEach { key in
            guard KeychainManager.shared.getString(key: key) != nil else { return }
            existingKeys.append(key.rawValue)
        }
        KeychainKey.obsoleteDataKeys.forEach { key in
            guard KeychainManager.shared.getData(key: key) != nil else { return }
            existingKeys.append(key.rawValue)
        }
        return existingKeys
    }

    func getAllExistingConfigurationFilesNames() throws -> [String] {
        try FileDirectoryManager.shared.getFilesConfigurationDirectoryContent()
    }
}

private extension AppRepositoryImpl {
    func setFirstInstallDoneDate() {
        guard UserDefaultsManager.shared.firstInstallDoneDate == nil else { return }
        UserDefaultsManager.shared.firstInstallDoneDate = Date()
        UserDefaultsManager.shared.hideAutoBackupAdvice = false
    }

    func clearFirstInstallDoneDate() {
        UserDefaultsManager.shared.firstInstallDoneDate = nil
    }
}
