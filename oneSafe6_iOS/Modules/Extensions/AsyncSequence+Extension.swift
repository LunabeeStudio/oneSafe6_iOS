//
//  AsyncSequence+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 16/01/2023 - 19:36.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }
}
