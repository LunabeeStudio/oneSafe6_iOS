//
//  ForceUpgradeRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 31/03/2023 - 10:34.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model
import Combine

public protocol ForceUpgradeRepository {
    var dataPublisher: AnyPublisher<ForceUpgradeData?, Never> { get }
    func fetchInfo() async throws -> ForceUpgradeInfo
    func fetchStrings(url: String) async throws -> ForceUpgradeStrings
    func getLastData() throws -> ForceUpgradeData?
    func saveData(_ data: ForceUpgradeData) throws
    func cleanData()
}
