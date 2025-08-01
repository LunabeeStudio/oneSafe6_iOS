//
//  ItemsSortingOption.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 16/11/2023 - 20:30.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum ItemsSortingOption: String {
    case creationDate
    case alphabetical
    case consultationDate

    public var itemIndexValueName: String {
        switch self {
        case .creationDate:
            "createdAtPosition"
        case .alphabetical:
            "alphabeticalPosition"
        case .consultationDate:
            "consultedAtPosition"
        }
    }
}
