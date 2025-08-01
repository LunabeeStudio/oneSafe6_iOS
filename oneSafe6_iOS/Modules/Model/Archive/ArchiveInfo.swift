//
//  ArchiveInfo.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 06/12/2022 - 11:26.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation

/// Model version of ArchiveMetadata protobuf file.
public struct ArchiveInfo: Equatable, Hashable {
    public let archiveKind: ArchiveKind
    public let isFromOneSafePlus: Bool
    public let archiveVersion: Int
    public let fromPlatform: String
    public let createdAt: Date
    public let itemsCount: Int
    public let archiveDirectoryUrl: URL
    public let cryptoToken: Data?
    public var archiveMasterKey: Data?
    public var archiveEncBubblesMasterKey: Data?
    public var hasBubblesData: Bool = false
    public var shouldImportItems: Bool = true
    public var shouldImportBubbles: Bool = false

    public init(
        archiveKind: ArchiveKind,
        isFromOneSafePlus: Bool,
        archiveVersion: Int,
        fromPlatform: String,
        createdAt: Date,
        itemsCount: Int,
        archiveDirectoryUrl: URL,
        cryptoToken: Data?
    ) {
        self.archiveKind = archiveKind
        self.isFromOneSafePlus = isFromOneSafePlus
        self.archiveVersion = archiveVersion
        self.fromPlatform = fromPlatform
        self.createdAt = createdAt
        self.itemsCount = itemsCount
        self.archiveDirectoryUrl = archiveDirectoryUrl
        self.cryptoToken = cryptoToken
    }
}
