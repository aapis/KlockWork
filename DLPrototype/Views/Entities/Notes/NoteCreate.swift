//
//  NoteCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteCreate: View {
    public var note: Note? = nil
    private var mode: EntityViewMode = .ready

    @State private var title: String = ""
    @State private var content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n"

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                FancyTextField(placeholder: "Placeholder content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
            }
            Spacer()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.forms.note.template) { newTemplate in
            if mode == .create {
                if let def = nav.forms.note.template {
                    if let tmpl = def.template {
                        content = tmpl
                    }
                }
            }
        }
        .onChange(of: nav.forms.note.version) {newVersion in
            if mode == .update {
                if let version = nav.forms.note.version {
                    if let vContent = version.content {
                        content = vContent
                    }
                }
            }
        }
        .onChange(of: nav.saved) { status in
            if status {
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
                note = Note(context: moc)
                note!.postedDate = nav.session.date
                note!.lastUpdate = nav.session.date
                note!.id = UUID()
                note!.alive = true

                if let job = nav.forms.note.job {
                    job.addToMNotes(note!)
                }
            } else if mode == .update {
                note!.lastUpdate = Date()
            }

            // Title is pulled directly from note content now
            note!.title = StringHelper.titleFromContent(from: title)
            self.title = note!.title ?? "Unnamed note"
            note!.body = content

            CoreDataNoteVersions(moc: moc).from(note!, source: source)
            PersistenceController.shared.save()
            
            // the last note you interacted with
            nav.session.note = note
            nav.save()
        } else {
            print("[error][note.create] A title is required to save")
        }
    }
}
