//
//  SafeItemIconImportRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 27/02/2023 - 11:01.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public protocol SafeItemIconImportRepository {
    func allImportIconsUrls() throws -> [URL]
    func saveImportIcons(for urls: [URL], progress: Progress) async throws
    func processIconsImport(progress: Progress) async throws
    func deleteAllImportIcons() throws
    func saveIconData(_ encData: Data, iconId: String) throws
}
