//
//  Repositories.swift
//  Dependencies
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 11:17.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import DependencyInjection
@preconcurrency import oneSafeKmp

public struct Repositories: DependenciesProvider {
    public init() {
        @Provides(AppRepositoryImpl()) var appRepository: AppRepository?
        @Provides(CryptoRepositoryImpl()) var cryptoRepository: CryptoRepository?
        @Provides(SafeItemIconRepositoryImpl()) var iconRepository: SafeItemIconRepository?
        @Provides(SafeItemRepositoryImpl()) var safeItemRepository: SafeItemRepository?
        @Provides(SearchRepositoryImpl()) var searchRepository: SearchRepository?
        @Provides(SafeItemImportRepositoryImpl()) var safeItemImportRepository: SafeItemImportRepository?
        @Provides(SafeItemIconImportRepositoryImpl()) var safeItemIconImportRepository: SafeItemIconImportRepository?
        @Provides(SafeItemFileImportRepositoryImpl()) var safeItemFileImportRepository: SafeItemFileImportRepository?
        @Provides(SafeItemIconDuplicateRepositoryImpl()) var safeItemIconDuplicateRepository: SafeItemIconDuplicateRepository?
        @Provides(SafeItemFileDuplicateRepositoryImpl()) var safeItemFileDuplicateRepository: SafeItemFileDuplicateRepository?
        @Provides(ArchiveRepositoryImpl()) var archiveRepository: ArchiveRepository?
        @Provides(PasswordGenerationRepositoryImpl()) var passwordGenerationRepository: PasswordGenerationRepository?
        @Provides(PasswordVerificationRepositoryImpl()) var passwordVerificationRepository: PasswordVerificationRepository?
        @Provides(SettingsRepositoryImpl()) var settingsRepository: SettingsRepository?
        @Provides(FavIconRepositoryImpl()) var favIconRepository: FavIconRepository?
        @Provides(ForceUpgradeRepositoryImpl()) var forceUpgradeRepository: ForceUpgradeRepository?
        @Provides(DatabaseRepositoryImpl()) var databaseRepository: DatabaseRepository?
        @Provides(FeatureFlagRepositoryImpl()) var featureFlagRepository: FeatureFlagRepository?
        @Provides(DiscoveryRepositoryImpl()) var discoveryRepository: DiscoveryRepository?
        @Provides(DraftRepositoryImpl()) var draftRepository: DraftRepository?
        @Provides(FileRepositoryImpl()) var fileRepository: FileRepository?

        // Bubbles
        @Provides(EnqueuedMessageRepositoryImpl()) var enqueuedMessageRepository: EnqueuedMessageLocalDataSource?
        @Provides(HandShakeDataRepositoryImpl()) var handShakeDataRepository: Protocols.HandShakeDataRepository?
        @Provides(SafeMessageRepositoryImpl()) var safeMessageRepository: Protocols.SafeMessageRepository?
        @Provides(SentMessageRepositoryImpl()) var sentMessageRepository: Protocols.SentMessageRepository?
        @Provides(ContactKeyRepositoryImpl()) var contactKeyRepository: Protocols.ContactKeyRepository?
        @Provides(ContactRepositoryImpl()) var contactRepository: Protocols.ContactRepository?
        @Provides(BubblesSafeRepositoryImpl()) var bubblesSafeRepository: BubblesSafeRepository?
        @Provides(BubblesMainCryptoRepositoryImpl()) var bubblesMainCryptoRepository: BubblesMainCryptoRepository?
        @Provides(ConversationRepositoryImpl()) var conversationRepository: Protocols.ConversationRepository?
        @Provides(DoubleRatchetKeyRepositoryImpl()) var doubleRatchetKeyRepository: DoubleRatchetKeyLocalDatasource?
        @Provides(MessageQueueRepositoryImpl()) var messageQueueRepository: MessageQueueLocalDatasource?
        @Provides(ArchiveBubblesRepositoryImpl()) var archiveBubblesRepository: ArchiveBubblesRepository?
        @Provides(BubblesImportRepositoryImpl()) var bubblesImportRepository: BubblesImportRepository?
    }
}
