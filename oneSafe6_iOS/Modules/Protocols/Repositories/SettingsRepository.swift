//
//  SettingsRepository.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/03/2023 - 5:44 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import Combine
@preconcurrency import oneSafeKmp

public protocol SettingsRepository: MessagingSettingsRepository {
    func observeInactivityAutolockOption() -> AnyPublisher<InactivityAutolockOption, Never>
    func getInactivityAutolockOption() -> InactivityAutolockOption
    func updateInactivityAutolockOption(_ option: InactivityAutolockOption) throws -> InactivityAutolockOption

    func observeByChangingAppAutolockOption() -> AnyPublisher<ByChangingAppAutolockOption, Never>
    func getByChangingAppAutolockOption() -> ByChangingAppAutolockOption

    func observePasswordVerificationOption() -> AnyPublisher<PasswordVerificationOption, Never>
    func getPasswordVerificationOption() -> PasswordVerificationOption

    func isFileSystemIcloudBackupAuthorized() -> Bool
    func updateFileSystemIcloudBackupAuthorized(_ isAuthorized: Bool)

    func updateByChangingAppAutolockOption(_ option: ByChangingAppAutolockOption) throws -> ByChangingAppAutolockOption
    func updatePasswordVerificationOption(_ option: PasswordVerificationOption) throws -> PasswordVerificationOption

    func observeClearPasteboardOption() -> AnyPublisher<ClearPasteboardOption, Never>
    func getClearPasteboardOption() -> ClearPasteboardOption
    func updateClearPasteboardOption(_ option: ClearPasteboardOption) throws -> ClearPasteboardOption

    func isFetchIconLabelEnabled() -> Bool
    func updateFetchIconLabelIsEnabled(_ isEnabled: Bool)

    func isAutoBackupEnabled() -> Bool
    func updateAutoBackupIsEnabled(_ isEnabled: Bool)

    func isAutoBackupICloudEnabled() -> Bool
    func updateAutoBackupICloudIsEnabled(_ isEnabled: Bool)

    func observeIsAutoBackupEnabled() -> AnyPublisher<Bool, Never>
    func isAutoBackupLocalEnabled() -> Bool
    func updateAutoBackupLocalIsEnabled(_ isEnabled: Bool)

    func observeAutoBackupFrequencyOption() -> AnyPublisher<AutoBackupFrequencyOption, Never>
    func getAutoBackupFrequencyOption() -> AutoBackupFrequencyOption
    func updateAutoBackupFrequencyOption(_ option: AutoBackupFrequencyOption) throws -> AutoBackupFrequencyOption

    func isSpotlightAuthorized() -> Bool
    func updateIsSpotlightAuthorized(_ value: Bool)
    func showSpotlightItemIdentifier() -> Bool
    func updateShowSpotlightItemIdentifier(_ value: Bool)

    func getProximityLockSnackBarDisplayCount() -> Int
    func incrementProximityLockSnackBarDisplayCount()
    func resetProximityLockSnackBarDisplayCount()

    func isHapticEnabled() -> Bool
    func updateIsHapticEnabled(_ isEnabled: Bool)

    func observeProximityLockOption() -> PassthroughSubject<ProximityLockOption, Never>
    func getProximityLockOption() -> ProximityLockOption
    func updateProximityLockOption(_ option: ProximityLockOption) throws -> ProximityLockOption

    func getResendMessageDelay() -> MessageResendDelay?
    func updateResentMessageDelay(_ value: MessageResendDelay)

    func getMessageEncryptionPreviewEnabled() -> Bool
    func updateMessageEncryptionPreviewEnabled(_ value: Bool)

    func isCreateItemFromPasteboardOptionEnabled() -> Bool
    func observeCreateItemFromPasteboardOptionEnabled() -> AnyPublisher<Bool, Never>
    func updateCreateItemFromPasteboardOptionEnabled(_ value: Bool)
}
