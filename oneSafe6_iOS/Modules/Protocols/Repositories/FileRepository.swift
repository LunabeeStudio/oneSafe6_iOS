//
//  FileRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 31/07/2023 - 16:08.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

public protocol FileRepository {
    func getAllEncryptedFileUrlInStorage() throws -> [URL]
    func getEncryptedFileUrlInStorage(fileId: String) throws -> URL
    func getEncryptedFileDataFromStorage(fileId: String) throws -> Data?
    func saveEncryptedFileDataToStorage(_ encData: Data, fileId: String) throws
    func deleteFileDataFromStorage(fileId: String) throws
    func deleteAllFileDataFromStorage() throws

    func temporayReadEditDirectoryUrl(directoryId: String) throws -> URL
    func temporayReadEditDirectoryContentFileNames(directoryId: String) throws -> [String]
    func saveDecryptedFileDataToReadEditTemporaryDirectory(fileName: String, directoryId: String, data: Data) throws -> URL
    func getDecryptedFileUrlInTemporaryDirectory(fileName: String, directoryId: String) throws -> URL
    func removeAllFilesInReadEditTemporaryDirectory(directoryId: String) async throws
    func clearReadEditTemporaryDirectory() throws
    func clearTemporaryDirectory() throws

    func getEncryptedFileDataFromAutolockDirectory(fileId: String) throws -> Data?
    func saveEncryptedFileDataToAutolockDirectory(_ encData: Data, fileId: String) throws
    func clearAutolockDirectory() async throws
}
