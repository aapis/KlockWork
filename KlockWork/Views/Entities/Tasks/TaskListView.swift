//
//  TaskListView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct TaskListView: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    @State private var content: String = ""
    @State var isPresented: Bool = false
    public var job: Job
    private var tasks: [LogTask] {
        let ordered = job.tasks!.sortedArray(using: [
                NSSortDescriptor(key: "completedDate", ascending: true),
                NSSortDescriptor(key: "cancelledDate", ascending: true),
                NSSortDescriptor(key: "created", ascending: false)
            ]
        )
        
        return ordered as! [LogTask]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        RowAddButton(isPresented: $isPresented, callback: self.actionOnCreate)
                            .frame(height: 40)
                            .disabled(self.content.isEmpty || self.state.session.job == nil)
                            .opacity(self.content.isEmpty || self.state.session.job == nil ? 0.5 : 1)

                        FancyTextField(
                            placeholder: "What needs to be done?",
                            lineLimit: 1,
                            onSubmit: self.actionOnCreate,
                            disabled: self.state.session.job == nil,
                            text: $content
                        )
                    }

                    Divider()
                        .foregroundColor(.clear)
                        .frame(height: 20)
                        .overlay(.clear)
                    
                    if job.tasks!.count == 0 {
                        Text("No tasks associated with this list yet")
                    } else {
                        VStack(alignment: .leading, spacing: 1) {
                            header.font(Theme.font)

                            // @TODO: group task statuses (complete, cancelled, etc) into tabbed interface
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 1) {
                                    ForEach(tasks, id: \.id) { task in
                                        TaskView(task: task, showCreated: true, showUpdated: true, showCancelled: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Tasks for \(self.job.title ?? self.job.jid.string) (#\(self.job.jid.string))")
                .foregroundColor(self.job.backgroundColor.isBright() ? Theme.base : .white)
            Spacer()
        }
        .padding()
        .background(self.job.backgroundColor)
    }
    
    private func actionOnCreate() -> Void {
        CoreDataTasks(moc: self.state.moc).create(
            content: self.content,
            created: Date(),
            due: DateHelper.endOfTomorrow(Date()) ?? Date(),
            job: self.job
        )

        self.content = ""
        self.dismiss()

        PersistenceController.shared.save()
    }
}

