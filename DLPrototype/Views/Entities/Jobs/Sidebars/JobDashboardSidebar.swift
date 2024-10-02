//
//  JobDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDashboardSidebar: View {
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
        .onAppear(perform: createToolbar)
    }
}

extension JobDashboardSidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Find resources",
                icon: "globe.americas",
                labelText: "Resources",
                contents: AnyView(JobsWidgetRedux())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Recent jobs",
                icon: "clock",
                labelText: "Recent jobs",
                contents: AnyView(JobPickerWidget())
            ),
            ToolbarButton(
                id: 2,
                helpText: "All jobs",
                icon: "hammer",
                labelText: "All Jobs",
                contents: AnyView(JobsWidget())
            )
        ]
    }
}
