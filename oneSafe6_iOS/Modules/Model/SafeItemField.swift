//
//  SafeItemField.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import UIKit

public struct SafeItemField {
    public enum Kind: String, CaseIterable, Codable {
        case text
        case url
        case password
        case note
        case email
        case phone
        case date
        case time
        case dateAndTime
        case number
        case creditCardNumber
        case iban
        case socialSecurityNumber
        case monthYear
        case file
        case photo
        case video
    }

    public var id: String
    public var encName: Data?
    public var position: Double
    public var itemId: String
    public var encPlaceholder: Data?
    public var encValue: Data?
    public var showPrediction: Bool
    public var encKind: Data?
    public var createdAt: Date
    public var updatedAt: Date
    public var isItemIdentifier: Bool
    public var encFormattingMask: Data?
    public var encSecureDisplayMask: Data?
    public var isSecured: Bool

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

extension SafeItemField: Hashable {
    public static func == (lhs: SafeItemField, rhs: SafeItemField) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(updatedAt)
    }
}
