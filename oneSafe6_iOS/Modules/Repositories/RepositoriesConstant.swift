//
//  Repository.swift
//  Repositories
//
//  Created by Lunabee Studio (Nicolas) on 13/02/2023 - 10:19.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

enum Constant {
    enum Archive {
        enum Platform {
            static let ios: String = "ios"
            static let android: String = "android"
        }

        enum FileExtension {
            static let backup: String = "os6lsb"
            static let sharing: String = "os6lss"

            static var all: [String] = [backup, sharing]
        }

        enum DirectoryName {
            static let archive: String = "archive"
            static let archiveContent: String = "content"
            static let archiveIcons: String = "icons"
            static let archiveFiles: String = "files"
            static let archiveInbox: String = "archiveInbox"
            static let unarchive: String = "unarchive"
            static let autoBackup: String = "backups"
            static let bubblesArchive: String = "bubblesArchive"
            static let bubblesUnarchive: String = "bubblesUnarchive"
        }

        enum FileName {
            static let archiveMetadata: String = "metadata"
            static let archiveData: String = "data"
        }

        /// Value is 2.
        static let version: Int = 2
    }

    enum SupportFile {
        static let prefillFileName: String = "prefill"
        static let discoverFileName: String = "discover"
        static let fileType: String = "json"
    }

    enum ICloud {
        static let ubiquityContainter: String = "iCloud.studio.lunabee.oneSafe.ios"
    }
}
