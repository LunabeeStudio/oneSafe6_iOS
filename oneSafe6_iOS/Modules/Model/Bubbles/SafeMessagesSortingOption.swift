//
//  ItemsSortingOption.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 16/11/2023 - 20:30.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum SafeMessagesSortingOption: String {
    case order

    public var safeMessageIndexValueName: String {
        switch self {
        case .order:
            "order"
        }
    }
}
