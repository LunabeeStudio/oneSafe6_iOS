//
//  DiscoveryRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Quentin Noblet) on 02/06/2023 - 10:21.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model

public protocol DiscoveryRepository {
    func getTutorialItemsDiscovery() throws -> Discovery
    func getFoldersDiscovery() throws -> Discovery
}
