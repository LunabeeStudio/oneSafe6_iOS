//
//  UseCase+ColorKit.swift
//  UseCases
//
//  Created by Lunabee Studio (Jérémy Magnier) on 16/01/2023 - 14:03.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Extensions
import SwiftUI
import ColorKit

public extension UseCase {
    static func getDominantColor(for image: UIImage?) -> String? {
        let dominantColors: [UIColor] = (try? image?.dominantColors(with: .best) ?? [])?.filter { $0.hexCode != UIColor.white.hexCode } ?? []
        return dominantColors.first { !$0.isGray }?.hexCode ?? dominantColors.first?.hexCode
    }
}
