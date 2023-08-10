//
//  RecentNotesWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentNotesWidget: View {
    public let title: String = "Recent Notes"

    @State private var minimized: Bool = false

    @FetchRequest public var notes: FetchedResults<Note>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    FancyButtonv2(
                        text: "Minimize",
                        action: actionMinimize,
                        icon: minimized ? "plus" : "minus",
                        showLabel: false,
                        type: .clear
                    )
                    .frame(width: 30, height: 30)

                    Text(title)
                        .padding(.trailing, 10)
                    Spacer()
                }
                .padding(5)
            }
            .background(Theme.base.opacity(0.2))

            VStack {
                if !minimized {
                    VStack(alignment: .leading, spacing: 5) {
                        if notes.count > 0 {
                            ForEach(notes) { note in
                                NoteRowPlain(note: note, moc: moc)
                            }
                        } else {
                            SidebarItem(
                                data: "Create a note first",
                                help: "Create a note first",
                                role: .important
                            )
                        }
                    }
                } else {
                    HStack {
                        Text("\(notes.count) notes")
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}

extension RecentNotesWidget {
    public init() {
        _notes = CoreDataNotes.fetchRecentNotes(limit: 7)
    }
    
    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
//        isSettingsPresented.toggle()
    }
}
