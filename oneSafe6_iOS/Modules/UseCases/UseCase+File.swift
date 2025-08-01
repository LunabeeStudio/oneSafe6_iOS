//
//  UseCase+File.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 01/08/2023 - 15:29.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Protocols
import Model
import CoreCrypto
import Extensions
import Errors
import ThumbnailsCaching
import AVFoundation

public extension UseCase {
    static func saveFileToStorage(tempFileUrl: URL, field: SafeItemField, safeItemKey: SafeItemKey) throws {
        let fileData: Data = try Data(contentsOf: tempFileUrl)
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: safeItemKey) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.fileNoId }
        guard let encData = try getEncryptedDataFromData(data: fileData, key: safeItemKey) else { throw AppError.fileNoData }
        try fileRepository.saveEncryptedFileDataToStorage(encData, fileId: fileId)
    }

    static func removeFileFromStorage(field: SafeItemField, safeItemKey: SafeItemKey) throws {
        let fileId: String = try getFileIdFor(field: field, key: safeItemKey)
        try? fileRepository.deleteFileDataFromStorage(fileId: fileId)
        Thumbnails.deleteImagesFor(id: fileId)
    }

    static func copyDecryptedFileToTemporaryDirectory(field: SafeItemField, key: SafeItemKey) throws -> URL {
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.fileNoId }
        guard let encData = try fileRepository.getEncryptedFileDataFromStorage(fileId: fileId) else { throw AppError.fileNoData }
        guard let data = try getDataFromEncryptedData(data: encData, key: key) else { throw AppError.fileNoData }

        var fileName: String = try getStringFromEncryptedData(data: field.encName, key: key) ?? fileId
        if let fileExtension = fileIdAndExtension.components(separatedBy: "|").last {
            fileName = "\(fileName.components(separatedBy: ".")[0]).\(fileExtension)"
        }
        return try fileRepository.saveDecryptedFileDataToReadEditTemporaryDirectory(fileName: fileName, directoryId: field.itemId, data: data)
    }

    /// Generates an url in the temporary directory that is available for the given file name.
    /// If the given file name is already used, "-2", for example, will be added to it juste before de file extension.
    static func getAvailableUrlInReadEditTemporaryDirectory(itemId: String, fileName: String) throws -> URL {
        var destinationUrl: URL = try fileRepository.temporayReadEditDirectoryUrl(directoryId: itemId).appending(path: fileName)
        destinationUrl = try destinationUrl.incrementingDestinationFileNameIfNeeded()
        return destinationUrl
    }

    static func addNewFileToReadEditTemporaryDirectory(fileUrl: URL, destinationFileName: String? = nil, itemId: String) throws -> URL {
        let data: Data = try Data(contentsOf: fileUrl)
        let fileName: String = destinationFileName ?? fileUrl.lastPathComponent
        var destinationUrl: URL = try fileRepository.temporayReadEditDirectoryUrl(directoryId: itemId).appending(path: fileName)
        destinationUrl = try destinationUrl.incrementingDestinationFileNameIfNeeded()
        return try fileRepository.saveDecryptedFileDataToReadEditTemporaryDirectory(fileName: destinationUrl.lastPathComponent, directoryId: itemId, data: data)
    }

    static func getFileUrlInTemporaryDirectory(field: SafeItemField, key: SafeItemKey) throws -> URL {
        let fileName: String = try getFileNameFor(field: field, key: key)
        return try fileRepository.getDecryptedFileUrlInTemporaryDirectory(fileName: fileName, directoryId: field.itemId)
    }

    static func getFileNameFor(field: SafeItemField, key: SafeItemKey) throws -> String {
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.fileNoId }
        var fileName: String = try getStringFromEncryptedData(data: field.encName, key: key) ?? fileId
        if let fileExtension = fileIdAndExtension.components(separatedBy: "|").last {
            fileName = "\(fileName.components(separatedBy: ".")[0]).\(fileExtension)"
        }
        return fileName
    }

    static func getFileIdFor(field: SafeItemField, key: SafeItemKey) throws -> String {
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.fileNoId }
        return fileId
    }

    static func getFileExtensionFor(field: SafeItemField, key: SafeItemKey) throws -> String {
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").last else { throw AppError.fileNoId }
        return fileId
    }

    static func removeFileFromTemporaryDirectory(fileUrl: URL) {
        try? FileManager.default.removeItem(at: fileUrl)
    }

    static func removeAllFilesInReadEditTemporaryDirectory(itemId: String) async throws {
        try await fileRepository.removeAllFilesInReadEditTemporaryDirectory(directoryId: itemId)
    }

    static func clearReadEditTemporaryDirectory() throws {
        try fileRepository.clearReadEditTemporaryDirectory()
    }

    static func clearTemporaryDirectory() throws {
        try fileRepository.clearTemporaryDirectory()
    }

    static func saveFileToAutolockDirectory(tempFileUrl: URL, field: SafeItemField, key: SafeItemKey) throws {
        let fileData: Data = try Data(contentsOf: tempFileUrl)
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.fileNoId }
        guard let encData = try getEncryptedDataFromData(data: fileData, key: key) else { throw AppError.fileNoData }
        try fileRepository.saveEncryptedFileDataToAutolockDirectory(encData, fileId: fileId)
    }

    static func copyDecryptedFileFromAutolockDirectoryToTemporaryDirectory(field: SafeItemField, key: SafeItemKey) throws -> URL {
        guard let fileIdAndExtension = try getStringFromEncryptedData(data: field.encValue, key: key) else { throw AppError.fileNoId }
        guard let fileId = fileIdAndExtension.components(separatedBy: "|").first else { throw AppError.fileNoId }
        let fileName: String = try getStringFromEncryptedData(data: field.encName, key: key) ?? fileId
        guard let encData = try fileRepository.getEncryptedFileDataFromAutolockDirectory(fileId: fileId) else { throw AppError.fileNoData }
        guard let data = try getDataFromEncryptedData(data: encData, key: key) else { throw AppError.fileNoData }
        return try fileRepository.saveDecryptedFileDataToReadEditTemporaryDirectory(fileName: fileName, directoryId: field.itemId, data: data)
    }

    static func clearAutolockDirectory() async throws {
        try await fileRepository.clearAutolockDirectory()
    }

    /// Return false if the file at the given url exceed the maximum size accepted (for crypto performance reasons).
    static func checkFileSize(at url: URL) -> Bool {
        url.size <= Constant.File.maximumFileSizeAcceptedInMB * 1024 * 1024
    }

    static func isFileEmpty(at url: URL) -> Bool {
        url.size == 0
    }

    static func getMaximumFileSizeAccepted() -> Int {
        Constant.File.maximumFileSizeAcceptedInMB * 1024 * 1024
    }

    static func getMaximumFileSizeAcceptedInMB() -> Int {
        Constant.File.maximumFileSizeAcceptedInMB
    }

    static func getVideoFormattedDuration(url: URL?) async throws -> String? {
        guard let url else { return nil }
        let duration: CMTime = try await AVURLAsset(url: url).load(.duration)
        return duration.seconds.formatDuration()
    }

    static func getWaitingOpenInFilesUrls() throws -> [URL] {
        let openInDirectoryUrl: URL = try FileManager.openInInboxUrl()
        return try FileManager.default.contentsOfDirectory(at: openInDirectoryUrl, includingPropertiesForKeys: nil)
    }

    static func clearOpenInFilesUrls() throws {
        let openInDirectoryUrl: URL = try FileManager.openInInboxUrl()
        try FileManager.default.removeItem(at: openInDirectoryUrl)
    }
}
