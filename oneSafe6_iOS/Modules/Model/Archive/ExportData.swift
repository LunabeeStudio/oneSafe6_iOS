//
//  ExportData.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 05/05/2025 - 14:55.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public struct ExportData {
    // Safe items
    public let items: [SafeItem]
    public let fields: [SafeItemField]
    public var keys: [SafeItemKey]
    public let iconsUrls: [URL]
    public let fileUrls: [URL]

    // Bubbles
    public let bubblesContacts: [Contact]
    public let bubblesContactsKeys: [ContactLocalKey]
    public let bubblesMessages: [SafeMessage]
    public let bubblesConversations: [EncConversation]
    public let bubblesMasterKey: Data?

    public init(items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], fileUrls: [URL], bubblesContacts: [Contact], bubblesContactsKeys: [ContactLocalKey], messages: [SafeMessage], conversations: [EncConversation], bubblesMasterKey: Data?) {
        self.items = items
        self.fields = fields
        self.keys = keys
        self.iconsUrls = iconsUrls
        self.fileUrls = fileUrls
        self.bubblesContacts = bubblesContacts
        self.bubblesContactsKeys = bubblesContactsKeys
        self.bubblesMessages = messages
        self.bubblesConversations = conversations
        self.bubblesMasterKey = bubblesMasterKey
    }

    public init(items: [SafeItem], fields: [SafeItemField], keys: [SafeItemKey], iconsUrls: [URL], fileUrls: [URL]) {
        self.items = items
        self.fields = fields
        self.keys = keys
        self.iconsUrls = iconsUrls
        self.fileUrls = fileUrls
        self.bubblesContacts = []
        self.bubblesContactsKeys = []
        self.bubblesMessages = []
        self.bubblesConversations = []
        self.bubblesMasterKey = nil
    }
}
