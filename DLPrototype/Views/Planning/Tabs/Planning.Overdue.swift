//
//  Planning.Overdue.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Overdue: View {
        @EnvironmentObject public var nav: Navigation
        @FetchRequest private var tasks: FetchedResults<LogTask>
        @State private var overdue: [UpcomingRow] = []
        private let page: PageConfiguration.AppPage = .planning

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                if !self.tasks.isEmpty {
                    ForEach(self.overdue, id: \.id) { row in
                        Section {
                            ForEach(row.tasks) { task in
                                TaskItem(task: task)
                            }
                        } header: {
                            Timestamp(text: "\(row.tasks.count) on \(row.date)", fullWidth: true, alignment: .leading, clear: true)
                                .background(Theme.base.opacity(0.6))
                        }
                    }
                } else {
                    HStack {
                        Text("No overdue tasks!")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Theme.rowColour)
                }

                Spacer()
            }
            .onAppear(perform: self.actionOnAppear)
        }

        init() {
            _tasks = CoreDataTasks.fetchOverdue()
        }
    }
}

extension Planning.Overdue {
    /// Fires when the Forecast callback is fired
    /// - Returns: Void
    private func actionForecastCallback() -> Void {

    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.overdue = []
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
            self.overdue.append(
                UpcomingRow(
                    date: group.key,
                    tasks: group.value.sorted(by: {$0.due! < $1.due!})
                )
            )
        }
    }
}
