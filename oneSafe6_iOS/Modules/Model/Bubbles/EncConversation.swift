//
//  EncConversation.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 18:00.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import oneSafeKmp

public struct EncConversation {
    public var id: String
    public let encPersonalPublicKey: Data
    public let encPersonalPrivateKey: Data
    public let encMessageNumber: Data
    public let encSequenceNumber: Data
    public let encRootKey: Data?
    public let encSendingChainKey: Data?
    public let encReceiveChainKey: Data?
    public let encLastContactPublicKey: Data?
    public let encReceivedLastMessageNumber: Data?

    public init(id: String, encPersonalPublicKey: Data, encPersonalPrivateKey: Data, encMessageNumber: Data, encSequenceNumber: Data, encRootKey: Data?, encSendingChainKey: Data?, encReceiveChainKey: Data?, encLastContactPublicKey: Data?, encReceivedLastMessageNumber: Data?) {
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

extension EncConversation {
    public func toKMPModel() -> oneSafeKmp.EncConversation {
        do {
            return oneSafeKmp.EncConversation(
                id: try .companion.fromString(uuidString: id),
                encPersonalPublicKey: encPersonalPublicKey.toByteArray(),
                encPersonalPrivateKey: encPersonalPrivateKey.toByteArray(),
                encMessageNumber: encMessageNumber.toByteArray(),
                encSequenceNumber: encSequenceNumber.toByteArray(),
                encRootKey: encRootKey?.toByteArray(),
                encSendingChainKey: encSendingChainKey?.toByteArray(),
                encReceiveChainKey: encReceiveChainKey?.toByteArray(),
                encLastContactPublicKey: encLastContactPublicKey?.toByteArray(),
                encReceivedLastMessageNumber: encReceivedLastMessageNumber?.toByteArray()
            )
        } catch {
            fatalError("Coudn't convert \(id) into DoubleRatchetUUID")
        }
    }

    public static func from(kmpModel: oneSafeKmp.EncConversation) -> EncConversation {
        EncConversation(
            id: kmpModel.id.uuidString(),
            encPersonalPublicKey: kmpModel.encPersonalPublicKey.toNSData(),
            encPersonalPrivateKey: kmpModel.encPersonalPrivateKey.toNSData(),
            encMessageNumber: kmpModel.encMessageNumber.toNSData(),
            encSequenceNumber: kmpModel.encSequenceNumber.toNSData(),
            encRootKey: kmpModel.encRootKey?.toNSData(),
            encSendingChainKey: kmpModel.encSendingChainKey?.toNSData(),
            encReceiveChainKey: kmpModel.encReceiveChainKey?.toNSData(),
            encLastContactPublicKey: kmpModel.encLastContactPublicKey?.toNSData(),
            encReceivedLastMessageNumber: kmpModel.encReceivedLastMessageNumber?.toNSData()
        )
    }
}
