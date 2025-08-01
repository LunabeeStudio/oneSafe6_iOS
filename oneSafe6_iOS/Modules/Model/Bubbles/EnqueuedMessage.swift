//
//  EnqueuedMessage.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 15:09.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp
import Errors

public struct EnqueuedMessage {
    public let id: Int32
    public let encIncomingMessage: Data
    public let encChannel: Data?

    public init(id: Int32, encIncomingMessage: Data, encChannel: Data?) {
        self.id = id
        self.encIncomingMessage = encIncomingMessage
        self.encChannel = encChannel
    }
}

extension EnqueuedMessage {
    public static func from(kmpModel: oneSafeKmp.EnqueuedMessage) -> EnqueuedMessage {
        EnqueuedMessage(
            id: kmpModel.id,
            encIncomingMessage: kmpModel.encIncomingMessage.toNSData(),
            encChannel: kmpModel.encChannel?.toNSData()
        )
    }

    public func toKMPModel() -> oneSafeKmp.EnqueuedMessage {
        .init(
            id: id,
            encIncomingMessage: encIncomingMessage.toByteArray(),
            encChannel: encChannel?.toByteArray()
        )
    }
}
