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
    private let page: PageConfiguration.AppPage = .explore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        FancyTextField(
                            placeholder: "What needs to be done?",
                            lineLimit: 1,
                            onSubmit: self.actionOnCreate,
                            disabled: self.state.session.job == nil,
                            bgColour: self.state.session.job?.backgroundColor.opacity(0.6) ?? .clear,
                            text: $content
                        )

                        RowAddButton(isPresented: $isPresented, callback: self.actionOnCreate)
                            .frame(height: 42)
                            .disabled(self.content.isEmpty || self.state.session.job == nil)
                            .opacity(self.content.isEmpty || self.state.session.job == nil ? 0.5 : 1)
                    }

                    if job.tasks!.count == 0 {
                        FancyHelpText(
                            text: "No tasks associated with this list yet",
                            page: self.page
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 1) {
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

