//
//  HandShakeDataRepository.swift
//  oneSafe
//
//  Created by Lunabee Studio (Nicolas) on 13/06/2025 - 18:53.
//  Copyright © 2025 Lunabee Studio. All rights reserved.
//

import oneSafeKmp

public protocol HandShakeDataRepository: HandShakeDataLocalDatasource {
    func deleteAll() throws
}
