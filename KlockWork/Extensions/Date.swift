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
}
