//
//  NoteBlock.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-19.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteBlock: View {
    public var note: Note

    @State private var highlighted: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        Button {
            nav.view = AnyView(NoteView(note: note, moc: moc))
            nav.parent = .notes
            nav.sidebar = AnyView(NoteViewSidebar(note: note, moc: moc))
            nav.pageId = UUID()
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (note.starred ? Color.yellow : Color.white)
                    // TODO: not sure I want this or not
//                    (note.starred ? LinearGradient(colors: [Color.yellow, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.2 : 0.1)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(note.title!)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding([.leading, .trailing, .top])
                        Text(noteBody())
                            .padding([.leading, .trailing, .bottom])

                        Spacer()
                        jobAndProject
                    }
                }
            }
        }
        .useDefaultHover({ inside in highlighted = inside})
        .buttonStyle(.plain)
    }

    @ViewBuilder private var jobAndProject: some View {
        HStack(spacing: 0) {
            ZStack {
                if let job = note.mJob {
                    if let project = job.project {
                        Color.fromStored(project.colour ?? Theme.rowColourAsDouble)
                    }
                }
            }
            .frame(width: 5)

            ZStack {
                if note.mJob != nil {
                    let colour = Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble)
                    colour
                    Text(note.mJob!.jid.string)
                        .foregroundColor(colour.isBright() ? Color.black : Color.white)
                } else {
                    Color.white.opacity(0.1)
                    Text("No job assigned")
                }
            }

            if note.starred {
                ZStack {
                    Color.yellow
                    Image(systemName: "star.fill")
                        .foregroundColor(.black)
                }
                .frame(width: 30)
            }
        }
        .frame(height: 30)
        .help(projectDescription())
    }

    private func noteBody() -> String {
        if let body = note.body {
            if body.count > 100 {
                let i = body.index(body.startIndex, offsetBy: 100)
                let description = String(body[...i]).trimmingCharacters(in: .whitespacesAndNewlines)

                return description + "..."
            }
        }

        return "No preview available"
    }

    private func projectDescription() -> String {
        if let job = note.mJob {
            if let project = job.project {
                return "\(project.name!)#\(job.jid.string)"
            }
        }

        return ""
    }
}
