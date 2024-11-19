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
    @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @State private var tabs: [ToolbarButton] = []

    var body: some View {
        if !self.isSearchStackShowing && !self.isUpcomingTaskStackShowing {
            FancyGenericToolbar(buttons: tabs, standalone: true, location: .sidebar, mode: .compact)
                .onAppear(perform: self.actionOnAppear)
        }
    }
}

extension DashboardSidebar {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Today in history",
                icon: "clock.badge.questionmark",
                selectedIcon: "clock.badge.questionmark.fill",
                labelText: "History",
                contents: AnyView(TodayInHistoryWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Resources",
                icon: "globe",
                selectedIcon: "globe",
                labelText: "Resources",
                contents: AnyView(UI.UnifiedSidebar.Widget())
            ),
            ToolbarButton(
                id: 2,
                helpText: "Companies & Projects",
                icon: "menucard",
                selectedIcon: "menucard.fill",
                labelText: "Outline",
                contents: AnyView(OutlineWidget())
            ),
            ToolbarButton(
                id: 3,
                helpText: "Calendar events",
                icon: "calendar",
                selectedIcon: "calendar",
                labelText: "Calendar events",
                contents: AnyView(UI.Sidebar.EventsWidget())
            )
        ]
    }
}
