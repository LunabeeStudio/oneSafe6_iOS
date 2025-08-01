//
//  WebsiteInfo.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 10/03/2023 - 14:01.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit

public struct WebsiteInfo {
    public let url: String?
    public let title: String?
    public let icon: UIImage?

    public static var empty: WebsiteInfo { .init(url: nil, title: nil, icon: nil) }

    public init(url: String?, title: String?, icon: UIImage?) {
        self.url = url
        self.title = title
        self.icon = icon
    }
}
