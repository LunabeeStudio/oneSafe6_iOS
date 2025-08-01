//
//  SafeItemBundle.swift
//  oneSafe
//
//  Created by Lunabee Studio on 13/10/2022 - 15:59.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation
import SwiftUI

public struct SafeItemBundle: Identifiable, Hashable {
    public var id: String { item.id }
    public let item: SafeItem
    public let fields: [SafeItemField]
    public let key: SafeItemKey
    public let defaultColor: Color?
    public let itemCreationOption: CreationOption?
    public let fromFilesUrls: [URL]?

    public init(item: SafeItem, fields: [SafeItemField], key: SafeItemKey, defaultColor: Color? = nil, itemCreationOption: CreationOption? = nil, fromFilesUrls: [URL] = []) {
        self.item = item
        self.fields = fields
        self.key = key
        self.defaultColor = defaultColor
        self.itemCreationOption = itemCreationOption
        self.fromFilesUrls = fromFilesUrls
    }
}

public extension SafeItemBundle {
    enum CreationOption {
        case addMediaFromLibrary
        case addMediaFromCamera
        case addMediaFromFile
        case addFile
        case fromFiles
    }
}
