//
//  Menu.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Menu: View {
        @State private var numTasks: Int = 0
        @State private var numJobs: Int = 0
        @State private var numNotes: Int = 0

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack {
                HStack(spacing: 8) {
                    CountPills
                    Spacer()
                    if numJobs > 0 {
                        HStack {
                            FancyButtonv2(
                                text: "Start over",
                                action: actionResetPlan,
                                icon: "arrow.clockwise.circle.fill",
                                showLabel: false,
                                size: .small,
                                type: .clear
                            )
                        }
                        .frame(height: 30)
                    }
                }
                .padding(5)
            }
            .background(Theme.headerColour)
            .onAppear(perform: actionOnAppear)
            .onChange(of: nav.planning.tasks, perform: actionOnChangeTasks)
            .onChange(of: nav.planning.jobs, perform: actionOnChangeJobs)
            .onChange(of: nav.planning.notes, perform: actionOnChangeNotes)
        }

        var CountPills: some View {
            HStack(spacing: 0) {
                TaskPill
                JobPill
                NotePill
            }
            .frame(height: 30)
            .mask {
                Capsule()
            }
        }

        var TaskPill: some View {
            HStack {
                Text("\(numTasks)")
                    .foregroundColor(numTasks > Planning.tooManyTasks ? .black : .white)
                Image(systemName: "checklist")
                    .help(numTasks > Planning.tooManyTasks ? "This is probably too much work, consider removing some" : "\(numTasks) tasks selected")
                    .foregroundColor(numTasks > Planning.tooManyTasks ? .black : .white)
            }
            .padding(8)
            .background(numTasks > Planning.tooManyTasks ? .yellow : Theme.base.opacity(0.2))
        }

        var JobPill: some View {
            HStack {
                Text("\(numJobs)")
                    .foregroundColor(numJobs > Planning.tooManyJobs ? .black : .white)
                Image(systemName: "hammer")
                    .help(numJobs > Planning.tooManyJobs ? "This is probably too much work, consider removing some" : "\(numJobs) jobs selected")
                    .foregroundColor(numJobs > Planning.tooManyJobs ? .black : .white)
            }
            .padding(8)
            .background(numJobs > Planning.tooManyJobs ? .yellow : Theme.base.opacity(0.2))
        }

        var NotePill: some View {
            HStack {
                Text("\(numNotes)")
                Image(systemName: "note.text")
                    .help("\(numNotes) notes selected")
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}

extension Planning.Menu {
    private func actionFinalizePlan() -> Void {
        nav.planning.reset()
        let plan = nav.planning.finalize()
        nav.session.plan = plan
    }

    private func actionResetPlan() -> Void {
        nav.planning.reset()
        nav.planning = Navigation.Planning(moc: nav.planning.moc)
        nav.session.plan = nil
        nav.session.gif = .normal
    }

    private func actionOnChangeJobs(jobs: Set<Job>) -> Void {
        nav.planning.jobs = jobs
        actionOnAppear()
        actionFinalizePlan()
    }

    private func actionOnChangeTasks(tasks: Set<LogTask>) -> Void {
        nav.planning.tasks = tasks
        actionFinalizePlan()
        actionOnAppear()
    }

    private func actionOnChangeNotes(notes: Set<Note>) -> Void {
        nav.planning.notes = notes
        actionFinalizePlan()
        actionOnAppear()
    }

    private func actionOnAppear() -> Void {
        numTasks = nav.planning.tasks.count
        numJobs = nav.planning.jobs.count
        numNotes = nav.planning.notes.count

        if numJobs == 0 {
            actionResetPlan()
        }
    }
}
