//
//  Bundle+Extension.swift
//  CoreCrypto
//
//  Created by Lunabee Studio (François Combe) on 29/06/2023 - 14:53.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions

extension Bundle {
    static var currentBundleIdentifier: String { Bundle(for: CoreCrypto.self).bundleIdentifier.orEmpty }
}
