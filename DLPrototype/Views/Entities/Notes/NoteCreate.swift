//
//  NoteCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteCreate: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedJob: Job?
    @State private var jobId: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    
    
    private var jobs: [Job] {
        CoreDataJob(moc: moc).all()
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                Title(text: "Create a note")
                JobPickerUsing(onChange: pickerChange, jobId: $jobId)
                FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, text: $title)
                FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
                
                Spacer()

                HelpBar
            }.padding()
        }
        .background(Theme.toolbarColour)
    }

    @ViewBuilder private var HelpBar: some View {
        Spacer()
        ZStack(alignment: .topLeading) {
            Theme.darkBtnColour
            HStack {
                HStack {
                    Text("\u{2318} s: Create")
                }

                Spacer()
                HStack(spacing: 10) {
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: save,
                        size: .medium,
                        type: .primary,
                        redirect: AnyView(NoteDashboard()),
                        pageType: .notes,
                        sidebar: AnyView(NoteDashboardSidebar())
                    )
                    .keyboardShortcut("s", modifiers: [.command, .shift])

                }
                .frame(width: 300, height: 30)
            }
            .font(.callout)
            .padding()
        }
        .frame(height: 30)
    }
    
    // TODO: should not be part of this view
    private func pickerChange(selected: Int, sender: String?) -> Void {
        selectedJob = jobs.filter({ $0.jid == Double(selected)}).first
        
        if selectedJob != nil {
            jobId = selectedJob!.jid.string
        }
    }
    
    private func save() -> Void {
        let note = Note(context: moc)
        note.title = title
        note.body = content
        note.postedDate = Date()
        note.lastUpdate = Date()
        note.id = UUID()
        note.job = selectedJob // TODO: DEPRECATED
        note.mJob = selectedJob
        note.alive = true
        
        let version = NoteVersion(context: moc)
        version.id = UUID()
        version.title = title
        version.content = content
        version.starred = false
        version.created = note.postedDate

        PersistenceController.shared.save()
    }
}

struct NoteCreatev2: View {
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

extension NoteCreatev2 {
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
