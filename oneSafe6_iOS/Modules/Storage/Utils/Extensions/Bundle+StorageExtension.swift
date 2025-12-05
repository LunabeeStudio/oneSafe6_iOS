//
//  Bundle+Extension.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Extensions

extension Bundle {
    static var stCurrentBundleIdentifier: String { Bundle(for: RealmManager.self).bundleIdentifier.orEmpty }
}
