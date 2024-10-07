//
//  NoteRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning.Notes {
    struct Row: View {
        var note: Note
        var colour: Color

        @State private var selected: Bool = true

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            HStack(alignment: .top) {
                Button {
                    if selected {
                        nav.planning.notes.remove(note)
                    } else {
                        nav.planning.notes.insert(note)
                    }

                    selected.toggle()
                } label: {
                    Image(systemName: selected ? "checkmark.square" : "square")
                        .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                        .font(.title)

                    if let content = note.title {
                        Text("\(content)")
                            .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})

                Spacer()
            }
            .padding(10)
            .background(colour)
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Notes.Row {
    private func actionOnAppear() -> Void {
        if let plan = nav.session.plan {
            if let notes = plan.notes {
                if notes.contains(note) {
                    selected = true
                } else {
                    selected = false
                }
            }
        }
    }
}

