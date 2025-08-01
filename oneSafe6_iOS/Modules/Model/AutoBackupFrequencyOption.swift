//
//  AutoBackupFrequencyOption.swift
//  Model
//
//  Created by Lunabee Studio (Alexandre Cools) on 26/04/2023 - 4:45 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public enum AutoBackupFrequencyOption: String, CaseIterable {
    case everyDay
    case everyWeek
    case everyMonth

    public static let defaultValue: AutoBackupFrequencyOption = .everyDay
}
