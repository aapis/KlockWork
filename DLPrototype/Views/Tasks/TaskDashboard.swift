//
//  TaskDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskDashboard: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    @FetchRequest(sortDescriptors: [SortDescriptor(\LogTask.id)]) public var tasks: FetchedResults<LogTask>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                HStack {
                    Title(text: "Tasks", image: "list.number")
                    Spacer()
                }
                
                Text("You have \(tasks.count) tasks across \(jobs.count) projects")
                    .font(.title3)
                
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}
