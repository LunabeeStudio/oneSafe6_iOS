//
//  ArchiveImportContent.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 15/02/2023 - 18:00.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct ArchiveImportContent {
    public let items: [SafeItemImport]
    public let fields: [SafeItemFieldImport]
    public let keys: [SafeItemKeyImport]
    public let contacts: [ContactImport]
    public let contactsKeys: [ContactLocalKeyImport]
    public let messages: [SafeMessageImport]
    public let conversations: [EncConversationImport]
    public let encBubblesMasterKey: Data?
    public let salt: Data

    public init(items: [SafeItemImport], fields: [SafeItemFieldImport], keys: [SafeItemKeyImport], contacts: [ContactImport], contactsKeys: [ContactLocalKeyImport], messages: [SafeMessageImport], conversations: [EncConversationImport], encBubblesMasterKey: Data?, salt: Data) {
        self.items = items
        self.fields = fields
        self.keys = keys
        self.contacts = contacts
        self.contactsKeys = contactsKeys
        self.messages = messages
        self.conversations = conversations
        self.salt = salt
        self.encBubblesMasterKey = encBubblesMasterKey
    }
}
