//
//  UseCase+Image.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 17/03/2023 - 13:51.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit
import Extensions

public extension UseCase {
    static func imageFromEmoji(_ emoji: Character) -> UIImage? {
        String(emoji).toImage(height: Constant.Image.emojiHeight, margin: Constant.Image.emojiMargin)
    }

    static func imageFromRemoteUrl(_ url: URL) async throws -> UIImage? {
        let (data, _): (Data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}
