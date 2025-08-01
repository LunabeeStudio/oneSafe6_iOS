//
//  SearchQuery.swift
//  Storage
//
//  Created by Lunabee Studio (Alexandre Cools) on 21/03/2023 - 10:25 AM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct SearchQuery: Identifiable, Hashable {
    public let id: String
    public let encQuery: Data
    public let date: Date

    public init(id: String, encQuery: Data, date: Date) {
        self.id = id
        self.encQuery = encQuery
        self.date = date
    }
}
