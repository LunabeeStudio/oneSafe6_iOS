//
//  Keychain+Extension.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation

public enum KeychainKey: String {
    case masterKey = "mk"
    case searchIndexMasterKey = "smk"
    case bubblesMasterKey = "bmk"

    // Obsolete keychain keys
    @available(*, deprecated, message: "This data is now stored into a file.")
    case masterSalt = "mslt"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case searchIndexSalt = "sislt"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case databaseName = "dbn"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case importDatabaseName = "idbn"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case searchDatabaseName = "srch"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case bubblesDatabaseName = "bbls"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case cryptoToken = "ct"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case inactivityAutolockOption = "iao"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case byChangingAppAutolockOption = "bcaao"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case clearPasteboardOption = "cpo"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case passwordVerificationInterval = "pvi"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case lastPasswordVerificationTimestamp = "lpvt"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case proximityLockOption = "plo"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case currentSafeItemDraft = "csid"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case bubblesInputMessageDraft = "bimd"
    @available(*, deprecated, message: "This data is now stored into a file.")
    case searchText = "st"

    @available(*, deprecated, message: "This data is now stored into a file.")
    public static var obsoleteStringKeys: [KeychainKey] {
        [
            .databaseName,
            .importDatabaseName,
            .searchDatabaseName,
            .bubblesDatabaseName,
            .inactivityAutolockOption,
            .byChangingAppAutolockOption,
            .clearPasteboardOption,
            .passwordVerificationInterval,
            .lastPasswordVerificationTimestamp,
            .proximityLockOption,
            .searchText
        ]
    }

    @available(*, deprecated, message: "This data is now stored into a file.")
    public static var obsoleteDataKeys: [KeychainKey] {
        [
            .masterSalt,
            .searchIndexSalt,
            .cryptoToken,
            .currentSafeItemDraft,
            .bubblesInputMessageDraft
        ]
    }
}
