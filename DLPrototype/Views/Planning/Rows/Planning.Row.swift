//
//  JobPlanningRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Row: View {
        var job: Job
        var index: Array<Job>.Index?
        var type: PlanningObjectType
        var colour: Color = Color.clear

        @FetchRequest public var tasks: FetchedResults<LogTask>
        @FetchRequest public var notes: FetchedResults<Note>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                if let idx = index {
                    Header(job: job, index: idx, type: type)
                        .opacity((type == .tasks && tasks.count > 0) || (type == .notes && notes.count > 0) ? 1 : 0.7)

                    if type == .tasks {
                        if tasks.count > 0 {
                            Tasks(tasks: tasks, colour: colour)
                        } else {
                            VStack(alignment: .leading) {
                                HStack {
                                    FancyButtonv2(
                                        text: "Add a task to this job",
                                        icon: "plus",
                                        fgColour: colour.isBright() ? .black : .white,
                                        size: .link,
                                        type: .clear,
                                        redirect: AnyView(TaskDashboard(defaultSelectedJob: job)),
                                        pageType: .tasks,
                                        sidebar: AnyView(TaskDashboardSidebar())
                                    )
                                    Spacer()
                                }
                                .padding()
                                .background(colour)
                                .opacity(0.7)
                            }
                        }
                    } else if type == .notes {
                        if notes.count > 0 {
                            Notes(notes: notes, colour: colour)
                        } else {
                            VStack(alignment: .leading) {
                                HStack {
                                    FancyButtonv2(
                                        text: "Add a note to this job",
                                        icon: "plus",
                                        fgColour: colour.isBright() ? .black : .white,
                                        size: .link,
                                        type: .clear,
                                        redirect: AnyView(NoteDashboard()),
                                        pageType: .notes,
                                        sidebar: AnyView(NoteDashboardSidebar())
                                    )
                                    Spacer()
                                }
                                .padding()
                                .background(colour)
                                .opacity(0.7)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Planning.Row {
    init(job: Job, index: Array<Job>.Index?, type: Planning.PlanningObjectType) {
        self.job = job
        self.index = index
        self.type = type
        self.colour = Color.fromStored(self.job.colour ?? Theme.rowColourAsDouble)

        _tasks = FetchRequest(
            entity: LogTask.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \LogTask.completedDate, ascending: false)
            ],
            predicate: NSPredicate(format: "owner == %@ && completedDate == nil && cancelledDate == nil", self.job)
        )

        _notes = FetchRequest(
            entity: Note.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)
            ],
            predicate: NSPredicate(format: "mJob == %@ && alive == true", self.job)
        )
    }
}
