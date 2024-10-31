//
//  LogTask.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-14.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension LogTask {
    var notificationBody: String {
        "\(self.content ?? "Unknown task") is due at \(self.due?.formatted() ?? "unclear, why do you ask?")"
    }

    @ViewBuilder var rowView: some View {
        if let job = self.owner {
            if let date = self.completedDate {
                LogRow(
                    entry: Entry(
                        timestamp: DateHelper.longDate(date),
                        job: job,
                        message: "Completed task: \(self.content ?? "Error: Invalid task content") at: \(date.formatted()) "
                    ),
                    index: 0,
                    colour: job.backgroundColor
                )
            } else if let date = self.cancelledDate {
                LogRow(
                    entry: Entry(
                        timestamp: DateHelper.longDate(date),
                        job: job,
                        message: "Cancelled task: \(self.content ?? "Error: Invalid task content") at: \(date.formatted()) "
                    ),
                    index: 0,
                    colour: job.backgroundColor
                )
            } else {
                if self.lastUpdate != self.created {
                    if let date = self.lastUpdate {
                        LogRow(
                            entry: Entry(
                                timestamp: DateHelper.longDate(date),
                                job: job,
                                message: "Updated task: \(self.content ?? "Error: Invalid task content") at: \(date.formatted()) "
                            ),
                            index: 0,
                            colour: job.backgroundColor
                        )
                    }
                } else {
                    if let date = self.created {
                        LogRow(
                            entry: Entry(
                                timestamp: DateHelper.longDate(date),
                                job: job,
                                message: "Created task: \(self.content ?? "Error: Invalid task content") at: \(date.formatted()) "
                            ),
                            index: 0,
                            colour: job.backgroundColor
                        )
                    }
                }
            }
        }
    }
}
