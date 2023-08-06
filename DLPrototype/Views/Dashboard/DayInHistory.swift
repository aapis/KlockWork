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
    private var formattedDate: String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: date)
    }

    public func linkLabel() -> String {
        if count == 1 {
            return "\(count) record on \(formattedDate)"
        } else if count > 0 {
            return "\(count) records on \(formattedDate)"
        }

        return "No records from \(formattedDate)"
    }
}
