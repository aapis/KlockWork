//
//  RecentTasksWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TasksWidget: View {
    @State private var minimized: Bool = false
    @State private var grouped: Dictionary<Job, [LogTask]> = [:]
    @State private var query: String = ""
    @State private var isSettingsPresented: Bool = false
    @State private var sorted: [EnumeratedSequence<Dictionary<Job, [LogTask]>.Keys>.Element] = []

    @FetchRequest public var resource: FetchedResults<LogTask>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    @AppStorage("widget.tasks.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.tasks.minimizeAll") private var minimizeAll: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
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
            }
            .padding(10)
            .background(Theme.base.opacity(0.2))

            VStack {
                if isSettingsPresented {
                    Settings(
                        minimizeAll: $minimizeAll
                    )
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        if sorted.count > 0 {
                            ForEach(sorted, id: \.element) { index, key in
                                TaskGroup(index: index, key: key, tasks: grouped)
                            }
                        } else {
                            if nav.session.gif == .focus {
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
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
        .font(Theme.font)
    }
}

extension TasksWidget {
    public init() {
        _resource = CoreDataTasks.recentTasksWidgetData()
    }

    private func resetGroupedTasks() -> Void {
        grouped = Dictionary(grouping: resource, by: {$0.owner!})
        sorted = Array(grouped.keys.enumerated())
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

        if nav.session.gif == .focus {
            if let plan = nav.session.plan {
                if let setJobs = plan.jobs {
                    let jobs = setJobs.allObjects as! [Job]
                    query = jobs.map({$0.jid.string}).joined(separator: ", ")
                }

                if let setTasks = plan.tasks {
                    let tasks = setTasks.allObjects as! [LogTask]
                    grouped = Dictionary(grouping: tasks.filter {$0.completedDate == nil && $0.cancelledDate == nil}, by: {$0.owner!})
                }
            }
        }

        sorted = Array(grouped.keys.enumerated())
            .sorted(by: ({$0.element.jid < $1.element.jid}))
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        resetGroupedTasks()
    }
}

extension TasksWidget {
    struct Settings: View {
        private let title: String = "Widget Settings"

        @Binding public var minimizeAll: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Theme.base.opacity(0.3)
                
                VStack(alignment: .leading) {
                    FancySubTitle(text: title)
                    Toggle("Minimize all groups", isOn: $minimizeAll)
                    Spacer()
                    FancyDivider()
                }
                .padding()
            }
        }
    }
}
