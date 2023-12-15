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

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                FancyGenericToolbar(buttons: tabs, standalone: true, location: .sidebar)
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
                label: AnyView(
                    HStack {
                        Image(systemName: "hammer").padding(.leading)
                        Text("Jobs")
                    }
                ),
                contents: AnyView(JobPickerWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Tasks",
                label: AnyView(
                    HStack {
                        Image(systemName: "checklist").padding(.leading)
                        Text("Tasks")
                    }
                ),
                contents: AnyView(TasksWidget())
            ),
            ToolbarButton(
                id: 2,
                helpText: "Notes",
                label: AnyView(
                    HStack {
                        Image(systemName: "note.text").padding(.leading)
                        Text("Notes")
                    }
                ),
                contents: AnyView(NoteSearchWidget())
            )
        ]
    }
}
