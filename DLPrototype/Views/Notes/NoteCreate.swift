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

struct NoteCreatePreview: PreviewProvider {
    static var previews: some View {
        NoteCreate()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 800, height: 800)
    }
}
