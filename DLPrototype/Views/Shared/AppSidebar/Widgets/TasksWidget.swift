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
    @State private var groupedTasks: Dictionary<Job, [LogTask]> = [:]
    @State private var query: String = ""
    @State private var isSettingsPresented: Bool = false
    @State private var sortedJobs: [EnumeratedSequence<Dictionary<Job, [LogTask]>.Keys>.Element] = []

    @FetchRequest public var resource: FetchedResults<LogTask>

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
                        type: .clear
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
                        if showSearch {
                            VStack {
                                SearchBar(text: $query, disabled: minimized, placeholder: "Search tasks...")
                                    .onChange(of: query, perform: actionOnSearch)
                                    .onChange(of: nav.session.job, perform: actionOnChangeJob)
                            }
                        }

                        if groupedTasks.count > 0 {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(groupedTasks.keys.enumerated()), id: \.element) { index, key in
                                    TaskGroup(index: index, key: key, tasks: groupedTasks)
                                }
                            }
                        } else {
                            SidebarItem(
                                data: "No tasks or jobs matching query",
                                help: "No tasks or jobs matching query",
                                role: .important
                            )
                        }
                    }
                } else {
                    HStack {
                        Text("\(groupedTasks.count) jobs")
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
        .id(updater.ids["sidebar.today.incompleteTasksWidget"])
        .font(Theme.font)
    }
}

extension TasksWidget {
    public init() {
        _resource = CoreDataTasks.recentTasksWidgetData(limit: 100)
    }

    private func resetGroupedTasks() -> Void {
        // TODO: need to figure out how to sort this dictionary
        groupedTasks = Dictionary(grouping: resource, by: {$0.owner!})
        sortedJobs = Array(groupedTasks.keys.enumerated())
            .sorted(by: ({$0.element.jid < $1.element.jid}))
    }

    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
        isSettingsPresented.toggle()
    }

    private func actionOnAppear() -> Void {
        resetGroupedTasks()
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        if let jerb = job {
            query = jerb.jid.string
            resetGroupedTasks()
        }
    }

    private func actionOnSearch(term: String) -> Void {
        resetGroupedTasks()
        groupedTasks = groupedTasks.filter({searchCriteria(term: term, job: $0.key, tasks: $0.value)})
        // TODO: figure out how to apply sort (below doesn't work)
//            .sorted(by: {$0.key.created! > $1.key.created!})

        if query.isEmpty {
            resetGroupedTasks()
        }
    }

    internal func searchCriteria(term: String, job: Job, tasks: [LogTask]) -> Bool {
        if let projectName = job.project?.name {
            if projectName.contains(term) || projectName.caseInsensitiveCompare(term) == .orderedSame {
                return true
            }
        }

        if job.jid.string == term {
            return true
        }

        if tasks.contains(where: {$0.content?.contains(term) ?? false}) {
            return true
        }

        if tasks.contains(where: {$0.content?.caseInsensitiveCompare(term) == .orderedSame}) {
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
