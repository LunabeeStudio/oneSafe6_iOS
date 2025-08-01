//
//  DiscoveryItem.swift
//  Model
//
//  Created by Lunabee Studio (Quentin Noblet) on 02/06/2023 - 11:16.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public struct DiscoveryItem: Decodable {
    public let title: String
    public let isFavorite: Bool?
    public let color: String?
    public let iconId: String?
    public let items: [DiscoveryItem]?
    public let fields: [DiscoveryField]?
}
