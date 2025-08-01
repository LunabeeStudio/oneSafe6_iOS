//
//  REncHandShakeData.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 17:06.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import RealmSwift
import Model

public final class REncHandShakeData: Object {
    @Persisted(primaryKey: true) public var conversationLocalId: String
    @Persisted public var encConversationSharedId: Data
    @Persisted public var encOneSafePrivateKey: Data?
    @Persisted public var encOneSafePublicKey: Data?

    public convenience init(conversationLocalId: String, encConversationSharedId: Data, encOneSafePrivateKey: Data?, encOneSafePublicKey: Data?) {
        self.init()
        self.conversationLocalId = conversationLocalId
        self.encConversationSharedId = encConversationSharedId
        self.encOneSafePrivateKey = encOneSafePrivateKey
        self.encOneSafePublicKey = encOneSafePublicKey
    }
}

extension REncHandShakeData: CodableForAppModel {
    public var id: String { conversationLocalId }

    public static func from(appModel: EncHandShakeData) throws -> REncHandShakeData {
        REncHandShakeData(
            conversationLocalId: appModel.conversationLocalId,
            encConversationSharedId: appModel.encConversationSharedId,
            encOneSafePrivateKey: appModel.encOneSafePrivateKey,
            encOneSafePublicKey: appModel.encOneSafePublicKey
        )
    }

    public func toAppModel() throws -> EncHandShakeData {
        EncHandShakeData(
            conversationLocalId: conversationLocalId,
            encConversationSharedId: encConversationSharedId,
            encOneSafePrivateKey: encOneSafePrivateKey,
            encOneSafePublicKey: encOneSafePublicKey
        )
    }
}

extension EncHandShakeData: RealmStorable {
    public typealias RModel = REncHandShakeData
}
