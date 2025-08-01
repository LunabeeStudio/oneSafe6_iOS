//
//  ContactLocalKeyImport.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 15:07.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public struct ContactLocalKeyImport {
    public let contactId: String
    public let encKey: Data

    public init(contactId: String, encKey: Data) {
        self.contactId = contactId
        self.encKey = encKey
    }
}
