//
//  RSearchQuery.swift
//  Storage
//
//  Created by Lunabee Studio (Alexandre Cools) on 21/03/2023 - 10:22 AM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSearchQuery: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encQuery: Data
    @Persisted public var date: Date

    convenience init(id: String, encQuery: Data, date: Date) {
        self.init()
        self.id = id
        self.encQuery = encQuery
        self.date = date
    }
}

extension RSearchQuery: CodableForAppModel {
    public static func from(appModel: SearchQuery) throws -> RSearchQuery {
        .init(id: appModel.id, encQuery: appModel.encQuery, date: appModel.date)
    }

    public func toAppModel() throws -> SearchQuery {
        .init(id: id, encQuery: encQuery, date: date)
    }
}

extension SearchQuery: RealmStorable {
    public typealias RModel = RSearchQuery
}
