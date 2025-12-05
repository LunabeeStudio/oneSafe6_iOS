//
//  Data+Extension.swift
//  Crypto
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

internal extension Data {
    mutating func cptWipeData() {
        guard let range = Range(NSRange(location: 0, length: count)) else { return }
        resetBytes(in: range)
    }
}
