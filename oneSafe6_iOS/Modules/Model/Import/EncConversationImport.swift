//
//  EncConversationImport.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 15:24.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public struct EncConversationImport {
    public let id: String
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
