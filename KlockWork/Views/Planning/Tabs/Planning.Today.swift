//
//  Planning.Today.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning {
    struct Today: View {
        @EnvironmentObject public var nav: Navigation
        @State private var jobs: Set<Job> = []

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Menu()
                if self.jobs.count > 0 {
                    let jobs = Array(self.jobs).sorted(by: {$0.title ?? $0.jid.string > $1.title ?? $1.jid.string})
                    ForEach(jobs, id: \.objectID) { job in
                        Planning.Group(job: job, jobs: Array(self.jobs))
                    }
                } else {
                    HStack {
                        Text("Add jobs using the sidebar widget then select the tasks you'd like to focus. This list saves automatically.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Theme.rowColour)
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.nav.planning.jobs) { self.actionOnAppear() }
        }
    }
}

extension Planning.Today {
    /// Onload handler. Sets view state (jobs)
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.jobs = self.nav.planning.jobs

        if self.nav.planning.jobs.isEmpty {
            self.jobs = CoreDataTasks(moc: self.nav.moc).jobsForTasksDueToday()
        }
    }
}
