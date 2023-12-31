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
                        .keyboardShortcut("s", modifiers: .command)

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
    @State private var title: String = ""
    @State private var content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n"
    @State private var job: Job? = nil

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
                nav.to(.notes)
            }
        }
    }
}

extension NoteCreatev2 {
    private func save() -> Void {
        // Allow saving if there's at least one line and a job
        if job == nil {
            print("[error][note.create] A job is required to save")
            return
        }

        if let title = content.lines.first {
            let note = Note(context: moc)
            // Title is pulled directly from note content now
            note.title = title.starts(with: "#") ? title.replacingOccurrences(of: "# ", with: "") : "Generic note title"
            // Remove title from content
            note.body = title.isEmpty ? content : content.replacingOccurrences(of: title, with: "").lines[1...].joined()
            note.postedDate = nav.session.date
            note.lastUpdate = nav.session.date
            note.id = UUID()
            note.alive = true

            if let job = job {
                note.mJob = job
            }

            let version = NoteVersion(context: moc)
            version.id = UUID()
            version.title = note.title
            version.content = note.body
            version.starred = false
            version.created = note.postedDate

            PersistenceController.shared.save()

            nav.session.note = note
        } else {
            print("[error][note.create] A title is required to save")
        }
    }
}
