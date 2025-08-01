//
//  ArchiveImportMode.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 07/12/2022 - 19:07.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation

public enum ArchiveImportMode {
    case append(ParentItemInfo? = nil)
    case replace

    public struct ParentItemInfo {
        public let parentName: String
        public let parentColor: String
        public let parentKey: SafeItemKey

        public init(parentName: String, parentColor: String, parentKey: SafeItemKey) {
            self.parentName = parentName
            self.parentColor = parentColor
            self.parentKey = parentKey
        }
    }
}
