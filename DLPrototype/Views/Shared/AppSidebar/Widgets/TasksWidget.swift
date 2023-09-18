//
//  RecentTasksWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TasksWidget: View {
    public let title: String = "Tasks"

    @State private var minimized: Bool = false
    @State private var grouped: Dictionary<Project, [Job]> = [:]
    @State private var query: String = ""
    @State private var isSettingsPresented: Bool = false
    @State private var sorted: [EnumeratedSequence<Dictionary<Project, [Job]>.Keys>.Element] = []

    @FetchRequest public var resource: FetchedResults<Job>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    @AppStorage("widget.tasks.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.tasks.minimizeAll") private var minimizeAll: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    if let parent = nav.parent {
                        FancyButtonv2(
                            text: "Minimize",
                            action: actionMinimize,
                            icon: minimized ? "plus" : "minus",
                            showLabel: false,
                            type: .clear
                        )
                        .frame(width: 30, height: 30)
                        
                        if parent != .tasks {
                            Text(title)
                                .padding(.trailing, 10)
                        } else {
                            Text("Search all tasks")
                        }
                    }
                }
                .padding(5)

                Spacer()

                HStack {
                    FancyButtonv2(
                        text: "Settings",
                        action: actionSettings,
                        icon: "gear",
                        showLabel: false,
                        type: .clear,
                        twoStage: true
                    )
                    .frame(width: 30, height: 30)
                }
                .padding(5)
            }
            .background(Theme.base.opacity(0.2))

            VStack {
                if !minimized {
                    if isSettingsPresented {
                        Settings(
                            showSearch: $showSearch,
                            minimizeAll: $minimizeAll
                        )
                    } else {
                        if showSearch && nav.session.gif != .focus {
                            VStack {
                                SearchBar(text: $query, disabled: minimized, placeholder: "Search tasks...")
                                    .onChange(of: query, perform: actionOnSearch)
                                    .onChange(of: nav.session.job, perform: actionOnChangeJob)
                            }
                        }

                        VStack {
                            if sorted.count > 0 {
                                ForEach(sorted, id: \.element) { _, key in
                                    if key.hasTasks(focus: nav.session.gif, using: nav.session.plan) {
                                        TaskGroup(key: key, tasks: grouped)
                                    }
                                }
                            } else {
                                if nav.session.gif == .normal {
                                    SidebarItem(
                                        data: "No results for query \(query)",
                                        help: "No results for query \(query)",
                                        role: .important
                                    )
                                } else if nav.session.gif == .focus {
                                    Button {
                                        nav.setView(AnyView(Planning()))
                                        nav.setId()
                                        nav.setTitle("Update your plan")
                                        nav.setParent(.planning)
                                        nav.setSidebar(AnyView(DefaultPlanningSidebar()))
                                    } label: {
                                        SidebarItem(
                                            data: "Add tasks to your plan...",
                                            help: "Add tasks to your plan",
                                            role: .action
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("\(sorted.count) jobs")
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
        .id(updater.get("sidebar.today.incompleteTasksWidget"))
        .font(Theme.font)
    }
}

extension TasksWidget {
    public init() {
        _resource = CoreDataJob.fetchAll()
    }

    private func resetGroupedTasks() -> Void {
        grouped = Dictionary(grouping: resource, by: {$0.project!})

        let withTasks = grouped.filter {$0.value.allSatisfy({$0.tasks!.count > 0})}
        sorted = Array(withTasks.keys.enumerated())
            .sorted(by: ({$0.element.pid < $1.element.pid}))
    }

    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
        isSettingsPresented.toggle()
    }

    private func actionOnAppear() -> Void {
        resetGroupedTasks()

        if nav.session.gif == .focus {
            if let plan = nav.session.plan {
                if let setJobs = plan.jobs {
                    let jobs = setJobs.allObjects as! [Job]
                    query = jobs.map({$0.jid.string}).joined(separator: ", ")
                }

                if let setTasks = plan.tasks {
                    var planJobs: Set<Job> = []

                    for task in setTasks.allObjects as! [LogTask] {
                        if let job = task.owner {
                            if let jobSet = job.tasks {
                                let jobTasks = jobSet.allObjects as! [LogTask]

                                if jobTasks.filter({$0.completedDate == nil && $0.cancelledDate == nil}).contains(task) {
                                    planJobs.insert(job)
                                }
                            }
                        }
                    }

                    grouped = Dictionary(grouping: planJobs, by: {$0.project!})
                }
            }
        }

        sorted = Array(grouped.keys.enumerated())
            .sorted(by: ({$0.element.pid < $1.element.pid}))
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        resetGroupedTasks()
    }

    private func actionOnSearch(term: String) -> Void {
        if nav.session.gif != .focus {
            resetGroupedTasks()

            let filtered = grouped.filter({searchCriteria(term: term, project: $0.key, jobs: $0.value)})

            if filtered.count > 0 {
                grouped = filtered
            }
        }

        if query.isEmpty {
            resetGroupedTasks()
        }
    }

    internal func searchCriteria(term: String, project: Project, jobs: [Job]) -> Bool {
        if let projectName = project.name {
            if projectName.contains(term) || projectName.caseInsensitiveCompare(term) == .orderedSame {
                return true
            }
        }

//        if project.jid.string == term {
//            return true
//        }

        if jobs.contains(where: {$0.jid.string.contains(term)}) {
            return true
        }

        if jobs.contains(where: {$0.jid.string.caseInsensitiveCompare(term) == .orderedSame}) {
            return true
        }

        return false
    }
}

extension TasksWidget {
    struct Settings: View {
        private let title: String = "Widget Settings"
        
        @Binding public var showSearch: Bool
        @Binding public var minimizeAll: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Theme.base.opacity(0.3)
                
                VStack(alignment: .leading) {
                    FancySubTitle(text: title)
                    Toggle("Show search bar", isOn: $showSearch)
                    Toggle("Minimize all groups", isOn: $minimizeAll)
                    Spacer()
                    FancyDivider()
                }
                .padding()
            }
        }
    }
}
