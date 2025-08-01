//
//  FileKey.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 20/01/2025 - 10:43.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Foundation

public enum FileKey: String {
    case databaseName = "dbn"
    case importDatabaseName = "idbn"
    case searchDatabaseName = "srch"
    case bubblesDatabaseName = "bbls"
    case inactivityAutolockOption = "iao"
    case byChangingAppAutolockOption = "bcaao"
    case clearPasteboardOption = "cpo"
    case passwordVerificationInterval = "pvi"
    case lastPasswordVerificationTimestamp = "lpvt"
    case proximityLockOption = "plo"
    case searchText = "st"

    case masterSalt = "mslt"
    case searchIndexSalt = "sislt"
    case cryptoToken = "ct"
    case currentSafeItemDraft = "csid"
    case bubblesInputMessageDraft = "bimd"

}
