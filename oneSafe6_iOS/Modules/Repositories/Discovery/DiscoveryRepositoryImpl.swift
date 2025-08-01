//
//  DiscoveryRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (Quentin Noblet) on 02/06/2023 - 10:20.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Model
import Errors

final class DiscoveryRepositoryImpl: DiscoveryRepository {
    typealias File = Constant.SupportFile

    func getTutorialItemsDiscovery() throws -> Discovery {
        try getDiscovery(fileName: File.discoverFileName)
    }

    func getFoldersDiscovery() throws -> Discovery {
        try getDiscovery(fileName: File.prefillFileName)
    }

    private func getDiscovery(fileName: String) throws -> Discovery {
        guard let bundlePath = Bundle(for: type(of: self)).path(forResource: fileName, ofType: File.fileType) else {
            throw AppError.storageUnknown
        }

        if let data = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return try JSONDecoder().decode(Discovery.self, from: data)
        } else {
            throw AppError.storageUnknown
        }
    }
}
