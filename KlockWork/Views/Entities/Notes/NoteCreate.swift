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
    public var note: Note? = nil
    private var mode: EntityViewMode = .ready
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .notes
    @State private var title: String = ""
    @State private var content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n"

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
            }
        }
    }
    
    init(note: Note? = nil) {
        self.note = note

        if self.note != nil {
            self.mode = .update
        } else {
            self.mode = .create
        }
    }
}

extension NoteCreate {
    private func actionOnAppear() -> Void {
        if note != nil {
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
        }
    }

    private func save(source: SaveSource = .manual) -> Void {
        if let title = content.lines.first {
            var note = note
            if mode == .create {
                note = Note(context: self.state.moc)
                note!.postedDate = self.state.session.date
                note!.lastUpdate = Date()
                note!.id = UUID()
                note!.alive = true

                if let job = self.state.forms.note.job {
                    job.addToMNotes(note!)
                }
            } else if mode == .update {
                note!.lastUpdate = Date()
            }

            // Title is pulled directly from note content now
            note!.title = StringHelper.titleFromContent(from: title)
            self.title = note!.title ?? "Unnamed note"
            note!.body = content

            CoreDataNoteVersions(moc: self.state.moc).from(note!, source: source)
            PersistenceController.shared.save()
            
            // the last note you interacted with
            self.state.session.note = note
            self.state.save()
        } else {
            print("[error][note.create] A title is required to save")
        }
    }
}
