//
//  LazyDictionary.swift
//  Dependencies
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 11:38.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

struct LazyDictionary<U> {
    private var backingDictionary: [String: U] = .init()
    private var builderDictionary: [String: () -> U] = .init()

    private let lock: NSLock = .init()

    mutating func clear() { backingDictionary.removeAll() }

    mutating func set(value: @escaping () -> U, for key: String) {
        builderDictionary[key] = value
    }

    mutating func value(for key: String) -> U? {
        lock.lock()
        if let entry = backingDictionary.first(where: { $0.key.splitTypes().contains(key) }) {
            lock.unlock()
            return entry.value
        } else if let entry = builderDictionary.first(where: { $0.key.splitTypes().contains(key) }) {
            let builder: U = entry.value()
            backingDictionary[entry.key] = builder
            lock.unlock()
            return builder
        } else {
            lock.unlock()
            return nil
        }
    }
}

extension String {
    func splitTypes() -> [String] {
        self.split(separator: "&").map { String($0).trimmingCharacters(in: .whitespaces) }
    }
}
