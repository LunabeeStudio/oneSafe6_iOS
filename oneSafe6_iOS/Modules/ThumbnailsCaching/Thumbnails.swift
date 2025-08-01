//
//  Thumbnails.swift
//  ThumbnailsCaching
//
//  Created by Lunabee Studio (Nicolas) on 11/10/2023 - 08:18.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit
import QuickLookThumbnailing
import Errors
import ColorKit
import Extensions

public struct Thumbnails {
    public enum Kind: Sendable {
        case thumbnail
        case icon
    }

    public static func generateNotCachedThumbnail(url: URL) async throws -> UIImage {
        let request: QLThumbnailGenerator.Request = await QLThumbnailGenerator.Request(
            fileAt: url,
            size: Constant.fileLargeThumbnailSize,
            scale: UIScreen.main.scale,
            representationTypes: .thumbnail
        )
        return try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request).uiImage
    }

    public static func doesThumbnailExistsFor(id: String) -> Bool {
        guard let thumbnailUrl = thumbnailsDirectoryUrl?.appending(path: id) else { return false }
        return FileManager.default.fileExists(atPath: thumbnailUrl.path())
    }

    public static func doesIconExistsFor(id: String) -> Bool {
        guard let iconUrl = iconsDirectoryUrl?.appending(path: id) else { return false }
        return FileManager.default.fileExists(atPath: iconUrl.path())
    }

    public static func getImageDataFor(id: String,
                                       url: URL,
                                       kind: Kind,
                                       defaultImage: UIImage?,
                                       encryptionBlock: (_ data: Data) throws -> Data?,
                                       decryptionBlock: (_ encData: Data) throws -> Data?) async throws -> Data? {
        do {
            let encData: Data = try getEncryptedImageData(id: id, kind: kind)
            let imageData: Data? = try decryptionBlock(encData)
            return imageData
        } catch AppError.thumbnailsNoImageData {
            guard let imageData = (try await generateImage(url: url, kind: kind)?.pngData()) ?? defaultImage?.pngData() else {
                throw AppError.thumbnailsGetIconUnknownIssue
            }
            guard let encImageData = try encryptionBlock(imageData) else {
                throw AppError.thumbnailsGetIconUnknownIssue
            }
            try writeEncryptedImage(encImageData, id: id, kind: kind)
            return imageData
        } catch {
            throw AppError.thumbnailsGetIconUnknownIssue
        }
    }

    public static func deleteImagesFor(id: String) {
        (iconsDirectoryUrl?.appending(path: id)).map { try? FileManager.default.removeItem(at: $0) }
        (thumbnailsDirectoryUrl?.appending(path: id)).map { try? FileManager.default.removeItem(at: $0) }
    }

    public static func deleteAll() {
        iconsDirectoryUrl.map { try? FileManager.default.removeItem(at: $0) }
        thumbnailsDirectoryUrl.map { try? FileManager.default.removeItem(at: $0) }
    }
}

// MARK: - Thumbnails generation
private extension Thumbnails {
    static func generateImage(url: URL, kind: Kind) async throws -> UIImage? {
        switch kind {
        case .thumbnail:
            try await generateThumbnail(url: url)
        case .icon:
            try await generateIcon(url: url)
        }
    }

    static func generateThumbnail(url: URL) async throws -> UIImage {
        let request: QLThumbnailGenerator.Request = await QLThumbnailGenerator.Request(
            fileAt: url,
            size: Constant.fileLargeThumbnailSize,
            scale: UIScreen.main.scale,
            representationTypes: .thumbnail
        )
        return try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request).uiImage
    }

    static func generateIcon(url: URL) async throws -> UIImage? {
        let request: QLThumbnailGenerator.Request = await QLThumbnailGenerator.Request(
            fileAt: url,
            size: Constant.fileSmallThumbnailSize,
            scale: UIScreen.main.scale,
            representationTypes: .icon
        )
        let generatedImage: UIImage = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request).uiImage
        let colorsCount: Int = try generatedImage.dominantColors().filter { !$0.isGray }.count
        return colorsCount > 0 ? generatedImage : nil
    }
}

// MARK: - Thumbnails reading
private extension Thumbnails {
    static func getEncryptedImageData(id: String, kind: Kind) throws -> Data {
        switch kind {
        case .thumbnail:
            try getEncryptedThumbnailData(id: id)
        case .icon:
            try getEncryptedIconData(id: id)
        }
    }

    static func getEncryptedThumbnailData(id: String) throws -> Data {
        guard let thumbnailsDirectory = thumbnailsDirectoryUrl else {
            throw AppError.thumbnailsNoCacheDirectory
        }
        let thumbnailUrl: URL = thumbnailsDirectory.appending(path: id)
        if !FileManager.default.fileExists(atPath: thumbnailsDirectory.path()) {
            try FileManager.default.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
        }
        guard FileManager.default.fileExists(atPath: thumbnailUrl.path()) else {
            throw AppError.thumbnailsNoImageData
        }
        return try Data(contentsOf: thumbnailUrl)
    }

    static func getEncryptedIconData(id: String) throws -> Data {
        guard let iconsDirectory = iconsDirectoryUrl else {
            throw AppError.thumbnailsNoCacheDirectory
        }
        let iconUrl: URL = iconsDirectory.appending(path: id)
        if !FileManager.default.fileExists(atPath: iconsDirectory.path()) {
            try FileManager.default.createDirectory(at: iconsDirectory, withIntermediateDirectories: true)
        }
        guard FileManager.default.fileExists(atPath: iconUrl.path()) else {
            throw AppError.thumbnailsNoImageData
        }
        return try Data(contentsOf: iconUrl)
    }
}

// MARK: - Thumbnails writing
private extension Thumbnails {
    static func writeEncryptedImage(_ encImageData: Data, id: String, kind: Kind) throws {
        switch kind {
        case .thumbnail:
            try writeEncryptedThumbnail(encImageData, id: id)
        case .icon:
            try writeEncryptedIcon(encImageData, id: id)
        }
    }

    static func writeEncryptedThumbnail(_ encThumbnailData: Data, id: String) throws {
        guard let thumbnailsDirectory = thumbnailsDirectoryUrl else {
            throw AppError.thumbnailsNoCacheDirectory
        }
        if !FileManager.default.fileExists(atPath: thumbnailsDirectory.path()) {
            try FileManager.default.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
        }
        try encThumbnailData.write(to: thumbnailsDirectory.appending(path: id))
    }

    static func writeEncryptedIcon(_ encIconData: Data, id: String) throws {
        guard let iconsDirectory = iconsDirectoryUrl else {
            throw AppError.thumbnailsNoCacheDirectory
        }
        if !FileManager.default.fileExists(atPath: iconsDirectory.path()) {
            try FileManager.default.createDirectory(at: iconsDirectory, withIntermediateDirectories: true)
        }
        try encIconData.write(to: iconsDirectory.appending(path: id))
    }
}

// MARK: - Thumbnails urls
private extension Thumbnails {
    static var thumbnailsDirectoryUrl: URL? { FileManager.thumbnailsCacheDirectoryUrl?.appending(path: "thumbnails") }
    static var iconsDirectoryUrl: URL? { FileManager.thumbnailsCacheDirectoryUrl?.appending(path: "icons") }
}
