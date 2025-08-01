//
//  SafeItemFieldImport.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import UIKit

public struct SafeItemFieldImport {
    public let id: String
    public let encName: Data?
    public let position: Double
    public let itemId: String
    public let encPlaceholder: Data?
    public let encValue: Data?
    public let showPrediction: Bool
    public let encKind: Data?
    public let createdAt: Date
    public let updatedAt: Date
    public let isItemIdentifier: Bool
    public let encFormattingMask: Data?
    public let encSecureDisplayMask: Data?
    public let isSecured: Bool

    public init(id: String,
                encName: Data? = nil,
                position: Double,
                itemId: String,
                encPlaceholder: Data? = nil,
                encValue: Data? = nil,
                showPrediction: Bool = true,
                encKind: Data? = nil,
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                isItemIdentifier: Bool = false,
                encFormattingMask: Data? = nil,
                encSecureDisplayMask: Data? = nil,
                isSecured: Bool) {
        self.id = id
        self.encName = encName
        self.position = position
        self.itemId = itemId
        self.encPlaceholder = encPlaceholder
        self.encValue = encValue
        self.showPrediction = showPrediction
        self.encKind = encKind
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isItemIdentifier = isItemIdentifier
        self.encFormattingMask = encFormattingMask
        self.encSecureDisplayMask = encSecureDisplayMask
        self.isSecured = isSecured
    }
}
