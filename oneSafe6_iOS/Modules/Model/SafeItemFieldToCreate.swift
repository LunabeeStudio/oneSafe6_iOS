//
//  SafeItemFieldToCreate.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 10/01/2023 - 15:43.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public struct SafeItemFieldToCreate {
    public let position: Double
    public let kind: SafeItemField.Kind
    public let isSecured: Bool
    public let name: String
    public let placeholder: String
    public let isItemIdentifier: Bool
    public let initialValue: String?

    public init(position: Double, kind: SafeItemField.Kind, isSecured: Bool = false, name: String, placeholder: String, isItemIdentifier: Bool = false, initialValue: String? = nil) {
        self.position = position
        self.kind = kind
        self.isSecured = isSecured
        self.name = name
        self.placeholder = placeholder
        self.isItemIdentifier = isItemIdentifier
        self.initialValue = initialValue
    }
}
