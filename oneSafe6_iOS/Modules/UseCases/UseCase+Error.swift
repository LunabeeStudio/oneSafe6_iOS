//
//  UseCase+Error.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 11/05/2023 - 11:22.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public extension UseCase {
    static func isNotEnoughtSpaceError(_ error: Error) -> Bool {
        (((error as NSError).underlyingErrors.first as? NSError)?.underlyingErrors.first as? NSError)?.code == Constant.ErrorCode.storageSpace
    }
}
