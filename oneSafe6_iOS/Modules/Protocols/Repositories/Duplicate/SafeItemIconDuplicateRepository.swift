//
//  SafeItemIconDuplicateRepository.swift
//  oneSafe
//
//  Created by Lunabee Studio (Jérémie Carrez) on 27/06/2023 - 14:25.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public protocol SafeItemIconDuplicateRepository {
    func allDuplicateIconsUrls() throws -> [URL]
    func saveDuplicateIcons(for urls: [URL]) async throws
    func processIconsDuplicate() async throws
    func deleteAllDuplicateIcons() throws
    func saveIconData(_ encData: Data, iconId: String) throws
}
