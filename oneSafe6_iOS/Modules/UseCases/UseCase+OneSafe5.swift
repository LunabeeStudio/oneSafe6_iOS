//
//  UseCase+OneSafe5.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 13/02/2023 - 17:11.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit

public extension UseCase {
    @MainActor
    static func canImportFromOldOnesafe() -> Bool {
        guard let url = URL(string: Constant.Archive.OldOneSafe.urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    @MainActor
    static func openOldOneSafeForExport() async {
        guard let url = URL(string: "\(Constant.Archive.OldOneSafe.urlScheme)\(Constant.Archive.OldOneSafe.exportBackupUrlPath)") else { return }
        await UIApplication.shared.open(url)
    }
}
