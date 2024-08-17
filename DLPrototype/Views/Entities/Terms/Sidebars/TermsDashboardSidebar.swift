//
//  TermDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TermsDashboardSidebar: View {
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

extension TermsDashboardSidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Recent jobs",
                icon: "clock",
                labelText: "Recent jobs",
                contents: AnyView(JobPickerWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "All jobs",
                icon: "hammer",
                labelText: "All Jobs",
                contents: AnyView(JobsWidget())
            )
        ]
    }
}
