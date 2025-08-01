//
//  DraftRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 11/07/2023 - 09:53.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model

public protocol DraftRepository {
    func saveSafeItemDraft(encData: Data) throws
    func getCurrentSafeItemDraft() throws -> Data?
    func deleteSafeItemDraft() throws

    func saveBubblesInputMessageDraft(encData: Data) throws
    func getBubblesInputMessageDraft() throws -> Data?
    func deleteBubblesInputMessageDraft() throws
}
