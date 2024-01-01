//
//  TodaySidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TodaySidebar: View {
    @State public var date: Date = Date()
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    @EnvironmentObject public var nav: Navigation

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

extension TodaySidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Jobs",
                icon: "hammer",
                labelText: "Jobs",
                contents: AnyView(JobPickerWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Tasks",
                icon: "checklist",
                labelText: "Tasks",
                contents: AnyView(TasksWidget())
            ),
            ToolbarButton(
                id: 2,
                helpText: "Notes",
                icon: "note.text",
                labelText: "Notes",
                contents: AnyView(NotesWidget())
            )
        ]
    }
}
