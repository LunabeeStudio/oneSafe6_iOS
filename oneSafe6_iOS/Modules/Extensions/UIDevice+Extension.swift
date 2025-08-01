//
//  UIDevice+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Rémi Lanteri) on 15/03/2023 - 11:47.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit

extension UIDevice {
    public var hasNotch: Bool {
        guard let window = UIApplication.shared.keySceneWindow else { return false }

        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }

    public var isIpad: Bool { userInterfaceIdiom == .pad }
}
