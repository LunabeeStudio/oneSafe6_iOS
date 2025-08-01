//
//  ForceUpgradeRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 31/03/2023 - 10:29.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model
import Server
import Protocols
import Storage
import Combine

final class ForceUpgradeRepositoryImpl: ForceUpgradeRepository {
    @Published private var data: ForceUpgradeData?
    var dataPublisher: AnyPublisher<ForceUpgradeData?, Never> { $data.eraseToAnyPublisher() }

    init() {
        guard let data = UserDefaultsManager.shared.forceUpgradeData else { return }
        self.data = try? JSONDecoder().decode(ForceUpgradeData.self, from: data)
    }

    func fetchInfo() async throws -> ForceUpgradeInfo {
        let data: Data = try await ForceUpgradeServer.getUpgradeInfo()
        return try JSONDecoder().decode(ForceUpgradeInfo.self, from: data)
    }

    func fetchStrings(url: String) async throws -> ForceUpgradeStrings {
        let data: Data = try await ForceUpgradeServer.getStrings(url: url)
        return try JSONDecoder().decode(ForceUpgradeStrings.self, from: data)
    }

    func getLastData() throws -> ForceUpgradeData? {
        data
    }

    func saveData(_ data: ForceUpgradeData) throws {
        let encodedData: Data = try JSONEncoder().encode(data)
        self.data = data
        UserDefaultsManager.shared.forceUpgradeData = encodedData
    }

    func cleanData() {
        UserDefaultsManager.shared.forceUpgradeData = nil
        data = nil
    }

}
