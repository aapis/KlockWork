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
    static private let tooManyJobs: Int = 5
    static private let tooManyTasks: Int = 8

    @EnvironmentObject public var nav: Navigation

    @State private var jobs: [Job] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Title(text: "Planning")
                Spacer()
            }

            FancySubTitle(text: "What am I working on today?")
                .padding(.bottom, 10)
            Text("Add jobs using the sidebar widget then select the tasks you'd like to focus on. Finalize to save the plan!")

            WorkingOnToday
//            Spacer()
            // TODO: add this back when there are things to summarize
//            FancySubTitle(text: "Daily Summary")
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.session.planning.jobs, perform: actionOnChangeJobs)
        .font(Theme.font)
        .padding()
        .background(Theme.toolbarColour)
    }

    private var WorkingOnToday: some View {
        VStack(alignment: .leading, spacing: 1) {
            Menu()
            ScrollView(.vertical, showsIndicators: false) {
                let jobs = Array(nav.session.planning.jobs).sorted(by: {$0.jid > $1.jid})
                ForEach(jobs) { job in
                    VStack(spacing: 1) {
                        JobPlanningRow(job: job, index: jobs.firstIndex(of: job), type: .tasks)
                        JobPlanningRow(job: job, index: jobs.firstIndex(of: job), type: .notes)
                    }

                }
                .opacity(nav.session.planning.finalized == nil ? 1 : 0.1)
            }
        }
    }
}

extension Planning {
    enum PlanningObjectType {
        case tasks, notes
    }

    private func actionOnAppear() -> Void {
        actionOnChangeJobs(nav.session.planning.jobs)
    }

    private func actionOnChangeJobs(_ newJobs: Set<Job>) -> Void {
        jobs = Array(newJobs).sorted(by: {$0.jid > $1.jid})
    }
}

extension Planning {
    struct JobPlanningRow: View {
        var job: Job
        var index: Array<Job>.Index?
        var type: PlanningObjectType

        @FetchRequest public var tasks: FetchedResults<LogTask>
        @FetchRequest public var notes: FetchedResults<Note>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                if let idx = index {
                    Header(job: job, index: idx, type: type)

                    if type == .tasks && tasks.count > 0 {
                        Tasks(job: job)
                    } else if type == .notes && notes.count > 0 {
                        Notes(job: job)
                    }
                }
            }
        }
    }
}

extension Planning.JobPlanningRow {
    init(job: Job, index: Array<Job>.Index?, type: Planning.PlanningObjectType) {
        self.job = job
        self.index = index
        self.type = type

        _tasks = FetchRequest(
            entity: LogTask.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \LogTask.completedDate, ascending: false)
            ],
            predicate: NSPredicate(format: "owner == %@ && completedDate == nil", self.job)
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

extension Planning {
    struct Header: View {
        var job: Job
        var index: Int?
        var type: PlanningObjectType

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ZStack {
                colour

                VStack(alignment: .leading) {
                    HStack {
                        if type == .tasks {
                            if let tasks = job.tasks {
                                Image(systemName: "\(tasks.filtered(using: NSPredicate(format: "completedDate == nil")).count.string).circle")
                                    .font(.title)
                                    .foregroundColor(colour.isBright() ? .black : .white)
                                Text("Tasks associated with job \(job.jid.string)")
                                    .foregroundColor(colour.isBright() ? .black : .white)
                            }
                        } else if type == .notes {
                            if let notes = job.mNotes {
                                Image(systemName: "\(notes.filtered(using: NSPredicate(format: "alive == true")).count.string).circle")
                                    .font(.title)
                                    .foregroundColor(colour.isBright() ? .black : .white)
                                Text("Recent notes for job \(job.jid.string)")
                                    .foregroundColor(colour.isBright() ? .black : .white)
                            }
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

extension Planning.Header {
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
            if tasks.count > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(tasks) { task in
                        Row(task: task, colour: colour)
                    }
                }
                .onAppear(perform: actionOnAppear)
            }
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
            .background(colour)
        }
    }
}

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
                    if nav.session.planning.jobs.count > 0 {
                        HStack {
                            FancyButtonv2(
                                text: "Start over",
                                action: actionResetPlan,
                                icon: "arrow.clockwise.circle.fill",
                                showLabel: false,
                                size: .small,
                                type: .clear
                            )

                            FancyButtonv2(
                                text: "Finalize",
                                action: actionFinalizePlan,
                                icon: "checkmark.seal",
                                size: .small,
                                type: .primary
                            )
                        }
                        .frame(height: 30)
                    }
                }
                .padding(5)
            }
            .background(Theme.headerColour)
            .onAppear(perform: actionOnAppear)
            .onChange(of: nav.session.planning.tasks, perform: actionOnChangeTasks)
            .onChange(of: nav.session.planning.jobs, perform: actionOnChangeJobs)
            .onChange(of: nav.session.planning.notes, perform: actionOnChangeNotes)
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
                    .help("\(numNotes) jobs selected")
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}

extension Planning.Menu {
    private func actionFinalizePlan() -> Void {
        nav.session.planning.finalize()
    }

    private func actionResetPlan() -> Void {
        nav.session.planning.reset()
    }

    private func actionOnChangeJobs(jobs: Set<Job>) -> Void {
        nav.session.planning.jobs = jobs

        var taskSet: Set<LogTask> = []
        var noteSet: Set<Note> = []

        for job in jobs {
            if let tasks = job.tasks {
                for task in tasks {
                    let t = task as! LogTask
                    if t.completedDate == nil {
                        taskSet.insert(t)
                    }
                }
            }

            if let notes = job.mNotes {
                for note in notes {
                    let n = note as! Note
                    if n.alive {
                        noteSet.insert(n)
                    }
                }
            }
        }

        actionOnChangeNotes(notes: noteSet)
        actionOnChangeTasks(tasks: taskSet)
    }

    private func actionOnChangeTasks(tasks: Set<LogTask>) -> Void {
        nav.session.planning.tasks = tasks
        actionOnAppear()
    }

    private func actionOnChangeNotes(notes: Set<Note>) -> Void {
        nav.session.planning.notes = notes
        actionOnAppear()
    }

    private func actionOnAppear() -> Void {
        numTasks = nav.session.planning.tasks.count
        numJobs = nav.session.planning.jobs.count
        numNotes = nav.session.planning.notes.count
    }
}

extension Planning {
    struct Notes: View {
        public let job: Job

        @State private var colour: Color = .clear

        @EnvironmentObject public var nav: Navigation

        @FetchRequest public var notes: FetchedResults<Note>

        var body: some View {
            if notes.count > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(notes) { note in
                        Row(note: note, colour: colour)
                    }
                }
                .onAppear(perform: actionOnAppear)
            }
        }
    }
}

extension Planning.Notes {
    init(job: Job) {
        self.job = job

        _notes = FetchRequest(
            entity: Note.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)
            ],
            predicate: NSPredicate(format: "mJob == %@ && alive == true", self.job)
        )
    }

    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)
    }
}

extension Planning.Notes {
    struct Row: View {
        var note: Note
        var colour: Color

        @State private var selected: Bool = true

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            HStack(alignment: .top) {
                Button {
                    if selected {
                        nav.session.planning.notes.remove(note)
                    } else {
                        nav.session.planning.notes.insert(note)
                    }

                    selected.toggle()
                } label: {
                    Image(systemName: selected ? "checkmark.square" : "square")
                        .foregroundColor(colour.isBright() ? .black : .white)
                        .font(.title2)

                    if let content = note.title {
                        Text("\(content)")
                            .foregroundColor(colour.isBright() ? .black : .white)
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})

                Spacer()
            }
            .padding(10)
            .background(colour)
        }
    }
}
