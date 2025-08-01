//
//  BubblesArchiveRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 21/11/2024 - 11:10.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import ZIPFoundation
import Protocols
import oneSafeKmp

final class ArchiveBubblesRepositoryImpl: ArchiveBubblesRepository {
    // MARK: Export

    func writeMessageData(_ data: Data) throws {
        try data.write(to: archiveMessageFileUrl(create: true), options: .atomic)
    }

    func addAttachment(url: URL) throws {
        try FileManager.default.moveItem(at: url, to: archiveAttachmentUrl(create: true))
    }

    func zipArchive() throws -> URL {
        let destinationUrl: URL = try finalDestinationFileUrl(create: true)
        try FileManager.default.zipItem(at: archiveContentDirectoryUrl(create: false),
                                        to: destinationUrl,
                                        shouldKeepParent: false,
                                        compressionMethod: .deflate)
        return destinationUrl
    }

    func clearExportData() throws {
        let unarchiveUrl: URL = try archiveDirectoryUrl(create: false)
        if FileManager.default.fileExists(atPath: unarchiveUrl.path) {
            try FileManager.default.removeItem(at: unarchiveUrl)
        }
    }

    // MARK: Import

    func unzipArchive(url: URL) throws -> URL {
        let extractDirectoryUrl: URL = try unarchiveDirectoryUrl(create: true).appending(path: url.lastPathComponent)
        // Check if it is not already unzipped
        if !FileManager.default.fileExists(atPath: extractDirectoryUrl.path) {
            try FileManager.default.unzipItem(at: url, to: extractDirectoryUrl)
        }
        return extractDirectoryUrl
    }

    func getImportedMessageData(at url: URL) throws -> Data {
        let completeUrl: URL = importedMessageUrl(root: url)
        return try Data(contentsOf: completeUrl)
    }

    func getAttachmentUrlIfExist(at url: URL) -> URL? {
        let completeUrl: URL = importedAttachmentUrl(root: url)
        return FileManager.default.fileExists(atPath: completeUrl.path()) ? completeUrl : nil
    }

    func clearImportData() throws {
        let unarchiveUrl: URL = try unarchiveDirectoryUrl(create: false)
        if FileManager.default.fileExists(atPath: unarchiveUrl.path) {
            try FileManager.default.removeItem(at: unarchiveUrl)
        }
    }
}

private extension ArchiveBubblesRepositoryImpl {
    func archiveDirectoryUrl(create: Bool) throws -> URL {
        try rootDirectoryUrl(create: create, name: Constant.Archive.DirectoryName.bubblesArchive)
    }

    func archiveContentDirectoryUrl(create: Bool) throws -> URL {
        try archiveDirectoryUrl(create: create).appendingDirectory(path: Constant.Archive.DirectoryName.archiveContent)
    }

    func archiveMessageFileUrl(create: Bool) throws -> URL {
        try archiveContentDirectoryUrl(create: create).appending(path: MessagingConstant().MessageFileName)
    }

    func archiveAttachmentUrl(create: Bool) throws -> URL {
        try archiveContentDirectoryUrl(create: create).appending(path: MessagingConstant().AttachmentFileName)
    }

    func finalDestinationFileUrl(create: Bool) throws -> URL {
        try archiveDirectoryUrl(create: create).appending(path: UUID().uuidString).appendingPathExtension("zip")
    }

    func unarchiveDirectoryUrl(create: Bool) throws -> URL {
        try rootDirectoryUrl(create: create, name: Constant.Archive.DirectoryName.bubblesUnarchive)
    }

    func importedMessageUrl(root: URL) -> URL {
        root.appending(path: MessagingConstant().MessageFileName)
    }

    func importedAttachmentUrl(root: URL) -> URL {
        root.appending(path: MessagingConstant().AttachmentFileName)
    }
}

// MARK: - Utils -
private extension ArchiveBubblesRepositoryImpl {
    func rootDirectoryUrl(create: Bool = true, clear: Bool = false, name: String) throws -> URL {
        let directoryUrl: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        if clear {
            try? FileManager.default.removeItem(at: directoryUrl)
        }
        if (create || clear) && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}

private extension URL {
    func createDirectory(path: String) throws {
        let directoryUrl: URL = appending(path: path)
        if !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
    }

    /// - Warning: If used in a TasKGroup it can lead to errors when trying to create the same directory simultaneously. Make sure the directory is already created before calling this several times in a TaskGroup.
    func appendingDirectory(path: String) throws -> URL {
        let directoryUrl: URL = appending(path: path)
        if !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}
