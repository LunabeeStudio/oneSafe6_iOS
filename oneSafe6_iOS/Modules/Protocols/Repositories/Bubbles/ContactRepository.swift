//
//  ContactRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 28/08/2024 - 15:34.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

@preconcurrency import oneSafeKmp
import Combine

public protocol ContactRepository: ContactLocalDataSource {
    func startObserving() throws
    func stopObserving()
    func hasContact() throws -> Bool
    func observeHasContact() throws -> AnyPublisher<Bool, Never>
    func getAllContacts() -> [oneSafeKmp.Contact]
    func safeGetAllContacts() throws -> [oneSafeKmp.Contact]
    func deleteAll() throws
}
