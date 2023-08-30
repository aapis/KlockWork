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

            WorkingOnToday
//            Spacer()
            // TODO: add this back when there are things to summarize
//            FancySubTitle(text: "Daily Summary")
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.jobs, perform: actionOnChangeJobs)
        .font(Theme.font)
        .padding()
        .background(Theme.toolbarColour)
    }

    private var WorkingOnToday: some View {
        VStack(alignment: .leading, spacing: 1) {
            Menu()
            ScrollView(.vertical, showsIndicators: false) {
                let jobs = Array(nav.planning.jobs).sorted(by: {$0.jid > $1.jid})
                if jobs.count > 0 {
                    ForEach(jobs) { job in
                        VStack(spacing: 1) {
                            JobPlanningGroup(job: job, jobs: jobs)
                        }
                    }
                } else {
                    HStack {
                        Text("Add jobs using the sidebar widget then select the tasks you'd like to focus on. This list saves automatically.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Theme.rowColour)
                }
            }
        }
    }
}

extension Planning {
    enum PlanningObjectType {
        case tasks, notes
    }

    private func actionOnAppear() -> Void {
        actionOnChangeJobs(nav.planning.jobs)
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

extension Planning.JobPlanningRow {
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

extension Planning {
    struct JobPlanningGroup: View {
        var job: Job
        var jobs: [Job]

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    FancyButtonv2(
                        text: "Job #\(job.jid.string)",
                        icon: "hammer",
                        fgColour: colour.isBright() ? .black : .white,
                        showIcon: false,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(JobDashboard(defaultSelectedJob: job)),
                        pageType: .notes,
                        sidebar: AnyView(JobDashboardSidebar())
                    )

                    Spacer()
                    Button {
                        nav.planning.jobs.remove(job)

                        if nav.planning.jobs.count == 0 {
                            nav.planning.reset()
                            nav.session.plan = nil
                            nav.session.gif = .normal
                        } else {
                            let plan = nav.planning.finalize()
                            nav.session.plan = plan
                        }
                    } label: {
                        Image(systemName: highlighted ? "clear.fill" : "clear")
                            .foregroundColor(colour.isBright() ? .black : .white)
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({inside in highlighted = inside})
                }
                .padding()
                .background(colour)

                JobPlanningRow(job: job, index: jobs.firstIndex(of: job), type: .tasks)
                JobPlanningRow(job: job, index: jobs.firstIndex(of: job), type: .notes)
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.JobPlanningGroup {
    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)
    }
}

extension Planning {
    struct Header: View {
        var job: Job
        var index: Int?
        var type: PlanningObjectType

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false
        @State private var numChildren: Int = 0

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    if type == .tasks {
                        Image(systemName: "\(numChildren).circle")
                            .font(.title)
                            .foregroundColor(colour.isBright() ? .black : .white)
                        Text("Incomplete tasks associated with job \(job.jid.string)")
                            .foregroundColor(colour.isBright() ? .black : .white)
                    } else if type == .notes {
                        Image(systemName: "\(numChildren).circle")
                            .font(.title)
                            .foregroundColor(colour.isBright() ? .black : .white)
                        Text("Notes associated with job \(job.jid.string)")
                            .foregroundColor(colour.isBright() ? .black : .white)
                    }

                    Spacer()
                }
                .padding(10)
            }
            .onAppear(perform: actionOnAppear)
            .background(colour)
        }
    }
}

extension Planning.Header {
    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)

        if type == .tasks {
            if let tasks = job.tasks {
                numChildren = tasks.filtered(using: NSPredicate(format: "completedDate == nil && cancelledDate == nil")).count
            }
        } else if type == .notes {
            if let notes = job.mNotes {
                numChildren = notes.filtered(using: NSPredicate(format: "alive == true")).count
            }
        }
    }
}

extension Planning {
    struct Tasks: View {
        public var tasks: FetchedResults<LogTask>
        public var colour: Color

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(tasks) { task in
                    Row(task: task, colour: colour)
                }
                .onAppear(perform: actionOnAppear)
            }
        }
    }
}

extension Planning.Tasks {
    private func actionOnAppear() -> Void {
        nav.planning.tasks = nav.planning.tasks.filter {$0.completedDate == nil && $0.cancelledDate == nil}
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
                        nav.planning.tasks.remove(task)
                    } else {
                        nav.planning.tasks.insert(task)
                    }

                    selected.toggle()
                } label: {
                    Image(systemName: selected ? "checkmark.square" : "square")
                        .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                        .font(.title)

                    if let content = task.content {
                        Text("\(content)")
                            .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})

                Spacer()
            }
            .padding(10)
            .background(colour)
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Tasks.Row {
    private func actionOnAppear() -> Void {
        if let plan = nav.session.plan {
            if let tasks = plan.tasks {
                if tasks.contains(task) {
                    selected = true
                } else {
                    selected = false
                }
            }
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

extension Planning {
    struct Notes: View {
        public var notes: FetchedResults<Note>
        public var colour: Color

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            if notes.count > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(notes) { note in
                        Row(note: note, colour: colour)
                    }
                }
            }
        }
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
                        nav.planning.notes.remove(note)
                    } else {
                        nav.planning.notes.insert(note)
                    }

                    selected.toggle()
                } label: {
                    Image(systemName: selected ? "checkmark.square" : "square")
                        .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                        .font(.title)

                    if let content = note.title {
                        Text("\(content)")
                            .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})

                Spacer()
            }
            .padding(10)
            .background(colour)
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Notes.Row {
    private func actionOnAppear() -> Void {
        if let plan = nav.session.plan {
            if let notes = plan.notes {
                if notes.contains(note) {
                    selected = true
                } else {
                    selected = false
                }
            }
        }
    }
}
