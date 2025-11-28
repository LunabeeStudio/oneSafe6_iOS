//
//  SentMessageRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 21/11/2024 - 11:11.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

@preconcurrency import oneSafeKmp

public protocol SentMessageRepository: SentMessageLocalDatasource {
    func deleteAll() throws
}
