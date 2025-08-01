//
//  View+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (François Combe) on 22/12/2022 - 10:12.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func conditionalModifier(_ condition: Bool, @ViewBuilder transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

public extension View {
    func onChangeFrameProperty<V>(_ property: KeyPath<CGRect, V>, in coordinateSpace: CoordinateSpace, onChange: @escaping (V) -> Void) -> some View where V: Equatable {
        onGeometryChange(for: V.self) { proxy in
            proxy.frame(in: coordinateSpace)[keyPath: property]
        } action: { newValue in
            onChange(newValue)
        }
    }
}
