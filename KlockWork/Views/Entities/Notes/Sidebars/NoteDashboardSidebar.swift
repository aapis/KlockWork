//
//  NoteDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteDashboardSidebar: View {
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FancyGenericToolbar(
                buttons: tabs,
                standalone: true,
                location: .sidebar,
                mode: .compact
            )
        }
        .onAppear(perform: createToolbar)
    }
}

extension NoteDashboardSidebar {
    private func createToolbar() -> Void {
        self.tabs.append(contentsOf: Home.standardSidebarWidgets)
        self.tabs.append(
            ToolbarButton(
                id: 3,
                helpText: "Favourites notes",
                icon: "star.fill",
                labelText: "Favourite Notes",
                contents: AnyView(NotesWidget(favouritesOnly: true))
            )
        )
    }
}
