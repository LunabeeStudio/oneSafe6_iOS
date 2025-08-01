//
//  ContactImport.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 11:58.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public struct ContactImport {
    public let id: String
    public let encName: Data
    public let encSharedKey: ContactSharedKeyImport?
    public let updatedAt: Date
    public let encSharingMode: Data
    public let sharedConversationId: String
    public let consultedAt: Date?
    public let safeId: String // ignored until multi safe is supported
    public let encResetConversationDate: Data?

    public init(id: String, encName: Data, encSharedKey: ContactSharedKeyImport?, updatedAt: Date, encSharingMode: Data, sharedConversationId: String, consultedAt: Date?, safeId: String, encResetConversationDate: Data?) {
        self.id = id
        self.encName = encName
        self.encSharedKey = encSharedKey
        self.updatedAt = updatedAt
        self.encSharingMode = encSharingMode
        self.sharedConversationId = sharedConversationId
        self.consultedAt = consultedAt
        self.safeId = safeId
        self.encResetConversationDate = encResetConversationDate
    }
}
