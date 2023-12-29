//
//  TaskDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskDashboardSidebar: View {
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                FancyGenericToolbar(
                    buttons: tabs,
                    standalone: true,
                    location: .sidebar,
                    mode: .compact
                )
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: createToolbar)
    }
}

extension TaskDashboardSidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Tasks",
                icon: "checklist",
                labelText: "Tasks",
                contents: AnyView(TasksWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Search",
                icon: "magnifyingglass",
                labelText: "Search",
                contents: AnyView(
                    VStack(alignment: .leading) {
                        FindDashboard(searching: $searching, location: .sidebar)
                    }
                    .padding(8)
                    .background(Theme.base.opacity(0.2))
                )
            )
        ]
    }
}
