//
//  Planning.Upcoming.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct UpcomingRow: Identifiable, Hashable {
    var id: UUID = UUID()
    var date: String
    var tasks: [LogTask]
}

extension Planning {
    struct Upcoming: View {
        @EnvironmentObject public var nav: Navigation
        @State private var tasks: [LogTask] = []
        @State private var upcoming: [UpcomingRow] = []
        @State private var id: UUID = UUID()
        private let page: PageConfiguration.AppPage = .planning

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TaskForecast(callback: self.actionForecastCallback, page: self.page)
                if !self.upcoming.isEmpty {
                    ForEach(self.upcoming, id: \.id) { row in
                        Section {
                            ForEach(row.tasks) { task in
                                TaskItem(task: task, callback: self.actionTaskActionTap)
                            }
                        } header: {
                            Timestamp(text: "\(row.tasks.count) on \(row.date)", fullWidth: true, alignment: .leading, clear: true)
                                .background(Theme.base.opacity(0.6))
                        }
                    }
                } else {
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Text("No upcoming due dates")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Theme.rowColour)
                }
            }
            .id(self.id)
            .onAppear(perform: self.actionOnAppear)
        }
    }
}

extension Planning.Upcoming {
    /// Fires when the Forecast callback is fired
    /// - Returns: Void
    private func actionForecastCallback() -> Void {
        self.actionTaskActionTap()
    }

    /// Fires when a task is interacted with
    /// - Returns: Void
    private func actionTaskActionTap() -> Void {
        self.tasks = []
        self.actionOnAppear()
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.id = UUID()
        self.tasks = CoreDataTasks(moc: self.nav.moc).upcoming()
        self.upcoming = []
        let grouped = Dictionary(grouping: self.tasks, by: {$0.due!.formatted(date: .abbreviated, time: .omitted)})
        let sorted = Array(grouped)
            .sorted(by: {
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                if let d1 = df.date(from: $0.key) {
                    if let d2 = df.date(from: $1.key) {
                        return d1 < d2
                    }
                }
                return false
            })

        for group in sorted {
            self.upcoming.append(
                UpcomingRow(
                    date: group.key,
                    tasks: group.value.sorted(by: {$0.due! < $1.due!})
                )
            )
        }
    }
}
