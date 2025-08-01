//
//  Injection.swift
//  DependenciesInjection
//
//  Created by Rémi Lanteri on 25/01/2023.
//

@propertyWrapper
public struct Inject<T> {
    public var wrappedValue: T {
        DependenciesContainer.shared.resolveRepository()
    }

    public init() {}
}
