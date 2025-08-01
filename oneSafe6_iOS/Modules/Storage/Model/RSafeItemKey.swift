//
//  RSafeItemKey.swift
//  Crypto
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class RSafeItemKey: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var value: Data

    convenience init(id: String, value: Data) {
        self.init()
        self.id = id
        self.value = value
    }
}

extension RSafeItemKey: CodableForAppModel {
    public static func from(appModel: SafeItemKey) -> RSafeItemKey {
        RSafeItemKey(id: appModel.id, value: appModel.value)
    }

    public func toAppModel() -> SafeItemKey {
        SafeItemKey(id: id, value: value)
    }
}

extension SafeItemKey: RealmStorable {
    public typealias RModel = RSafeItemKey
}
