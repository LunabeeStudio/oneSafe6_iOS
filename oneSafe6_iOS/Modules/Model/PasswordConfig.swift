//
//  PasswordConfig.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 04/03/2023 - 16:15.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public struct PasswordConfig {
    public let length: Int
    public let includeUppercase: Bool
    public let includeLowercase: Bool
    public let includeNumber: Bool
    public let includeSymbol: Bool

    public init(length: Int, includeUppercase: Bool, includeLowercase: Bool, includeNumber: Bool, includeSymbol: Bool) {
        self.length = length
        self.includeUppercase = includeUppercase
        self.includeLowercase = includeLowercase
        self.includeNumber = includeNumber
        self.includeSymbol = includeSymbol
    }
}
