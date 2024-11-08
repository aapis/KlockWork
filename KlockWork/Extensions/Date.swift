//
//  Date.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-02.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import Foundation

extension Date {
    // Thanks: https://stackoverflow.com/a/50958263
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    // Thanks: https://stackoverflow.com/q/46402684
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }

    // Thanks: https://stackoverflow.com/q/46402684
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }

    var startOfMonth: Date? {
        if let (start, _) = DateHelper.datesAtStartAndEndOfMonth(for: self) {
            return start
        }
        return nil
    }

    var endOfMonth: Date? {
        if let (_, end) = DateHelper.datesAtStartAndEndOfMonth(for: self) {
            return end
        }
        return nil
    }

    var startOfYear: Date? {
        let cYear = DateHelper.todayShort(self, format: "yyyy")
        if let start = DateHelper.date(from: "\(cYear)/01/01 00:00") {
            return start
        }
        return nil
    }

    var endOfYear: Date? {
        let cYear = DateHelper.todayShort(self, format: "yyyy")
        if let end = DateHelper.date(from: "\(cYear)/12/31 11:59") {
            return end
        }
        return nil
    }
}
