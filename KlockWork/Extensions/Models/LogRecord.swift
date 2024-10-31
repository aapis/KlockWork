//
//  LogRecord.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-31.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

extension LogRecord {
    @ViewBuilder var rowView: some View {
        LogRow(
            entry: Entry(
                timestamp: DateHelper.longDate(self.timestamp!),
                job: self.job!,
                message: self.message!
            ),
            index: 0,//records.firstIndex(of: self),
            colour: self.job?.backgroundColor ?? Theme.rowColour,
            record: self
        )
    }
}
