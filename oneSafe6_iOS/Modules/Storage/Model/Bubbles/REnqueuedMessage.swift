//
//  REnqueuedMessage.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 14:42.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import RealmSwift
import Model

public final class REnqueuedMessage: Object {
    @Persisted(primaryKey: true) public var id: Int32
    @Persisted public var encIncomingMessage: Data
    @Persisted public var encChannel: Data?

    public convenience init(id: Int32, encIncomingMessage: Data, encChannel: Data? = nil) {
        self.init()
        self.id = id
        self.encIncomingMessage = encIncomingMessage
        self.encChannel = encChannel
    }
}

extension REnqueuedMessage: CodableForAppModel {
    public static func from(appModel: EnqueuedMessage) throws -> REnqueuedMessage {
        REnqueuedMessage(
            id: appModel.id,
            encIncomingMessage: appModel.encIncomingMessage,
            encChannel: appModel.encChannel
        )
    }

    public func toAppModel() throws -> EnqueuedMessage {
        EnqueuedMessage(
            id: id,
            encIncomingMessage: encIncomingMessage,
            encChannel: encChannel
        )
    }
}

extension EnqueuedMessage: RealmStorable {
    public typealias RModel = REnqueuedMessage
}
