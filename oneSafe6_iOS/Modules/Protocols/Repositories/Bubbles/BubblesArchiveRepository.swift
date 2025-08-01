//
//  BubblesArchiveRepository.swift
//  Protocols
//
//  Created by Lunabee Studio (François Combe) on 21/11/2024 - 11:11.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

public protocol ArchiveBubblesRepository {
    func writeMessageData(_ data: Data) throws
    func addAttachment(url: URL) throws
    func zipArchive() throws -> URL
    func clearExportData() throws
    func unzipArchive(url: URL) throws -> URL
    func getImportedMessageData(at url: URL) throws -> Data
    func getAttachmentUrlIfExist(at url: URL) -> URL?
    func clearImportData() throws
}
