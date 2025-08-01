//
//  Registration.swift
//  DependenciesRegistration
//
//  Created by Rémi Lanteri on 25/01/2023.
//

public protocol DependenciesProvider {
    init()
}

@propertyWrapper
public struct Register<D: DependenciesProvider> {
    public var wrappedValue: D

    public init() {
        self.wrappedValue = D()
    }
}
