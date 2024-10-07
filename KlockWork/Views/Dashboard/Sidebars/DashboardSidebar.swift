//
//  DashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct DashboardSidebar: View {
    @State private var tabs: [ToolbarButton] = []

    var body: some View {
        FancyGenericToolbar(buttons: tabs, standalone: true, location: .sidebar, mode: .compact)
            .onAppear(perform: createToolbar)
    }
}

extension DashboardSidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Today in history",
                icon: "calendar",
                labelText: "History",
                contents: AnyView(TodayInHistoryWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Resources",
                icon: "globe",
                labelText: "Resources",
                contents: AnyView(UnifiedSidebar.Widget())
            ),
            ToolbarButton(
                id: 2,
                helpText: "Companies & Projects",
                icon: "menucard",
                labelText: "Outline",
                contents: AnyView(OutlineWidget())
            ),
        ]
    }
}
