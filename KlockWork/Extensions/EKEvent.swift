//
//  EKEvent.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import EventKit

extension EKEvent {
    func startTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"

        return df.string(from: self.startDate)
    }

    func endTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"

        return df.string(from: self.endDate)
    }
}
