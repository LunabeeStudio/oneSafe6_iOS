//
//  ContactSharedKeyImport.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 22/05/2025 - 14:46.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public struct ContactSharedKeyImport {
    public let encKey: Data

    public init(encKey: Data) {
        self.encKey = encKey
    }
}
