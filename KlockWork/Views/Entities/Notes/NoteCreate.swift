//
//  NoteCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteCreate: View {
    @EnvironmentObject public var state: Navigation
    @State public var note: Note?
    @State private var mode: EntityViewMode = .ready
    @State private var title: String = ""
    @State private var content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n"
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .notes

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                FancyTextField(placeholder: "Placeholder content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
            }
            Spacer()
        }
        .background(self.page.primaryColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: self.state.forms.note.template) {
            if mode == .create {
                if let def = self.state.forms.note.template {
                    if let tmpl = def.template {
                        content = tmpl
                    }
                }
            }
        }
        .onChange(of: self.state.forms.note.version) {
            if mode == .update {
                if let version = self.state.forms.note.version {
                    if let vContent = version.content {
                        content = vContent
                    }
                }
            }
        }
        .onChange(of: self.state.saved) {
            if self.state.saved {
                self.save()
                self.state.to(.notes)
            }
        }
    }
}

extension NoteCreate {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.note {
            self.note = stored
        }

        if let job = self.state.session.job {
            self.state.forms.note.job = job
        }

        if note != nil {
            self.mode = .update
            if let body = note!.body {
                let versions = note!.versions!.allObjects as! [NoteVersion]
                if let mostRecentVersion = versions.last {
                    if mostRecentVersion.content != nil {
                        content = mostRecentVersion.content!
                    }
                } else {
                    content = body
                }

                title = StringHelper.titleFromContent(from: content)
            }
        } else {
            self.mode = .create
        }
    }
    
    /// Fires when save button/action is triggered
    /// - Parameter source: SaveSource
    /// - Returns: Void
    private func save(source: SaveSource = .manual) -> Void {
        if let title = content.lines.first {
            if mode == .create {
                self.note = CoreDataNotes(moc: self.state.moc).createAndReturn(
                    alive: true,
                    body: self.content,
                    lastUpdate: Date(),
                    postedDate: self.note?.postedDate ?? Date(),
                    starred: false,
                    title: StringHelper.titleFromContent(from: title),
                    job: self.state.forms.note.job ?? self.state.session.job
                )

                self.note?.addToVersions(
                    CoreDataNoteVersions(moc: self.state.moc).from(self.note!, source: source)
                )
            } else if mode == .update {
                let noteVersion = CoreDataNoteVersions(moc: self.state.moc).from(note!, source: source)
                noteVersion.content = self.content

                note!.lastUpdate = Date()
                note!.title = StringHelper.titleFromContent(from: title)
                note!.body = noteVersion.content!

                if let job = self.state.forms.note.job {
                    job.addToMNotes(self.note!)
                } else if let job = self.state.session.job {
                    job.addToMNotes(self.note!)
                }
                note!.addToVersions(noteVersion)
            }

            PersistenceController.shared.save()
            
            // the last note you interacted with
            self.state.session.note = note
            self.state.save()
        } else {
            print("[error][note.create] A title is required to save")
        }
    }
}
