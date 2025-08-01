//
//  SafeItemIconRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 22/02/2023 - 17:02.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public protocol SafeItemIconRepository {
    func getEncryptedIconData(id: String) throws -> Data?
    func saveEncryptedIconData(_ encData: Data, previousIconId: String?) throws -> String
    func deleteIconData(iconId: String) throws
    func getAllIconsUrls() throws -> [URL]
    func getAllIconsUrls(for iconsIds: [String]) throws -> [URL]
    func deleteAllIcons() throws
}
