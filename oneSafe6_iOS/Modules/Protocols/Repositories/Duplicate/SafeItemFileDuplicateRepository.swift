//
//  SafeItemFileDuplicateRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Nicolas Dominati) on 07/09/2023 - 12:00.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public protocol SafeItemFileDuplicateRepository {
    func allDuplicateFilesUrls() throws -> [URL]
    func saveDuplicateFiles(for urls: [URL]) async throws
    func processFilesDuplicate() async throws
    func deleteAllDuplicateFiles() throws
    func writeEncryptedFileDataToDuplicateDirectory(_ encData: Data, fileId: String) throws -> URL
}
