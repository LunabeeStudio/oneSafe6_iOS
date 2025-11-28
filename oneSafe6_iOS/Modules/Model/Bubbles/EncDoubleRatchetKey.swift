//
//  EncDoubleRatchetKey.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 25/07/2024 - 18:38.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp

public struct EncDoubleRatchetKey {
    public let id: String
    public let data: Data

    public init(id: String, data: Data) {
        self.id = id
        self.data = data
    }
}

extension EncDoubleRatchetKey {
    public func toKMPModel() -> oneSafeKmp.EncDoubleRatchetKey {
        .init(
            id: id,
            data: data.toByteArray()
        )
    }

    public static func from(kmpModel: oneSafeKmp.EncDoubleRatchetKey) -> EncDoubleRatchetKey {
        EncDoubleRatchetKey(
            id: kmpModel.id,
            data: kmpModel.data.toNSData()
        )
    }
}
