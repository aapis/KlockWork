//
//  Note.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteView: View {
    public var note: Note
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var lastUpdate: Date?
    @State private var star: Bool? = false
    @State private var isShowingEditor: Bool = true
    @State private var selectedJob: Job?
    @State private var autoSelectedJobId: String = ""
    @State private var currentVersion: Int = 0
    @State private var disableNextButton: Bool = false
    @State private var disablePreviousButton: Bool = false
    @State private var noteVersions: [NoteVersion] = []
    @State private var sidebarVisible: Bool = false // TODO: move to app settings
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater
    
    private var jobs: [Job] {
        CoreDataJob(moc: moc).all()
    }
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Change associated job", tag: 0)]
        
        for job in jobs {
            items.append(CustomPickerItem(title: job.jid.string, tag: Int(job.jid)))
        }
        
        return items
    }
    
    private var versions: [NoteVersion] {
        CoreDataNoteVersions(moc: moc).by(id: note.id!)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                TopBar

                JobPickerUsing(onChange: pickerChange, jobId: $autoSelectedJobId)

                HStack(alignment: .top, spacing: 5) {
                    VStack(alignment: .leading) {
                        FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, disabled: revisionNotLatest(), text: $title)
                        FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, disabled: revisionNotLatest(), text: $content)
                            .scrollIndicators(.never)
                    }

                    if sidebarVisible {
                        SideBar
                    }
                }

                HelpBar
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: {createBindings(note: note)})
        .onChange(of: note, perform: createBindings)
    }

    private var TopBar: some View {
        HStack {
            Title(text: "Editing", image: "pencil")

            Spacer()

            if lastUpdate != nil {
                FancyButton(text: "Back", action: previousVersion, icon: "arrowtriangle.left", showLabel: false)
                    .disabled(disablePreviousButton)
                Text("v\(currentVersion)/\(noteVersions.count).\(DateHelper.shortDateWithTime(lastUpdate))")
                    .padding(8)
                    .background(Theme.toolbarColour)
                    .font(Theme.font)
                FancyButton(text: "Next", action: nextVersion, icon: "arrowtriangle.right", showLabel: false)
                    .disabled(disableNextButton)
                
                if sidebarVisible {
                    FancyButton(
                        text: "Close sidebar",
                        action: {sidebarVisible.toggle()},
                        icon: "sidebar.right",
                        showLabel: false,
                        fgColour: Color.accentColor
                    )
                    .keyboardShortcut("b", modifiers: .command)
                } else {
                    FancyButton(
                        text: "Open sidebar",
                        action: {sidebarVisible.toggle()},
                        icon: "sidebar.right",
                        showLabel: false
                    )
                    .keyboardShortcut("b", modifiers: .command)
                }
            }

            if note.starred {
                FancyButton(text: "Un-favourite", action: starred, icon: "star.fill", showLabel: false)
                    .keyboardShortcut("+", modifiers: .command)
            } else {
                FancyButton(text: "Favourite", action: starred, icon: "star", showLabel: false)
                    .keyboardShortcut("+", modifiers: .command)
            }
        }
    }

    private var SideBar: some View {
        VStack {
            ZStack {
                Theme.darkBtnColour

                VStack(alignment: .leading) {
                    Text("Meta")
                        .font(.title)

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        if let date = note.postedDate {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "calendar")
                                Text("\(date.formatted())")
                                    .help("Created on \(date)")
                            }
                        }

                        if let date = note.lastUpdate {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "pencil")
                                Text("\(date.formatted())")
                                    .help("Edited on \(date)")
                            }
                        }

                        if let id = note.id {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "questionmark")
                                Text("\(id.uuidString)")
                                    .help("System id: \(id.uuidString)")
                            }
                        }

                        if !note.alive {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "eye")
                                Text("Soft deleted")
                            }
                        }

                        if let versions = note.versions {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")
                                Text("\(versions.count)")
                                    .help("\(versions.count) versions saved")
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .frame(minWidth: 300, maxWidth: 400)
    }

    @ViewBuilder private var HelpBar: some View {
        Spacer()
        ZStack(alignment: .topLeading) {
            Theme.darkBtnColour
            HStack {
                HStack {
                    Text("\u{2318} s: Save")
                    Text("\u{2318} +: Toggle star")
                    Text("\u{2318} b: Toggle sidebar")
                }

                Spacer()
                HStack(spacing: 10) {
                    Spacer()
                    FancyButtonv2(
                        text: "Delete",
                        action: delete,
                        icon: "trash",
                        showLabel: false,
                        type: .destructive,
                        redirect: AnyView(
                            NoteDashboard()
                                .environmentObject(jm)
                                .environmentObject(updater)
                        )
                    )

                    if revisionNotLatest() {
                        FancyButtonv2(text: "Restore", action: update, size: .medium, type: .primary)
                            .keyboardShortcut("s", modifiers: .command)
                    } else {
                        FancyButtonv2(text: "Save", action: update, size: .medium, type: .primary)
                            .keyboardShortcut("s", modifiers: .command)
                    }
                }
                .frame(width: 300, height: 30)
            }
            .font(.callout)
            .padding()
        }
        .frame(height: 30)
    }
    
    private func previousVersion() -> Void {
        let all = CoreDataNoteVersions(moc: moc).by(id: note.id!)
        
        if currentVersion > 0 {
            disableNextButton = false
            // change text fields
            let prev = all[currentVersion - 1]
            title = prev.title!
            content = prev.content!
            lastUpdate = prev.created!
            
            if currentVersion == noteVersions.count {
                CoreDataNoteVersions(moc: moc).from(note)
            }
            
            currentVersion -= 1
        } else {
            disablePreviousButton = true
        }
    }
    
    private func nextVersion() -> Void {
        let all = CoreDataNoteVersions(moc: moc).by(id: note.id!)
        
        if currentVersion < noteVersions.count {
            disablePreviousButton = false
            
            let next = all[currentVersion + 1]
            title = next.title!
            content = next.content!
            lastUpdate = next.created!
            
            currentVersion += 1
        } else {
            disableNextButton = true
        }
    }
    
    // TODO: should not be part of this view
    private func pickerChange(selected: Int, sender: String?) -> Void {
        let matchedJob = jobs.filter({$0.jid == Double(selected)})
        
        if matchedJob.count == 1 {
            selectedJob = matchedJob[0]
        }
    }
    
    private func starred() -> Void {
        note.starred.toggle()
        
        update()
    }
    
    private func cancel() -> Void {
        isShowingEditor = false
    }
    
    private func update() -> Void {
        note.title = title // TODO: REMOVE
        note.body = content // TODO: REMOVE
        note.lastUpdate = Date()
        lastUpdate = note.lastUpdate
        note.job = selectedJob // TODO: REMOVE
        note.mJob = selectedJob
        note.alive = true
        
        CoreDataNoteVersions(moc: moc).from(note)
        
        noteVersions = CoreDataNoteVersions(moc: moc).by(id: note.id!)
        currentVersion = noteVersions.count

        PersistenceController.shared.save()
    }
    
    private func delete() -> Void {
        isShowingEditor = false
        title = ""
        content = ""
        note.alive = false
        
        PersistenceController.shared.save()
    }
    
    private func hardDelete() -> Void {
        delete() // soft delete
        moc.delete(note)
        
        PersistenceController.shared.save()
    }
    
    private func createBindings(note: Note) -> Void {
        title = note.title!
        content = note.body!
        selectedJob = note.mJob ?? nil
        lastUpdate = note.lastUpdate ?? nil
        isShowingEditor = true
        noteVersions = CoreDataNoteVersions(moc: moc).by(id: note.id!)
        currentVersion = noteVersions.count
        autoSelectedJobId = selectedJob?.jid.string ?? ""
    }
    
    private func revisionNotLatest() -> Bool {
        return currentVersion < noteVersions.count
    }
}

//struct NoteViewPreview: PreviewProvider {
//    static var previews: some View {
//        let note = Note()
//
//        NoteView(note: note).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .frame(width: 800, height: 800)
//    }
//}
