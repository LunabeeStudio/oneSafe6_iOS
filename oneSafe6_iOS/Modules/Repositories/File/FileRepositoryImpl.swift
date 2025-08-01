//
//  FileRepositoryImpl.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 31/07/2023 - 16:10.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Storage

final class FileRepositoryImpl: FileRepository {
    private let fileManager: FileDirectoryManager = .shared

    func getAllEncryptedFileUrlInStorage() throws -> [URL] {
        try fileManager.getAllFilesUrlsInStorage()
    }

    func getEncryptedFileUrlInStorage(fileId: String) throws -> URL {
        try fileManager.getFileUrlInStorage(fileId: fileId)
    }

    func getEncryptedFileDataFromStorage(fileId: String) throws -> Data? {
        try fileManager.getFileDataFromStorage(fileId: fileId)
    }

    func saveEncryptedFileDataToStorage(_ encData: Data, fileId: String) throws {
        try fileManager.writeFileDataToStorage(encData, fileId: fileId)
    }

    func deleteFileDataFromStorage(fileId: String) throws {
        try fileManager.deleteFileDataFromStorage(fileId: fileId)
    }

    func deleteAllFileDataFromStorage() {
        fileManager.deleteAllFilesFromStorage()
    }

    func temporayReadEditDirectoryUrl(directoryId: String) throws -> URL {
        try fileManager.temporayReadEditDirectoryUrl(directoryId: directoryId)
    }

    func temporayReadEditDirectoryContentFileNames(directoryId: String) throws -> [String] {
        try fileManager.temporayReadEditDirectoryContentFileNames(directoryId: directoryId)
    }

    func saveDecryptedFileDataToReadEditTemporaryDirectory(fileName: String, directoryId: String, data: Data) throws -> URL {
        try fileManager.writeFileDataToTemporayReadEditDirectory(fileName: fileName, directoryId: directoryId, data: data)
    }

    func getDecryptedFileUrlInTemporaryDirectory(fileName: String, directoryId: String) throws -> URL {
        try fileManager.getFileUrlInTemporaryDirectory(fileName: fileName, directoryId: directoryId)
    }

    func removeAllFilesInReadEditTemporaryDirectory(directoryId: String) async throws {
        try await fileManager.removeAllFilesInReadEditTemporaryDirectory(directoryId: directoryId)
    }

    func clearReadEditTemporaryDirectory() throws {
        try fileManager.clearReadEditTemporaryDirectory()
    }

    func clearTemporaryDirectory() throws {
        try fileManager.clearReadEditTemporaryDirectory()
    }

    func getEncryptedFileDataFromAutolockDirectory(fileId: String) throws -> Data? {
        try fileManager.getFileDataFromAutolock(fileId: fileId)
    }

    func saveEncryptedFileDataToAutolockDirectory(_ encData: Data, fileId: String) throws {
        try fileManager.writeFileDataToAutolockDirectory(encData, fileId: fileId)
    }

    func clearAutolockDirectory() async throws {
        try await fileManager.clearAutolockDirectory()
    }
}
