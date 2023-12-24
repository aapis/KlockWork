//
//  NoteGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteGroup: View {
    public let index: Int
    public let key: Job
    public var notes: Dictionary<Job, [Note]>

    @State private var minimized: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    @AppStorage("widget.notesearch.minimizeAll") private var minimizeAll: Bool = false

    var body: some View {
        let colour = Color.fromStored(key.colour ?? Theme.rowColourAsDouble)

        if let project = key.project {
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    if let job = nav.session.job {
                        if job == key {
                            FancyStar(background: Color.fromStored(key.colour ?? Theme.rowColourAsDouble))
                                .help("Records you create will be associated with this job (#\(job.jid.string))")
                        }
                    }

                    FancyButtonv2(
                        text: project.name!,
                        action: minimize,
                        icon: minimized ? "plus" : "minus",
                        fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                        showIcon: false,
                        size: .link
                    )

                    Spacer()
                    FancyButtonv2(
                        text: project.name!,
                        action: minimize,
                        icon: minimized ? "plus" : "minus",
                        fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                        showLabel: false,
                        size: .tinyLink,
                        type: .clear
                    )
                }
                .padding(8)
            }
            .background(minimized ? colour : Theme.base.opacity(0.3))
            .onAppear(perform: actionOnAppear)

            if !minimized {
                VStack(alignment: .leading, spacing: 5) {
                    if let subtasks = self.notes[key] {
                        ForEach(subtasks) { note in
                            NoteRowPlain(note: note, moc: moc)
                        }
                    }
                }
                .foregroundColor(colour.isBright() ? .black : .white)
                .padding(8)
                .background(colour)
                .border(Theme.base.opacity(0.5), width: 1)
            }
        }
        
        FancyDivider(height: 8)
    }
}

extension NoteGroup {
    private func minimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
        minimized = minimizeAll
    }
}
