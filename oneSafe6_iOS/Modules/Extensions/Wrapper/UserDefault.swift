//
//  UserDefault.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
public struct UserDefault<T> {
    private var defaults: UserDefaults
    private let key: String
    private let defaultValue: T

    public var projectedValue: CurrentValueSubject<T, Never>

    public var wrappedValue: T {
        get { defaults.object(forKey: key) as? T ?? defaultValue }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                defaults.removeObject(forKey: key)
            } else {
                defaults.set(newValue, forKey: key)
            }
            projectedValue.send(newValue)
            defaults.synchronize()
        }
    }

    public init(wrappedValue: T, key: String, userDefaults: UserDefaults = .standard) {
        self.defaultValue = wrappedValue
        self.key = key
        self.defaults = userDefaults
        self.projectedValue = .init(defaults.object(forKey: key) as? T ?? defaultValue)
    }
}

extension UserDefault where T: ExpressibleByNilLiteral {
    public init(key: String) {
        self.init(wrappedValue: nil, key: key)
    }
}
