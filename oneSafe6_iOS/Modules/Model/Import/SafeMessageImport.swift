//
//  SafeMessageImport.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 15:12.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public struct SafeMessageImport {
    public let id: String
    public let fromContactId: String
    public let encSentAt: Data
    public let encContent: Data
    public let direction: SafeMessage.Direction
    public let encChannel: Data?
    public let isRead: Bool
    public let order: Float
    public let encSafeItemId: Data?

    public init(id: String, fromContactId: String, encSentAt: Data, encContent: Data, direction: SafeMessage.Direction, encChannel: Data?, isRead: Bool, order: Float, encSafeItemId: Data?) {
        self.id = id
        self.fromContactId = fromContactId
        self.encSentAt = encSentAt
        self.encContent = encContent
        self.direction = direction
        self.encChannel = encChannel
        self.isRead = isRead
        self.order = order
        self.encSafeItemId = encSafeItemId
    }
}
