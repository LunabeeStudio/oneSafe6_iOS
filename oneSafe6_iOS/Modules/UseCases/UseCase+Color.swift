//
//  UseCase+Color.swift
//  UseCases
//
//  Created by Lunabee Studio (Jérémy Magnier) on 27/01/2023 - 18:00.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import SwiftUI

extension UseCase {
    public static func randomColor() -> Color {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}
