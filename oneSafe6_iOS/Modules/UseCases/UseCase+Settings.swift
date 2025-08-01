//
//  UseCase+Settings.swift
//  oneSafe
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/03/2023 - 5:33 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit
import Model
import Combine

extension UseCase {
    public static func observeInactivityAutolockOption() -> AnyPublisher<InactivityAutolockOption, Never> {
        settingsRepository.observeInactivityAutolockOption()
    }

    public static func observePasswordVerificationOption() -> AnyPublisher<PasswordVerificationOption, Never> {
        settingsRepository.observePasswordVerificationOption()
    }

    public static func observeByChangingAppAutolockOption() -> AnyPublisher<ByChangingAppAutolockOption, Never> {
        settingsRepository.observeByChangingAppAutolockOption()
    }

    public static func observeClearPasteboardOption() -> AnyPublisher<ClearPasteboardOption, Never> {
        settingsRepository.observeClearPasteboardOption()
    }

    public static func observeAutoBackupFrequencyOption() -> AnyPublisher<AutoBackupFrequencyOption, Never> {
        settingsRepository.observeAutoBackupFrequencyOption()
    }

    public static func observeIsAutoBackupEnabled() -> AnyPublisher<Bool, Never> {
        settingsRepository.observeIsAutoBackupEnabled()
    }

    public static func observeProximityLockOption() -> PassthroughSubject<ProximityLockOption, Never> {
        settingsRepository.observeProximityLockOption()
    }

    public static func getInactivityAutolockOption() -> InactivityAutolockOption {
        settingsRepository.getInactivityAutolockOption()
    }

    public static func getByChangingAppAutolockOption() -> ByChangingAppAutolockOption {
        settingsRepository.getByChangingAppAutolockOption()
    }

    public static func getPasswordVerificationOption() -> PasswordVerificationOption {
        settingsRepository.getPasswordVerificationOption()
    }

    public static func isFileSystemIcloudBackupAuthorized() -> Bool {
        settingsRepository.isFileSystemIcloudBackupAuthorized()
    }

    public static func getClearPasteboardOption() -> ClearPasteboardOption {
        settingsRepository.getClearPasteboardOption()
    }

    public static  func getProximityLockOption() -> ProximityLockOption {
        settingsRepository.getProximityLockOption()
    }

    public static func isFetchIconLabelEnabled() -> Bool {
        settingsRepository.isFetchIconLabelEnabled()
    }

    public static func isAutoBackupEnabled() -> Bool {
        settingsRepository.isAutoBackupEnabled()
    }

    public static func isAutoBackupICloudEnabled() -> Bool {
        settingsRepository.isAutoBackupICloudEnabled()
    }

    public static func isAutoBackupLocalEnabled() -> Bool {
        settingsRepository.isAutoBackupLocalEnabled()
    }

    public static func isHapticEnabled() -> Bool {
        settingsRepository.isHapticEnabled()
    }

    public static func getAutoBackupFrequencyOption() -> AutoBackupFrequencyOption {
        settingsRepository.getAutoBackupFrequencyOption()
    }

    public static func getProximityLockSnackBarDisplayCount() -> Int {
        settingsRepository.getProximityLockSnackBarDisplayCount()
    }

    public static func updateInactivityAutolockOption(_ option: InactivityAutolockOption) throws -> InactivityAutolockOption {
        try settingsRepository.updateInactivityAutolockOption(option)
    }

    public static func updateByChangingAppAutolockOption(_ option: ByChangingAppAutolockOption) throws -> ByChangingAppAutolockOption {
        try settingsRepository.updateByChangingAppAutolockOption(option)
    }

    public static func updatePasswordVerificationOption(_ option: PasswordVerificationOption) throws -> PasswordVerificationOption {
        let option: PasswordVerificationOption = try settingsRepository.updatePasswordVerificationOption(option)
        try passwordVerificationRepository.updateLastPasswordEnterWithSuccessDate()
        return option
    }

    public static func updateClearPasteboardOption(_ option: ClearPasteboardOption) throws -> ClearPasteboardOption {
        try settingsRepository.updateClearPasteboardOption(option)
    }

    public static func updateFetchIconLabelIsEnabled(_ isEnabled: Bool) {
        settingsRepository.updateFetchIconLabelIsEnabled(isEnabled)
    }

    public static func updateAutoBackupIsEnabled(_ isEnabled: Bool) {
        settingsRepository.updateAutoBackupIsEnabled(isEnabled)
    }

    public static func updateAutoBackupICloudIsEnabled(_ isEnabled: Bool) {
        settingsRepository.updateAutoBackupICloudIsEnabled(isEnabled)
        if !isEnabled {
            settingsRepository.updateAutoBackupLocalIsEnabled(false)
        }
    }

    public static func updateAutoBackupLocalIsEnabled(_ isEnabled: Bool) {
        settingsRepository.updateAutoBackupLocalIsEnabled(isEnabled)
    }

    public static func updateAutoBackupFrequencyOption(_ option: AutoBackupFrequencyOption) throws -> AutoBackupFrequencyOption {
        try settingsRepository.updateAutoBackupFrequencyOption(option)
    }

    public static func updateFileSystemIcloudBackupAuthorized(_ isAuthorized: Bool) {
        do {
            try archiveRepository.getUrlsToAuthorizeFileSystemIcloudBackup(isAuthorized)
            settingsRepository.updateFileSystemIcloudBackupAuthorized(isAuthorized)
        } catch {}
    }

    public static func updateProximityLockOption(_ option: ProximityLockOption) throws -> ProximityLockOption {
        UIDevice.current.isProximityMonitoringEnabled = option != .never
        if option == .never {
            settingsRepository.resetProximityLockSnackBarDisplayCount()
        }
        return try settingsRepository.updateProximityLockOption(option)
    }

    public static func updateIsHapticEnabled(_ isEnabled: Bool) {
        settingsRepository.updateIsHapticEnabled(isEnabled)
    }

    public static func incrementProximityLockSnackBarDisplayCount() {
        settingsRepository.incrementProximityLockSnackBarDisplayCount()
    }

    public static func canShowProximityLockSnackBarConfirmation() -> Bool {
        settingsRepository.getProximityLockSnackBarDisplayCount() < Constant.ProximityLock.snackBarConfirmationMaxDisplayCount
    }

    public static func isCreateItemFromPasteboardOptionEnabled() -> Bool {
        settingsRepository.isCreateItemFromPasteboardOptionEnabled()
    }

    public static func observeCreateItemFromPasteboardOptionEnabled() -> AnyPublisher<Bool, Never> {
        settingsRepository.observeCreateItemFromPasteboardOptionEnabled()
    }

    public static func updateCreateItemFromPasteboardOptionEnabled(_ value: Bool) {
        settingsRepository.updateCreateItemFromPasteboardOptionEnabled(value)
    }
}

// MARK: Bubbles settings
public extension UseCase {
    static func messageEncryptionPreviewEnabled() -> Bool {
        settingsRepository.getMessageEncryptionPreviewEnabled()
    }

    static func updateIsMessageEncryptionPreviewEnabled(_ isEnabled: Bool) {
        settingsRepository.updateMessageEncryptionPreviewEnabled(isEnabled)
    }

    static func resendMessageDelay() -> MessageResendDelay {
        settingsRepository.getResendMessageDelay() ?? .defaultValue
    }

    static func updateResendMessageDelay(_ value: MessageResendDelay) {
        settingsRepository.updateResentMessageDelay(value)
    }
}
