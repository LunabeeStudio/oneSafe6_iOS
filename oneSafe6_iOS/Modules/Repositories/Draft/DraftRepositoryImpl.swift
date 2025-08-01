//
//  DraftRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 11/07/2023 - 09:40.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import Protocols
import Storage

public final class DraftRepositoryImpl: DraftRepository {
    public func saveSafeItemDraft(encData: Data) throws {
        try FileDirectoryManager.shared.save(safeItemDraftData: encData)
    }

    public func getCurrentSafeItemDraft() throws -> Data? {
        try FileDirectoryManager.shared.currentSafeItemDraftData()
    }

    public func deleteSafeItemDraft() throws {
        try FileDirectoryManager.shared.deleteCurrentSafeItemDraft()
    }

    public func saveBubblesInputMessageDraft(encData: Data) throws {
        try FileDirectoryManager.shared.save(bubblesInputMessageDraft: encData)
    }

    public func getBubblesInputMessageDraft() throws -> Data? {
        try FileDirectoryManager.shared.bubblesInputMessageDraft()
    }

    public func deleteBubblesInputMessageDraft() throws {
        try FileDirectoryManager.shared.deleteBubblesInputMessageDraft()
    }
}
