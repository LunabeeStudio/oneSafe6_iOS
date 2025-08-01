//
//  DiscoveryField.swift
//  Model
//
//  Created by Lunabee Studio (Quentin Noblet) on 02/06/2023 - 11:21.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public struct DiscoveryField: Decodable {
    public let isItemIdentifier: Bool
    public let isSecured: Bool
    public let kind: String
    public let position: Int
    public let showPrediction: Bool
    public let name: String
    public let value: String
    public let placeholder: String
    public let formattingMask: String?
    public let secureDisplayMask: String?
}
