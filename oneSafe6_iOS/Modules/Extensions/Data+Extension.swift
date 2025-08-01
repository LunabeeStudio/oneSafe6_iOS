//
//  Data+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Data {
    var hexString: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
    
    func string(using encoding: String.Encoding) -> String? { String(data: self, encoding: encoding) }
}
