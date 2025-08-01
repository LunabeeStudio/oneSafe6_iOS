//
//  AnyOptional+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }

    public func asyncMap<U>(_ transform: (Wrapped) async throws -> U) async rethrows -> U? {
        switch self {
        case let .some(wrapped):
            return try await transform(wrapped)
        case .none:
            return nil
        }
    }

    public func asyncFlatMap<U>(_ transform: (Wrapped) async throws -> U?) async rethrows -> U? {
        switch self {
        case let .some(wrapped):
            return try await transform(wrapped)
        case .none:
            return nil
        }
    }
}
