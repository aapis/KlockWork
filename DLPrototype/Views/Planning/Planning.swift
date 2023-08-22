//
//  Planning.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    private let maxItems: Int = 6

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Title(text: "Planning")
                Spacer()
            }

            FancySubTitle(text: "What am I working on today?")

            WorkingOnToday

            FancySubTitle(text: "Daily Summary")
        }
        .onAppear(perform: actionOnAppear)
        .font(Theme.font)
        .padding()
        .background(Theme.toolbarColour)
    }

    private var WorkingOnToday: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 5) {
                ScrollView(.vertical, showsIndicators: false) {
                    AllJobsPickerWidget(location: .content)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Statistics()
                    ScrollView(.vertical, showsIndicators: false) {
                        let jobs = Array(nav.session.planning.jobs) //.sorted(by: {$0.jid > $1.jid})
                        ForEach(jobs) { job in
                            VStack(spacing: 1) {
                                Group(job: job, index: jobs.firstIndex(of: job))
                                Tasks(job: job)
                            }
                            .opacity(nav.session.planning.finalized == nil ? 1 : 0.1)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

extension Planning {
    private func actionOnAppear() -> Void {

    }
}

extension Planning {
    struct Group: View {
        public var job: Job
        public var index: Int?

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ZStack {
                colour

                VStack(alignment: .leading) {
                    HStack {
                        if let tasks = job.tasks {
                            Image(systemName: "\(tasks.count.string).circle")
                                .font(.title)
                                .foregroundColor(colour.isBright() ? .black : .white)
                            Text("Tasks associated with job \(job.jid.string)")
                                .foregroundColor(colour.isBright() ? .black : .white)
                        }

                        Spacer()
                        Button {
                            nav.session.planning.jobs.remove(job)
                        } label: {
                            Image(systemName: highlighted ? "clear.fill" : "clear")
                                .foregroundColor(colour.isBright() ? .black : .white)
                                .font(.title)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in highlighted = inside})
                    }
                    .padding(10)
                }
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Group {
    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)
    }
}

extension Planning {
    struct Tasks: View {
        public let job: Job

        @State private var colour: Color = .clear

        @EnvironmentObject public var nav: Navigation

        @FetchRequest public var tasks: FetchedResults<LogTask>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(tasks) { task in
                    ZStack {
                        colour
                        Row(task: task, colour: colour)
                    }
                }
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Tasks {
    init(job: Job) {
        self.job = job

        _tasks = FetchRequest(
            entity: LogTask.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \LogTask.completedDate, ascending: false)
            ],
            predicate: NSPredicate(format: "owner == %@ && completedDate == nil", self.job)
        )
    }

    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)
    }
}

extension Planning.Tasks {
    struct Row: View {
        var task: LogTask
        var colour: Color

        @State private var selected: Bool = true

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            HStack(alignment: .top) {
                Button {
                    if selected {
                        nav.session.planning.tasks.remove(task)
                    } else {
                        nav.session.planning.tasks.insert(task)
                    }

                    selected.toggle()
                } label: {
                    Image(systemName: selected ? "checkmark.square" : "square")
                        .foregroundColor(colour.isBright() ? .black : .white)
                        .font(.title2)

                    if let content = task.content {
                        Text("\(content)")
                            .foregroundColor(colour.isBright() ? .black : .white)
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})

                Spacer()
            }
            .padding(10)
        }
    }
}

extension Planning {
    struct Statistics: View {
        @State private var numTasks: Int = 0
        @State private var numJobs: Int = 0

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack {
                HStack {
                    Text("\(numTasks) Task(s)")
                        .padding()
                    Text("\(numJobs) Job(s)")
                    Spacer()
                    if nav.session.planning.jobs.count > 0 {
                        FancyButtonv2(
                            text: "Finalize Plan",
                            action: actionFinalizePlan,
                            icon: "checkmark.seal.fill",
                            showLabel: false,
                            type: .primary
                        )

                        FancyButtonv2(
                            text: "Reset Plan",
                            action: actionResetPlan,
                            icon: "arrow.clockwise.circle.fill",
                            showLabel: false,
                            type: .white
                        )
                        .padding(.trailing, 4)
                    }
                }
            }
            .background(Theme.headerColour)
            .onAppear(perform: actionOnAppear)
            .onChange(of: nav.session.planning.tasks, perform: actionOnChangeTasks)
            .onChange(of: nav.session.planning.jobs, perform: actionOnChangeJobs)
        }
    }
}

extension Planning.Statistics {
    private func actionFinalizePlan() -> Void {
        nav.session.planning.finalize()
    }

    private func actionResetPlan() -> Void {
        nav.session.planning.reset()
    }

    private func actionOnChangeJobs(jobs: Set<Job>) -> Void {
        nav.session.planning.jobs = jobs

        var taskSet: Set<LogTask> = []
        for job in jobs {
            if let tasks = job.tasks {
                for task in tasks {
                    taskSet.insert(task as! LogTask)
                }
            }
        }

        actionOnChangeTasks(tasks: taskSet)
    }

    private func actionOnChangeTasks(tasks: Set<LogTask>) -> Void {
        nav.session.planning.tasks = tasks
        actionOnAppear()
    }

    private func actionOnAppear() -> Void {
        numTasks = nav.session.planning.tasks.count
        numJobs = nav.session.planning.jobs.count
    }
}
