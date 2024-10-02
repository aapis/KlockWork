//
//  NoteCreateSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteCreateSidebar: View {
    public var note: Note? = nil

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
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Canvas: Note",
                icon: "doc.text",
                labelText: "Notes",
                contents: AnyView(NoteFormWidget(note: note))
            )
        ]
    }
}
