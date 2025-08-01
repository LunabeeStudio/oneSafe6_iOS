//
//  Sequence+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 19/12/2022 - 13:56.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Sequence {
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    func asyncMap<T>( _ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values: [T] = .init()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }

    func asyncCompactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T] {
        var values: [T] = .init()
        for element in self {
            if let transformedElement = try await transform(element) {
                values.append(transformedElement)
            }
        }
        return values
    }
}
