//
//  URL+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Alexandre Cools) on 06/04/2023 - 4:10 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    public var size: Int64 {
        if isDirectory {
            let urls: [URL] = (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])) ?? []
            let size: Int64 = urls.reduce(0) { $0 + $1.size }
            return size
        } else {
            return Int64((try? resourceValues(forKeys: [.totalFileSizeKey]))?.totalFileSize ?? 0)
        }
    }

    public var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false }

    public var mimeType: String {
        UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }

    public mutating func excludeFromBackup(_ newValue: Bool) throws {
        var values: URLResourceValues = URLResourceValues()
        values.isExcludedFromBackup = newValue
        try setResourceValues(values)
    }

    public func moveFileToTmpDirectory() throws -> URL {
        let newUrl: URL = FileManager.default.temporaryDirectory.appending(path: self.lastPathComponent, directoryHint: .notDirectory)
        try? FileManager.default.removeItem(at: newUrl)
        try FileManager.default.moveItem(at: self, to: newUrl)
        return newUrl
    }

    public func incrementingDestinationFileNameIfNeeded() throws -> URL {
        let parentDirectoryUrl: URL = deletingLastPathComponent()
        var fileName: String = lastPathComponent
        let existingFileNames: [String] = try FileManager.default.contentsOfDirectory(at: parentDirectoryUrl, includingPropertiesForKeys: nil).map { $0.lastPathComponent }
        if !existingFileNames.filter({ $0.localizedStandardContains(fileName) }).isEmpty {
            let firstFileNamePart: String = fileName.components(separatedBy: ".")[0]
            let remainingFilePart: String = fileName.replacingOccurrences(of: firstFileNamePart, with: "")
            var count: Int = 1
            var currentFileName: String = ""
            var isCurrentFileNameAvailable: Bool = false

            while !isCurrentFileNameAvailable {
                count += 1
                currentFileName = "\(firstFileNamePart)-\(count)\(remainingFilePart)"
                isCurrentFileNameAvailable = existingFileNames.filter {
                    $0.localizedStandardContains(currentFileName)
                }.isEmpty
            }
            fileName = currentFileName
        }
        return parentDirectoryUrl.appending(path: fileName)
    }
}
