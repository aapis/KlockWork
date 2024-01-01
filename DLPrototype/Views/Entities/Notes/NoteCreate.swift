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
    private var isCreating: Bool { note == nil }

    @State private var title: String = ""
    @State private var content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n"
    @State private var job: Job? = nil

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                FancyTextField(placeholder: "Placeholder content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
                HStack {
                    Spacer()
                    NoteVersionExplorer(note: note)
                }
            }
            Spacer()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.forms.note.template) { newTemplate in
            if let def = nav.forms.note.template {
                content = def.template
            }
        }
        .onChange(of: nav.forms.note.job) { newJob in
            job = newJob
        }
        .onChange(of: nav.saved) { status in
            if status {
                self.save()
            }
        }
    }
    
    struct NoteVersionExplorer: View {
        public var note: Note? = nil
        private var versions: [NoteVersion] = []

        var body: some View {
            VStack(alignment: .leading) {
                if note != nil  {
                    ForEach(versions) { version in
                        Text(version.created!.description)
                    }
                }
            }
        }
        
        init(note: Note? = nil) {
            self.note = note
            
            if let note = self.note {
                self.versions = note.versions!.allObjects as! [NoteVersion]
            }
        }
    }
}

extension NoteCreate {
    private func actionOnAppear() -> Void {
        if !isCreating {
            if let n = note {
                if let body = n.body {
                    content = body
                    title = StringHelper.titleFromContent(from: body)
                }
                job = n.mJob
            }
        }
    }

    private func save() -> Void {
        // Allow saving if there's at least one line and a job
        if job == nil {
            print("[error][note.create] A job is required to save")
            return
        }

        if let title = content.lines.first {
            var note = note
            if isCreating {
                note = Note(context: moc)
                note!.postedDate = nav.session.date
                note!.lastUpdate = nav.session.date
                note!.id = UUID()
                note!.alive = true

                if let job = job {
                    note!.mJob = job
                }
            } else {
                note!.lastUpdate = Date()
            }

            // Title is pulled directly from note content now
            note!.title = StringHelper.titleFromContent(from: title)
            self.title = note!.title ?? "Unnamed note"
            note!.body = content

            let version = NoteVersion(context: moc)
            version.id = UUID()
            version.title = note!.title
            version.content = note!.body
            version.starred = false
            version.created = note!.postedDate
            
            PersistenceController.shared.save()
            
            // the last note you interacted with
            nav.session.note = note
            nav.save()
        } else {
            print("[error][note.create] A title is required to save")
        }
        
        print("[error][note.create] should be ok")
    }
}
