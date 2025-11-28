//
//  Date+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Alexandre Cools) on 20/01/2023 - 3:25 PM.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

public extension Date {
    init?(iso8601: String) {
        if let date = try? Date(iso8601, strategy: .iso8601WithoutTimeZone) {
            self = date
        } else if let date = try? Date(iso8601, strategy: .iso8601) {
            // Fallback iso8601 with timezone for old Android version.
            self = date
        } else {
            return nil
        }
    }

    init?(monthYear: String) {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "MM/yy"
        guard let date = formatter.date(from: monthYear) else {
            return nil
        }
        self = date
    }

    func toMonthYear() -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "MMyy"
        return dateFormatter.string(from: self)
    }

    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth())!
    }
}

public extension Date {
    static func + (lhs: Date, rhs: DateOffset) -> Date {
        Calendar.current.date(byAdding: rhs.components, to: lhs) ?? lhs
    }
    static func - (lhs: Date, rhs: DateOffset) -> Date {
        Calendar.current.date(byAdding: rhs.components.negated, to: lhs) ?? lhs
    }
}

public struct DateOffset {
    public static func days(_ value: Int) -> DateOffset { .init(components: DateComponents(day: value)) }
    public static func hours(_ value: Int) -> DateOffset { .init(components: DateComponents(hour: value)) }

    let components: DateComponents
}

// Negate all integer date components (used to implement Date - DateOffset)
private extension DateComponents {
    var negated: DateComponents {
        var c: DateComponents = self
        c.year = c.year.map { -$0 }
        c.month = c.month.map { -$0 }
        c.weekOfYear = c.weekOfYear.map { -$0 }
        c.weekOfMonth = c.weekOfMonth.map { -$0 }
        c.day = c.day.map { -$0 }
        c.hour = c.hour.map { -$0 }
        c.minute = c.minute.map { -$0 }
        c.second = c.second.map { -$0 }
        c.nanosecond = c.nanosecond.map { -$0 }
        return c
    }
}

public extension FormatStyle where Self == Date.ISO8601FormatStyle {
    static var iso8601WithoutTimeZone: Date.ISO8601FormatStyle { .iso8601(timeZone: .gmt) }
}

// MARK: - Private stuff -
private extension ParseStrategy where Self == Date.ISO8601FormatStyle {
    static var iso8601WithoutTimeZone: Date.ISO8601FormatStyle { .iso8601(timeZone: .gmt) }
}
