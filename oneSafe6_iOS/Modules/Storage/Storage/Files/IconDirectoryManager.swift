//
//  IconDirectoryManager.swift
//  Storage
//
//  Created by Lunabee Studio (Nicolas) on 21/12/2021 - 16:02.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

import Foundation
import Model

public final class IconDirectoryManager {
    public static let shared: IconDirectoryManager = .init()
    private init() { }

    public func writeIconDataToFile(_ data: Data, iconId: String) throws {
        try data.write(to: iconsDirectoryUrl().appendingPathComponent(iconId), options: .atomic)
    }

    public func readIconDataFromFile(iconId: String) throws -> Data? {
        try Data(contentsOf: iconsDirectoryUrl().appendingPathComponent(iconId), options: .alwaysMapped)
    }

    public func deleteIconFile(iconId: String) throws {
        try FileManager.default.removeItem(at: iconsDirectoryUrl().appendingPathComponent(iconId))
    }

    public func allIconsUrls() throws -> [URL] {
        let directoryUrl: URL = try iconsDirectoryUrl()
        return try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }

    public func deleteAllIcons() throws {
        let directoryUrl: URL = try iconsDirectoryUrl()
        try FileManager.default.removeItem(at: directoryUrl)
    }
}

// MARK: Import
public extension IconDirectoryManager {
    func allImportIconsUrls() throws -> [URL] {
        let directoryUrl: URL = try iconsImportDirectoryUrl(create: true)
        return try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }

    func saveImportIcons(for urls: [URL], progress: Progress) async throws {
        let directoryUrl: URL = try iconsImportDirectoryUrl(create: true)
        progress.totalUnitCount = Int64(urls.count)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    await MainActor.run(body: {
                        progress.completedUnitCount += 1
                    })
                    try FileManager.default.copyItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func processIconsImport(progress: Progress) async throws {
        let directoryUrl: URL = try iconsDirectoryUrl(create: true)
        let urls: [URL] = try allImportIconsUrls()
        progress.totalUnitCount = Int64(urls.count)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    await MainActor.run(body: {
                        progress.completedUnitCount += 1
                    })
                    try FileManager.default.moveItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func deleteAllImportIcons() throws {
        let directoryUrl: URL = try iconsImportDirectoryUrl(create: false)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            try FileManager.default.removeItem(at: directoryUrl)
        }
    }

    func writeImportIconDataToFile(_ data: Data, iconId: String) throws {
        try data.write(to: iconsImportDirectoryUrl().appendingPathComponent(iconId), options: .atomic)
    }
}

public extension IconDirectoryManager {
    func allDuplicateIconsUrls() throws -> [URL] {
        let directoryUrl: URL = try iconsDuplicateDirectoryUrl(create: true)
        guard FileManager.default.fileExists(atPath: directoryUrl.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }

    func saveDuplicateIcons(for urls: [URL]) async throws {
        let directoryUrl: URL = try iconsDuplicateDirectoryUrl(create: true)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    try FileManager.default.copyItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func processIconsDuplicate() async throws {
        let directoryUrl: URL = try iconsDirectoryUrl(create: true)
        let urls: [URL] = try allDuplicateIconsUrls()

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    try FileManager.default.moveItem(at: url, to: directoryUrl.appending(path: url.lastPathComponent))
                }
            }
            try await taskGroup.waitForAll() // This is needed in case of thrown error to raise it up.
        }
    }

    func deleteAllDuplicateIcons() throws {
        let directoryUrl: URL = try iconsDuplicateDirectoryUrl(create: false)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            try FileManager.default.removeItem(at: directoryUrl)
        }
    }

    func writeDuplicateIconDataToFile(_ data: Data, iconId: String) throws {
        try data.write(to: iconsDuplicateDirectoryUrl().appendingPathComponent(iconId), options: .atomic)
    }
}

private extension IconDirectoryManager {
    func iconsDirectoryUrl(create: Bool = true) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appendingPathComponent("icons")
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func iconsImportDirectoryUrl(create: Bool = true) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appendingPathComponent("iconsImport")
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }

    func iconsDuplicateDirectoryUrl(create: Bool = true) throws -> URL {
        let directoryUrl: URL = try FileManager.applicationGroupContainer().appendingPathComponent("iconsDuplicate")
        if create && !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return directoryUrl
    }
}
