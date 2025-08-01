//
//  Color+Extension.swift
//  oneSafe
//
//  Created by Lunabee Studio (Francois Beta) on 22/07/2022 - 16:17.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import SwiftUI

public extension Color {
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        self.init(uiColor)
    }

    var hexCode: String? {
        UIColor(self).hexCode
    }
}
