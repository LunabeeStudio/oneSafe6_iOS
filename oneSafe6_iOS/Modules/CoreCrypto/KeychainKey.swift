//
//  KeychainKey.swift
//  CoreCrypto
//
//  Created by Lunabee Studio (François Combe) on 29/06/2023 - 14:57.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import KeychainAccess

enum KeychainKey: String {
    case autoLoginMasterKey = "almk"
    case autoLoginSearchIndexMasterKey = "alsmk"
    case autoLoginBubblesMasterKey = "albmk"
}
