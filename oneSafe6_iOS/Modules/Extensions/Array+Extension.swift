//
//  Array+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Jérémie Carrez) on 21/07/2023 - 10:51.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
    func isDisjoint(with otherArray: [Element]) -> Bool {
        let setA: Set<Element> = Set(self)
        let setB: Set<Element> = Set(otherArray)
        return setA.isDisjoint(with: setB)
    }
}
