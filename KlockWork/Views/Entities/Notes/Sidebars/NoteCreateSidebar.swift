//
//  NoteCreateSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteCreateSidebar: View {
    @EnvironmentObject public var state: Navigation
    @State public var note: Note?
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

extension NoteCreateSidebar {
    private func createToolbar() -> Void {
        if let stored = self.state.session.note {
            self.note = stored
        }

        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Canvas: Note",
                icon: "doc.text",
                labelText: "Notes",
                contents: AnyView(NoteFormWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Resources",
                icon: "globe",
                labelText: "Resources",
                contents: AnyView(UnifiedSidebar.Widget())
            ),
        ]
    }
}
