//
//  RecentTasksWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct IncompleteTasksWidget: View {
    public let title: String = "Incomplete Tasks"

    @State private var minimized: Bool = false
    @State private var groupedTasks: Dictionary<Job, [LogTask]> = [:]
    @State private var query: String = ""

    @FetchRequest public var resource: FetchedResults<LogTask>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
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
                // TODO: move this to a new view
                VStack {
                    SearchBar(text: $query, disabled: minimized)
                        .onChange(of: query, perform: search)
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
        .onAppear(perform: onAppear)
        .id(updater.ids["sidebar.today.incompleteTasksWidget"])
    }
}

extension IncompleteTasksWidget {
    public init() {
        _resource = CoreDataTasks.recentTasksWidgetData(limit: 100)
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
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
