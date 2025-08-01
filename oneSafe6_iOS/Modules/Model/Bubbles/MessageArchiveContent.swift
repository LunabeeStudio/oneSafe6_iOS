//
//  MessageArchiveContent.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 12/12/2024 - 10:49.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation

public struct MessageArchiveContent {
    public let messageData: Data
    public let attachment: URL?

    public init(messageData: Data, attachment: URL?) {
        self.messageData = messageData
        self.attachment = attachment
    }
}
