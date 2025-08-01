//
//  CryptoRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 15:12.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import LocalAuthentication
import Combine

public protocol CryptoRepository {
    func getMasterSalt() throws -> Data
    func getSearchIndexSalt() throws -> Data
    func saveMasterSalt(_ salt: Data) throws
    func saveSearchIndexSalt(_ salt: Data) throws
    func isBiometryActivated() -> Bool
    func observeIsBiometryActivated() -> CurrentValueSubject<Bool, Never>
    func getMasterKey(context: LAContext) throws -> Data
    func getSearchIndexMasterKey(context: LAContext) throws -> Data
    func getEncBubblesMasterKey() throws -> Data
    func save(masterKey: Data) throws
    func save(searchIndexMasterKey: Data) throws
    func save(encBubblesMasterKey: Data) throws
    func deleteBiometryMasterKeys() throws
    func cryptoToken() throws -> Data?
    func save(cryptoToken: Data) throws
}
