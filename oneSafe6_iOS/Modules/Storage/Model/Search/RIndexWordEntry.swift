//
//  RIndexWordEntry.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 10/01/2023 - 14:02.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RIndexWordEntry: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var encWord: Data
    @Persisted public var match: String

    convenience init(id: String, encWord: Data, match: String) {
        self.init()
        self.id = id
        self.encWord = encWord
        self.match = match
    }
}

extension RIndexWordEntry: CodableForAppModel {
    public static func from(appModel: IndexWordEntry) -> RIndexWordEntry {
        RIndexWordEntry(id: appModel.id, encWord: appModel.encWord, match: appModel.match)
    }

    public func toAppModel() -> IndexWordEntry {
        IndexWordEntry(id: id, encWord: encWord, match: match)
    }
}

extension IndexWordEntry: RealmStorable {
    public typealias RModel = RIndexWordEntry
}
