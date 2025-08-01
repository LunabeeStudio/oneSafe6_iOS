//
//  REncDoubleRatchetKey.swift
//  Storage
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 18:40.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import RealmSwift

public final class REncDoubleRatchetKey: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var data: Data

    convenience init(id: String, data: Data) {
        self.init()
        self.id = id
        self.data = data
    }
}

extension REncDoubleRatchetKey: CodableForAppModel {
    public func toAppModel() -> EncDoubleRatchetKey {
        EncDoubleRatchetKey(
            id: id,
            data: data
        )
    }

    public static func from(appModel: EncDoubleRatchetKey) -> REncDoubleRatchetKey {
        REncDoubleRatchetKey(
            id: appModel.id,
            data: appModel.data
        )
    }
}

extension EncDoubleRatchetKey: RealmStorable {
    public typealias RModel = REncDoubleRatchetKey
}
