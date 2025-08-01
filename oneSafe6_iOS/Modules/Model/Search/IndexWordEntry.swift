//
//  IndexWordEntry.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 10/01/2023 - 13:53.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions

public struct IndexWordEntry {
    public let id: String
    public var encWord: Data
    public var match: String

    public init(id: String = UUID().uuidStringV4, encWord: Data, match: String) {
        self.id = id
        self.encWord = encWord
        self.match = match
    }
}
