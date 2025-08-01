//
//  FileManager+Extension.swift
//  ThumbnailsCaching
//
//  Created by Lunabee Studio (Nicolas) on 11/10/2023 - 08:21.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

extension FileManager {
    static var thumbnailsCacheDirectoryUrl: URL? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return cachesDirectory.appending(path: "thumbnailsCache")
    }
}
