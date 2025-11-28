//
//  UseCase.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 18/11/2022 - 14:46.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import struct DependencyInjection.Inject
import Protocols
@preconcurrency import oneSafeKmp

public enum UseCase {
    @Inject static var appRepository: AppRepository
    @Inject static var cryptoRepository: CryptoRepository
    @Inject static var safeItemIconRepository: SafeItemIconRepository
    @Inject static var safeItemRepository: SafeItemRepository
    @Inject static var searchRepository: SearchRepository
    @Inject static var safeItemImportRepository: SafeItemImportRepository
    @Inject static var safeItemIconImportRepository: SafeItemIconImportRepository
    @Inject static var safeItemFileImportRepository: SafeItemFileImportRepository
    @Inject static var safeItemIconDuplicateRepository: SafeItemIconDuplicateRepository
    @Inject static var safeItemFileDuplicateRepository: SafeItemFileDuplicateRepository
    @Inject static var archiveRepository: ArchiveRepository
    @Inject static var passwordGenerationRepository: PasswordGenerationRepository
    @Inject static var passwordVerificationRepository: PasswordVerificationRepository
    @Inject static var settingsRepository: SettingsRepository
    @Inject static var favIconRepository: FavIconRepository
    @Inject static var forceUpgradeRepository: ForceUpgradeRepository
    @Inject static var databaseRepository: DatabaseRepository
    @Inject static var featureFlagRepository: FeatureFlagRepository
    @Inject static var discoveryRepository: DiscoveryRepository
    @Inject static var draftRepository: DraftRepository
    @Inject static var fileRepository: FileRepository
    @Inject static var contactRepository: Protocols.ContactRepository
    @Inject static var messageRepository: Protocols.SafeMessageRepository
    @Inject static var sentMessageRepository: Protocols.SentMessageRepository
    @Inject static var bubblesSafeRepository: BubblesSafeRepository
    @Inject static var contactKeyRepository: Protocols.ContactKeyRepository
    @Inject static var archiveBubblesRepository: ArchiveBubblesRepository
    @Inject static var conversationsRepository: Protocols.ConversationRepository
    @Inject static var bubblesImportRepository: BubblesImportRepository
    @Inject static var handShakeDataRepository: Protocols.HandShakeDataRepository
}

// MARK: Helpers
extension UseCase {
    static func incrementWorker(_ worker: ProgressWorker?) async {
        if let worker {
            await worker.increment(1)
        }
    }
}
