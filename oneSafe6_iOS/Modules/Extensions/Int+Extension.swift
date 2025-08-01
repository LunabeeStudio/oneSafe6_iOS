//
//  Int+Extension.swift
//  Debug
//
//  Created by Nicolas on 03/08/2022.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation

extension Int {
    public var formattedSize: String { Int64(self).formattedSize }
}

extension Int64 {
    public var formattedSize: String {
        let formatter: ByteCountFormatter = .init()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .binary
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: self)
    }
}
