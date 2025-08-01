//
//  FileManager+Extension.swift
//  Debug
//
//  Created by Nicolas on 03/08/2022.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation
import Errors

public extension FileManager {
    // swiftlint:disable force_try
    class func documentsDirectory() -> URL {
        try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }

    class func libraryDirectory() -> URL {
        try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    // swiftlint:enable force_try
    static func applicationGroupContainer() throws -> URL {
        guard let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constant.applicationGroup) else { throw AppError.storageUnableToAccessApplicationGroupContainer }
        return containerUrl
    }

    static func openInInboxUrl() throws -> URL {
        try applicationGroupContainer().appending(path: "openInInbox")
    }
}
