//
//  DayInHistory.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DayInHistory {
    public var year: Int
    public var date: Date
    public var count: Int
    public var highlight: Bool {
        return count == 0
    }

    public func linkLabel() -> String {
        if count == 1 {
            return "\(count) record on \(self.formatDate())"
        } else if count > 0 {
            return "\(count) records on \(self.formatDate())"
        }

        return "No records from \(self.formatDate("yyyy"))"
    }

    private func formatDate(_ format: String = "MMM d, yyyy") -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
}
