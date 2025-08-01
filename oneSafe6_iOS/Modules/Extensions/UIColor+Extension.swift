//
//  UIColor+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 08/12/2022 - 19:26.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import UIKit

public extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length: Int = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    var hexCode: String? {
        guard let components = cgColor.components else { return nil }
        if components.count >= 3 {
            let r: Float = Float(components[0])
            let g: Float = Float(components[1])
            let b: Float = Float(components[2])

            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        } else if components.count == 2 {
            let w: Float = Float(components[0])
            return String(format: "%02lX%02lX%02lX", lroundf(w * 255), lroundf(w * 255), lroundf(w * 255))
        } else {
            return nil
        }
    }

    var isGray: Bool {
        let rangeLimit: Float = 17.0 / 255.0
        guard let components = cgColor.components else { return false }
        if components.count >= 3 {
            let r: Float = Float(components[0])
            let g: Float = Float(components[1])
            let b: Float = Float(components[2])
            return ([r, g, b].max() ?? 0.0) - ([r, g, b].min() ?? 0.0) < rangeLimit
        } else if components.count == 2 {
            return true
        } else {
            return false
        }
    }

    // Utils
    var luminosity: CGFloat {
        // 1 - Convert the RGB values to the range 0-1
        let coreColour: CIColor = .init(color: self)
        var red: CGFloat = coreColour.red
        var green: CGFloat = coreColour.green
        var blue: CGFloat = coreColour.blue

        // 1a - Clamp these colours between 0 and 1 (combat sRGB colour space)
        red = red.clamp(min: 0, max: 1)
        green = green.clamp(min: 0, max: 1)
        blue = blue.clamp(min: 0, max: 1)

        // 2 - Find the minimum and maximum values of R, G and B.
        guard let minRGB = [red, green, blue].min(), let maxRGB = [red, green, blue].max() else {
            return red
        }

        // 3 - Now calculate the Luminace value by adding the max and min values and divide by 2.
        let luminosity: CGFloat = (minRGB + maxRGB) / 2
        return luminosity
    }

    func adjust(saturation: CGFloat, brightness: CGFloat? = nil) -> UIColor {
        var hue: CGFloat = 0
        var originalSaturation: CGFloat = 0
        var originalBrightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard getHue(&hue, saturation: &originalSaturation, brightness: &originalBrightness, alpha: &alpha) else { return self }
        return UIColor(hue: hue,
                       saturation: originalSaturation != 0 ? saturation : 0,
                       brightness: brightness ?? originalBrightness,
                       alpha: alpha)
    }

    func withMinLuminosity(_ newLuminosity: CGFloat) -> UIColor {
        if luminosity < newLuminosity {
            return withLuminosity(newLuminosity)
        } else {
            return self
        }
    }

    func withMaxLuminosity(_ newLuminosity: CGFloat) -> UIColor {
        if luminosity > newLuminosity {
            return withLuminosity(newLuminosity)
        } else {
            return self
        }
    }

    /// Return a UIColor with adjusted luminosity, returns self if unable to convert
    /// - Parameter newLuminosity: New luminosity, between 0 and 1 (percentage)
    func withLuminosity(_ newLuminosity: CGFloat) -> UIColor {
        // 1 - Convert the RGB values to the range 0-1
        let coreColour: CIColor = .init(color: self)
        var red: CGFloat = coreColour.red
        var green: CGFloat = coreColour.green
        var blue: CGFloat = coreColour.blue
        let alpha: CGFloat = coreColour.alpha

        // 1a - Clamp these colours between 0 and 1 (combat sRGB colour space)
        red = red.clamp(min: 0, max: 1)
        green = green.clamp(min: 0, max: 1)
        blue = blue.clamp(min: 0, max: 1)

        // 1b - If gray level
        if red == green && green == blue {
            return self.adjust(saturation: 0, brightness: newLuminosity)
        }

        // 2 - Find the minimum and maximum values of R, G and B.
        guard let minRGB = [red, green, blue].min(), let maxRGB = [red, green, blue].max() else {
            return self
        }

        // 3 - Now calculate the Luminace value by adding the max and min values and divide by 2.
        var luminosity: CGFloat = (minRGB + maxRGB) / 2

        // 4 - The next step is to find the Saturation.
        // 4a - if min and max RGB are the same, we have 0 saturation
        var saturation: CGFloat = 0

        // 5 - Now we know that there is Saturation we need to do check the level of the Luminance in order to select the correct formula.
        //     If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
        //     If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
        if luminosity <= 0.5 {
            saturation = (maxRGB - minRGB) / (maxRGB + minRGB)
        } else if luminosity > 0.5 {
            saturation = (maxRGB - minRGB) / (2.0 - maxRGB - minRGB)
        } else {
            // 0 if we are equal RGBs
        }

        // 6 - The Hue formula is depending on what RGB color channel is the max value. The three different formulas are:
        var hue: CGFloat = 0
        // 6a - If Red is max, then Hue = (G-B)/(max-min)
        if red == maxRGB {
            hue = (green - blue) / (maxRGB - minRGB)
        }
        // 6b - If Green is max, then Hue = 2.0 + (B-R)/(max-min)
        else if green == maxRGB {
            hue = 2.0 + ((blue - red) / (maxRGB - minRGB))
        }
        // 6c - If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
        else if blue == maxRGB {
            hue = 4.0 + ((red - green) / (maxRGB - minRGB))
        }

        // 7 - The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
        //     If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
        if hue < 0 {
            hue += 360
        } else {
            hue *= 60
        }

        // we want to convert the luminosity. So we will.
        luminosity = newLuminosity

        // Now we need to convert back to RGB

        // 1 - If there is no Saturation it means that it’s a shade of grey. So in that case we just need to convert the Luminance and set R,G and B to that level.
        if saturation == 0 {
            return UIColor(red: 1.0 * luminosity, green: 1.0 * luminosity, blue: 1.0 * luminosity, alpha: alpha)
        }

        // 2 - If Luminance is smaller then 0.5 (50%) then temporary_1 = Luminance x (1.0+Saturation)
        //     If Luminance is equal or larger then 0.5 (50%) then temporary_1 = Luminance + Saturation – Luminance x Saturation
        var temporaryVariableOne: CGFloat = 0
        if luminosity < 0.5 {
            temporaryVariableOne = luminosity * (1 + saturation)
        } else {
            temporaryVariableOne = luminosity + saturation - luminosity * saturation
        }

        // 3 - Final calculated temporary variable
        let temporaryVariableTwo: CGFloat = 2 * luminosity - temporaryVariableOne

        // 4 - The next step is to convert the 360 degrees in a circle to 1 by dividing the angle by 360
        let convertedHue: CGFloat = hue / 360

        // 5 - Now we need a temporary variable for each colour channel
        let tempRed: CGFloat = (convertedHue + 0.333).convertToColourChannel()
        let tempGreen: CGFloat = convertedHue.convertToColourChannel()
        let tempBlue: CGFloat = (convertedHue - 0.333).convertToColourChannel()

        // 6 we must run up to 3 tests to select the correct formula for each colour channel, converting to RGB
        let newRed: CGFloat = tempRed.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newGreen: CGFloat = tempGreen.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newBlue: CGFloat = tempBlue.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)

        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }

    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0

        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0

        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        let r: CGFloat = fgA * fgR + (1 - fgA) * bgR
        let g: CGFloat = fgA * fgG + (1 - fgA) * bgG
        let b: CGFloat = fgA * fgB + (1 - fgA) * bgB

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
