//
//  ContactKeyRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 28/05/2025 - 13:40.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import Model
@preconcurrency import oneSafeKmp

public protocol ContactKeyRepository: ContactKeyLocalDataSource {
    func deleteAll() throws
}
