//
//  NoteBlock.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-19.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteBlock: View {
    typealias UI = WidgetLibrary.UI
    public var note: Note

    @State private var highlighted: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        Button {
            self.nav.session.note = self.note
            self.nav.to(.noteDetail)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (note.starred ? Color.yellow : Color.white)
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.2 : 0.1)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(note.title!)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding([.leading, .trailing, .top])
                        Text(noteBody())
                            .foregroundStyle(.white.opacity(0.55))
                            .padding([.leading, .trailing, .bottom])

                        Spacer()
                        UI.ResourcePath(
                            company: self.note.mJob?.project?.company,
                            project: self.note.mJob?.project,
                            job: self.note.mJob
                        )
                        .help(self.projectDescription())
                    }
                }
            }
        }
        .clipShape(.rect(cornerRadius: 5))
        .useDefaultHover({ inside in highlighted = inside})
        .buttonStyle(.plain)
    }
}

extension NoteBlock {
    /// Determines note body content
    /// - Returns: String
    private func noteBody() -> String {
        if let body = note.body {
            if body.count > 100 {
                let i = body.index(body.startIndex, offsetBy: 100)
                let description = String(body[...i]).trimmingCharacters(in: .whitespacesAndNewlines)

                return description + "..."
            } else {
                return body
            }
        }

        return "No preview available"
    }
    
    /// Determines project description
    /// - Returns: String
    private func projectDescription() -> String {
        if let job = note.mJob {
            if let project = job.project {
                return "\(project.name!)#\(job.jid.string)"
            }
        }

        return ""
    }
}
