//
//  TimeInterval+Extension.swift
//  oneSafe
//
//  Created by Lunabee Studio (François Combe) on 09/05/2023 - 15:52.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

extension TimeInterval {
    static func seconds(_ seconds: Double) -> TimeInterval {
        seconds
    }

    static func minutes(_ minutes: Double) -> TimeInterval {
        minutes * seconds(60)
    }

    static func hours(_ hours: Double) -> TimeInterval {
        hours * minutes(60)
    }

    static func days(_ days: Double) -> TimeInterval {
        days * hours(24)
    }
}
