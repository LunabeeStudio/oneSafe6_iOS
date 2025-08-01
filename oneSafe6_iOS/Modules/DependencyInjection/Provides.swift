//
//  Provides.swift
//  Dependencies
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 11:38.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

@propertyWrapper
public struct Provides<DependencyType> {
    public var wrappedValue: DependencyType?

    public init(wrappedValue: DependencyType? = nil, _ dependencyBuilder: @autoclosure @escaping () -> DependencyType) {
        DependenciesContainer.shared.register { dependencyBuilder() as DependencyType }
    }
}
