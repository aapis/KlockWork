//
//  RecentTasksWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TasksWidget: View {
    public let title: String = "Incomplete Tasks"

    @State private var minimized: Bool = false
    @State private var groupedTasks: Dictionary<Job, [LogTask]> = [:]
    @State private var query: String = ""
    @State private var isSettingsPresented: Bool = false

    @FetchRequest public var resource: FetchedResults<LogTask>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    @AppStorage("widget.tasks.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.tasks.minimizeAll") private var minimizeAll: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let parent = nav.parent {
                    if parent != .tasks {
                        FancySubTitle(text: "Tasks")
                    }
                }

                Spacer()
                FancyButtonv2(
                    text: "Settings",
                    action: actionSettings,
                    icon: "gear",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
                
                FancyButtonv2(
                    text: "Minimize",
                    action: actionMinimize,
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

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
                                .onChange(of: query, perform: search)
                        }
                    }

                    if groupedTasks.count > 0 {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(groupedTasks.keys.enumerated()), id: \.element) { index, key in
                                TaskGroup(index: index, key: key, tasks: groupedTasks)
                            }
                            FancyDivider()
                        }
                    } else {
                        SidebarItem(
                            data: "No tasks or jobs matching query",
                            help: "No tasks or jobs matching query",
                            role: .important
                        )
                    }
                }
            }
        }
        .onAppear(perform: onAppear)
        .id(updater.ids["sidebar.today.incompleteTasksWidget"])
        .font(Theme.font)
    }
}

extension TasksWidget {
    public init() {
        _resource = CoreDataTasks.recentTasksWidgetData(limit: 100)
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionSettings() -> Void {
        withAnimation {
            isSettingsPresented.toggle()
        }
    }

    private func onAppear() -> Void {
        resetGroupedTasks()
    }

    private func search(term: String) -> Void {
        if term.count > 3 {
            let filtered = groupedTasks.filter({
                (
                    (
                        $0.key.project?.name?.contains(term) ?? false
                    )
                    ||
                    (
                        $0.key.project?.name?.caseInsensitiveCompare(term) == .orderedSame
                    )
                    ||
                    (
                        $0.value.contains(where: {$0.content?.contains(term) ?? false})
                    )
                    ||
                    (
                        $0.value.contains(where: {$0.content?.caseInsensitiveCompare(term) == .orderedSame})
                    )
                )
            })
            // TODO: figure out how to apply sort (below doesn't work)
//            .sorted(by: {$0.key.created! > $1.key.created!})

            groupedTasks = filtered
        }
        else {
            resetGroupedTasks()
        }
    }

    private func resetGroupedTasks() -> Void {
        // TODO: need to figure out how to sort this dictionary
        groupedTasks = Dictionary(grouping: resource, by: {$0.owner!})
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
