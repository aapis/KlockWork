//
//  Tasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Tasks: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    
    var body: some View {
        NavigationSplitView {
            List(jobs) { job in
                NavigationLink(String(format: "%1.f", job.jid), value: job)
            }
            .navigationDestination(for: Job.self) {
                TaskListView(job: $0)
                    .navigationTitle("Tasks for job \(String(format: "%1.f", $0.jid))")
            }
        } detail: {
            TaskDashboard()
                .navigationTitle("Tasks")
            
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}
