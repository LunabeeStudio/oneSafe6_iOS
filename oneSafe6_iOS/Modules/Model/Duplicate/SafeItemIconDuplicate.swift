//
//  SafeItemIconDuplicate.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 28/06/2023 - 10:25.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct SafeItemIconDuplicate {
    public let id: String
    public let data: Data

    public init(id: String, data: Data) {
        self.id = id
        self.data = data
    }
}
