//
//  EncHandShakeData.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 18/07/2024 - 17:01.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp

public struct EncHandShakeData {
    public let conversationLocalId: String
    public let encConversationSharedId: Data
    public let encOneSafePrivateKey: Data?
    public let encOneSafePublicKey: Data?

    public init(conversationLocalId: String, encConversationSharedId: Data, encOneSafePrivateKey: Data?, encOneSafePublicKey: Data?) {
        self.conversationLocalId = conversationLocalId
        self.encConversationSharedId = encConversationSharedId
        self.encOneSafePrivateKey = encOneSafePrivateKey
        self.encOneSafePublicKey = encOneSafePublicKey
    }
}

extension EncHandShakeData {
    public static func from(kmpModel: oneSafeKmp.EncHandShakeData) -> EncHandShakeData {
        EncHandShakeData(
            conversationLocalId: kmpModel.conversationLocalId.uuidString(),
            encConversationSharedId: kmpModel.encConversationSharedId.toNSData(),
            encOneSafePrivateKey: kmpModel.encOneSafePrivateKey?.toNSData(),
            encOneSafePublicKey: kmpModel.encOneSafePublicKey?.toNSData()
        )
    }

    public func toKMPModel() -> oneSafeKmp.EncHandShakeData {
        do {
            return oneSafeKmp.EncHandShakeData(
                conversationLocalId: try .companion.fromString(uuidString: conversationLocalId),
                encConversationSharedId: encConversationSharedId.toByteArray(),
                encOneSafePrivateKey: encOneSafePrivateKey?.toByteArray(),
                encOneSafePublicKey: encOneSafePublicKey?.toByteArray()
            )
        } catch {
            fatalError("Coudn't convert \(conversationLocalId) into DoubleRatchetUUID")
        }
    }
}
