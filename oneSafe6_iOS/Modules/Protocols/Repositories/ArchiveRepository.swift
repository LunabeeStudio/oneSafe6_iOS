//
//  ArchiveRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (Rémi Lanteri) on 27/02/2023 - 11:22.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Model
import Combine

public protocol ArchiveRepository {
    var archiveExtensions: [String] { get }
    var lastAutoBackupDate: Date? { get }
    var supportedVersion: Int { get }
    func observeLastAutoBackupDate() -> CurrentValueSubject<Date?, Never>
    func updateLastAutoBackupDate(_ date: Date)
    func writeExportArchiveMetadata(archiveKind: ArchiveKind, itemsCount: Int, contactsCount: Int, cryptoToken: Data?) throws
    func writeExportArchiveData(exportData: ExportData, toSalt: Data, progress: Progress) async throws
    func copyIconsToIconsExport(iconsUrls: [URL], progress: Progress) async throws
    func copyFilesToFilesExport(filesUrls: [URL], progress: Progress) async throws
    func zipArchive(archiveKind: ArchiveKind, progress: Progress) throws -> URL
    func getUrlsToAuthorizeFileSystemIcloudBackup(_ isAuthorized: Bool) throws
    func copyArchiveToImportToInbox(archiveUrl: URL) throws -> URL
    func unzipArchive(inboxArchiveUrl: URL, progress: Progress?) throws -> URL
    func getImportArchiveInfo(archiveExtractionUrl: URL) throws -> ArchiveInfo
    func getImportArchiveContent(archiveExtractionUrl: URL, safeId: String, progress: Progress) async throws -> ArchiveImportContent
    func getImportArchiveIconsUrls(archiveExtractionUrl: URL) throws -> [URL]
    func getImportArchiveFilesUrls(archiveExtractionUrl: URL) throws -> [URL]
    func clearExportArchiveFiles() throws
    func clearImportArchiveFiles() throws
    func getAllLocalAutoBackupUrls() throws -> [URL]
    func getAllICloudAutoBackupUrls() throws -> [URL]
    func copyAutoBackupToICloudDrive(backupUrl: URL) throws
    func moveAutoBackupToLocalDirectory(backupUrl: URL) throws
    func getAutoBackupDirectoryUrl() throws -> URL
    func getAutoBackupICloudDriveDirectoryUrl() throws -> URL
    func lastManualBackupDate() -> CurrentValueSubject<Date, Never>
    func setLastManualBackupDate(_ value: Date)
}
