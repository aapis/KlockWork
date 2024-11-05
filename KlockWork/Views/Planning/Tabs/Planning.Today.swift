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
        @State private var jobsArray: [Job] = []

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Menu()
                if self.jobsArray.count > 0 {
                    ForEach(self.jobsArray, id: \.objectID) { job in
                        Planning.Group(job: job, jobs: self.jobsArray)
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
        if self.jobs != self.nav.planning.jobs {
            self.jobs = self.nav.planning.jobs
            self.jobsArray = Array(self.jobs).sorted(by: {$0.title ?? $0.jid.string > $1.title ?? $1.jid.string})
        }

        if self.nav.planning.jobs.isEmpty {
            self.jobs = CoreDataTasks(moc: self.nav.moc).jobsForTasksDueToday()
        }
    }
}
