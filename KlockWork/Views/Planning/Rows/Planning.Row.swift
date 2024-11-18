//
//  JobPlanningRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning {
    struct Row: View {
        @EnvironmentObject public var state: Navigation
        var job: Job
        var index: Array<Job>.Index?
        var type: PlanningObjectType
        var colour: Color = Color.clear

        @FetchRequest public var tasks: FetchedResults<LogTask>
        @FetchRequest public var notes: FetchedResults<Note>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if let idx = index {
                    Header(job: job, index: idx, type: type)
                        .opacity((type == .tasks && tasks.count > 0) || (type == .notes && notes.count > 0) ? 1 : 0.7)

                    if type == .tasks {
                        if tasks.count > 0 {
                            Tasks(tasks: tasks, colour: Theme.rowColour)
                        }
                    } else if type == .notes {
                        if notes.count > 0 {
                            Notes(notes: notes, colour: Theme.rowColour)
                        }
                    }
                }
            }
            .background(self.state.theme.style == .opaque ? self.state.session.appPage.primaryColour : Theme.rowColour)
        }
    }
}

extension Planning.Row {
    init(job: Job, index: Array<Job>.Index?, type: Planning.PlanningObjectType) {
        self.job = job
        self.index = index
        self.type = type
        self.colour = self.job.backgroundColor

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
