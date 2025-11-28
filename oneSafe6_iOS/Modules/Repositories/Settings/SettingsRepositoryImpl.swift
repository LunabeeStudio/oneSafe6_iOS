//
//  SettingsRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/03/2023 - 5:43 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Protocols
import Model
import Storage
import Combine
@preconcurrency import oneSafeKmp

final class SettingsRepositoryImpl: SettingsRepository {
    func observeInactivityAutolockOption() -> AnyPublisher<InactivityAutolockOption, Never> {
        FileDirectoryManager.shared.inactivityAutolockOptionObserver
            .prepend(getInactivityAutolockOption())
            .eraseToAnyPublisher()
    }

    func observeByChangingAppAutolockOption() -> AnyPublisher<ByChangingAppAutolockOption, Never> {
        FileDirectoryManager.shared.byChangingAppAutolockOptionObserver
            .prepend(getByChangingAppAutolockOption())
            .eraseToAnyPublisher()
    }

    func observePasswordVerificationOption() -> AnyPublisher<PasswordVerificationOption, Never> {
        FileDirectoryManager.shared.updatePasswordVerificationOptionObserver
            .prepend(getPasswordVerificationOption())
            .eraseToAnyPublisher()
    }

    func observeClearPasteboardOption() -> AnyPublisher<ClearPasteboardOption, Never> {
        FileDirectoryManager.shared.clearPasteboardOptionObserver
            .prepend(getClearPasteboardOption())
            .eraseToAnyPublisher()
    }

    func observeAutoBackupFrequencyOption() -> AnyPublisher<AutoBackupFrequencyOption, Never> {
        UserDefaultsManager.shared.$autoBackupFrequencyIdentifier
            .map { AutoBackupFrequencyOption(rawValue: $0) ?? .defaultValue }
            .eraseToAnyPublisher()
    }

    func observeIsAutoBackupEnabled() -> AnyPublisher<Bool, Never> {
        UserDefaultsManager.shared.$autoBackupIsEnabled
            .eraseToAnyPublisher()
    }

    func observeProximityLockOption() -> PassthroughSubject<ProximityLockOption, Never> {
        FileDirectoryManager.shared.proximityLockOptionObserver
    }

    func getInactivityAutolockOption() -> InactivityAutolockOption {
        FileDirectoryManager.shared.inactivityAutolockOption() ?? .defaultValue
    }

    func getByChangingAppAutolockOption() -> ByChangingAppAutolockOption {
        FileDirectoryManager.shared.byChangingAppAutolockOption() ?? .defaultValue
    }

    func getPasswordVerificationOption() -> PasswordVerificationOption {
        FileDirectoryManager.shared.passwordVerificationOption() ?? .defaultValue
    }

    func getClearPasteboardOption() -> ClearPasteboardOption {
        FileDirectoryManager.shared.clearPasteboardOption() ?? .defaultValue
    }

    func getProximityLockOption() -> ProximityLockOption {
        FileDirectoryManager.shared.proximityLockOption() ?? .defaultValue
    }

    func isFetchIconLabelEnabled() -> Bool {
        UserDefaultsManager.shared.fetchIconLabelIsEnabled
    }

    func isFileSystemIcloudBackupAuthorized() -> Bool {
        UserDefaultsManager.shared.isFileSystemIcloudBackupAuthorized
    }

    func isAutoBackupEnabled() -> Bool {
        UserDefaultsManager.shared.autoBackupIsEnabled
    }

    func isAutoBackupICloudEnabled() -> Bool {
        UserDefaultsManager.shared.autoBackupICloudIsEnabled
    }

    func isAutoBackupLocalEnabled() -> Bool {
        UserDefaultsManager.shared.autoBackupLocalIsEnabled
    }

    func getAutoBackupFrequencyOption() -> AutoBackupFrequencyOption {
        .init(rawValue: UserDefaultsManager.shared.autoBackupFrequencyIdentifier) ?? .defaultValue
    }

    func getProximityLockSnackBarDisplayCount() -> Int {
        UserDefaultsManager.shared.proximityLockSnackBarDisplayCount
    }

    func isHapticEnabled() -> Bool {
        UserDefaultsManager.shared.isHapticEnabled
    }

    func updateInactivityAutolockOption(_ option: InactivityAutolockOption) throws -> InactivityAutolockOption {
        try FileDirectoryManager.shared.updateInactivityAutolockOption(option)
        return option
    }

    func updateByChangingAppAutolockOption(_ option: ByChangingAppAutolockOption) throws -> ByChangingAppAutolockOption {
        try FileDirectoryManager.shared.updateByChangingAppAutolockOption(option)
        return option
    }

    func updatePasswordVerificationOption(_ option: PasswordVerificationOption) throws -> PasswordVerificationOption {
        try FileDirectoryManager.shared.updatePasswordVerificationOption(option)
        return option
    }

    func updateClearPasteboardOption(_ option: ClearPasteboardOption) throws -> ClearPasteboardOption {
        try FileDirectoryManager.shared.updateClearPasteboardOption(option)
        return option
    }

    func updateFetchIconLabelIsEnabled(_ isEnabled: Bool) {
        UserDefaultsManager.shared.fetchIconLabelIsEnabled = isEnabled
    }

    func updateAutoBackupIsEnabled(_ isEnabled: Bool) {
        UserDefaultsManager.shared.autoBackupIsEnabled = isEnabled
    }

    func updateAutoBackupICloudIsEnabled(_ isEnabled: Bool) {
        UserDefaultsManager.shared.autoBackupICloudIsEnabled = isEnabled
    }

    func updateAutoBackupLocalIsEnabled(_ isEnabled: Bool) {
        UserDefaultsManager.shared.autoBackupLocalIsEnabled = isEnabled
    }

    func updateFileSystemIcloudBackupAuthorized(_ isAuthorized: Bool) {
        UserDefaultsManager.shared.isFileSystemIcloudBackupAuthorized = isAuthorized
    }

    func updateAutoBackupFrequencyOption(_ option: AutoBackupFrequencyOption) throws -> AutoBackupFrequencyOption {
        UserDefaultsManager.shared.autoBackupFrequencyIdentifier = option.rawValue
        return option
    }

    func isSpotlightAuthorized() -> Bool {
        UserDefaultsManager.shared.isSpotlightAuthorized
    }

    func updateIsSpotlightAuthorized(_ value: Bool) {
        UserDefaultsManager.shared.isSpotlightAuthorized = value
    }

    func showSpotlightItemIdentifier() -> Bool {
        UserDefaultsManager.shared.showSpotlightItemIdentifier
    }

    func updateShowSpotlightItemIdentifier(_ value: Bool) {
        UserDefaultsManager.shared.showSpotlightItemIdentifier = value
    }

    func updateIsHapticEnabled(_ isEnabled: Bool) {
        UserDefaultsManager.shared.isHapticEnabled = isEnabled
    }

    func incrementProximityLockSnackBarDisplayCount() {
        UserDefaultsManager.shared.proximityLockSnackBarDisplayCount += 1
    }

    func resetProximityLockSnackBarDisplayCount() {
        UserDefaultsManager.shared.proximityLockSnackBarDisplayCount = 0
    }

    func updateProximityLockOption(_ option: ProximityLockOption) throws -> ProximityLockOption {
        try FileDirectoryManager.shared.updateProximityLockOption(option)
        return option
    }

    // MARK: Bubbles (MessagingSettingsRepository)
    func __bubblesResendMessageDelayInMillis(safeId: DoubleratchetDoubleRatchetUUID) async throws -> KotlinLong {
        // Ignoring safe if until implemenation of multi safe
        .init(value: UserDefaultsManager.shared.bubblesResendMessageDelay ?? MessageResendDelay.defaultValue.numberOfMilliSeconds)
    }

    func getResendMessageDelay() -> MessageResendDelay? {
        guard let userDefaultValue = UserDefaultsManager.shared.bubblesResendMessageDelay else { return nil }
        return MessageResendDelay(numberOfMilliSeconds: userDefaultValue)
    }

    func updateResentMessageDelay(_ value: MessageResendDelay) {
        UserDefaultsManager.shared.bubblesResendMessageDelay = value.numberOfMilliSeconds
    }

    func getMessageEncryptionPreviewEnabled() -> Bool {
        UserDefaultsManager.shared.messageEncryptionPreviewEnabled
    }

    func updateMessageEncryptionPreviewEnabled(_ value: Bool) {
        UserDefaultsManager.shared.messageEncryptionPreviewEnabled = value
    }

    func isCreateItemFromPasteboardOptionEnabled() -> Bool {
        UserDefaultsManager.shared.createItemFromPastboardOptionEnabled
    }

    func observeCreateItemFromPasteboardOptionEnabled() -> AnyPublisher<Bool, Never> {
        UserDefaultsManager.shared.$createItemFromPastboardOptionEnabled
            .eraseToAnyPublisher()
    }

    func updateCreateItemFromPasteboardOptionEnabled(_ value: Bool) {
        UserDefaultsManager.shared.createItemFromPastboardOptionEnabled = value
    }
}
