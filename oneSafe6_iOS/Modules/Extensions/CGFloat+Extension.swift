//
//  CGFloat+Extension.swift
//  DesignSystem
//
//  Created by Lunabee Studio (Nicolas) on 02/01/2023 - 13:52.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

// Fantastic explanation of how it works
// http://www.niwa.nu/2013/05/math-behind-colorspace-conversions-rgb-hsl/
extension CGFloat {
    /// clamp the supplied value between a min and max
    /// - Parameter min: The min value
    /// - Parameter max: The max value
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min {
            return min
        } else if self > max {
            return max
        } else {
            return self
        }
    }

    /// If colour value is less than 1, add 1 to it. If temp colour value is greater than 1, substract 1 from it
    func convertToColourChannel() -> CGFloat {
        let min: CGFloat = 0
        let max: CGFloat = 1
        let modifier: CGFloat = 1
        if self < min {
            return self + modifier
        } else if self > max {
            return self - max
        } else {
            return self
        }
    }

    /// Formula to convert the calculated colour from colour multipliers
    /// - Parameter temp1: Temp variable one (calculated from luminosity)
    /// - Parameter temp2: Temp variable two (calcualted from temp1 and luminosity)
    func convertToRGB(temp1: CGFloat, temp2: CGFloat) -> CGFloat {
        if 6 * self < 1 {
            return temp2 + (temp1 - temp2) * 6 * self
        } else if 2 * self < 1 {
            return temp1
        } else if 3 * self < 2 {
            return temp2 + (temp1 - temp2) * (0.666 - self) * 6
        } else {
            return temp2
        }
    }
}
