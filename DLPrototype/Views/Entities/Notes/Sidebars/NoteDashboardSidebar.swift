//
//  NoteDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

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
                helpText: "Notes",
                icon: "note.text",
                labelText: "Notes",
                contents: AnyView(NotesWidget())
            ),
            ToolbarButton(
                id: 2,
                helpText: "Favourites notes",
                icon: "star.fill",
                labelText: "Favourite Notes",
                contents: AnyView(NotesWidget(favouritesOnly: true))
            )
        ]
    }
}
