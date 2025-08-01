//
//  CryptoKeyLength.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 08:26.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

public enum CryptoKeyLength: Int {
    case bits256 = 256
    case bits512 = 512

    public var bytesCount: Int { rawValue / 8 }
}
