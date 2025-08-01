//
//  REncConversation.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 18:11.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class REncConversation: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encPersonalPublicKey: Data
    @Persisted public var encPersonalPrivateKey: Data
    @Persisted public var encMessageNumber: Data
    @Persisted public var encSequenceNumber: Data
    @Persisted public var encRootKey: Data?
    @Persisted public var encSendingChainKey: Data?
    @Persisted public var encReceiveChainKey: Data?
    @Persisted public var encLastContactPublicKey: Data?
    @Persisted public var encReceivedLastMessageNumber: Data?

    convenience init(id: String, encPersonalPublicKey: Data, encPersonalPrivateKey: Data, encMessageNumber: Data, encSequenceNumber: Data, encRootKey: Data? = nil, encSendingChainKey: Data? = nil, encReceiveChainKey: Data? = nil, encLastContactPublicKey: Data? = nil, encReceivedLastMessageNumber: Data? = nil) {
        self.init()
        self.id = id
        self.encPersonalPublicKey = encPersonalPublicKey
        self.encPersonalPrivateKey = encPersonalPrivateKey
        self.encMessageNumber = encMessageNumber
        self.encSequenceNumber = encSequenceNumber
        self.encRootKey = encRootKey
        self.encSendingChainKey = encSendingChainKey
        self.encReceiveChainKey = encReceiveChainKey
        self.encLastContactPublicKey = encLastContactPublicKey
        self.encReceivedLastMessageNumber = encReceivedLastMessageNumber
    }
}

extension REncConversation: CodableForAppModel {
    public func toAppModel() -> EncConversation {
        EncConversation(
            id: id,
            encPersonalPublicKey: encPersonalPublicKey,
            encPersonalPrivateKey: encPersonalPrivateKey,
            encMessageNumber: encMessageNumber,
            encSequenceNumber: encSequenceNumber,
            encRootKey: encRootKey,
            encSendingChainKey: encSendingChainKey,
            encReceiveChainKey: encReceiveChainKey,
            encLastContactPublicKey: encLastContactPublicKey,
            encReceivedLastMessageNumber: encReceivedLastMessageNumber
        )
    }

    public static func from(appModel: EncConversation) -> REncConversation {
        REncConversation(
            id: appModel.id,
            encPersonalPublicKey: appModel.encPersonalPublicKey,
            encPersonalPrivateKey: appModel.encPersonalPrivateKey,
            encMessageNumber: appModel.encMessageNumber,
            encSequenceNumber: appModel.encSequenceNumber,
            encRootKey: appModel.encRootKey,
            encSendingChainKey: appModel.encSendingChainKey,
            encReceiveChainKey: appModel.encReceiveChainKey,
            encLastContactPublicKey: appModel.encLastContactPublicKey,
            encReceivedLastMessageNumber: appModel.encReceivedLastMessageNumber
        )
    }
}

extension EncConversation: RealmStorable {
    public typealias RModel = REncConversation
}
