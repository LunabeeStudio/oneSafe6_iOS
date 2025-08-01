//
//  DependenciesContainer.swift
//  Dependencies
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 11:38.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

final class DependenciesContainer {
    static let shared: DependenciesContainer = .init()
    private var dependencies: LazyDictionary<Any> = .init()

    private init() {}

    deinit {
        dependencies.clear()
    }

    func register<DependencyType>(_ dependencyBuilder: @escaping () -> DependencyType) {
        register(key: String(describing: DependencyType.self), factoryClosure: dependencyBuilder)
    }

    func resolveRepository<DependencyType>() -> DependencyType {
        let key: String = .init(describing: DependencyType.self)
        guard let repository = dependencies.value(for: key) as? DependencyType else {
            fatalError("Repository of type \(key) was not found.")
        }
        return repository
    }
}

private extension DependenciesContainer {
    func register(key: String, factoryClosure: @escaping () -> Any) {
        dependencies.set(value: factoryClosure, for: key)
    }
}
