//
//  Realm+Extension.swift
//  Storage
//
//  Created by Lunabee Studio (Francois Beta) on 04/08/2022 - 14:56.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import RealmSwift

extension Realm {
    func handleObjects(named className: String) -> Bool {
        configuration.objectTypes?.contains { $0.className() == className } ?? false
    }
}
