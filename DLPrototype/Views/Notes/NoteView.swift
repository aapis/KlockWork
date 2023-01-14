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
    @State private var currentVersion: Int = 0
    @State private var disableNextButton: Bool = false
    @State private var disablePreviousButton: Bool = false
    @State private var noteVersions: [NoteVersion] = []
    
    @Environment(\.managedObjectContext) var moc
    
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
    
//    private var currentVersion: NoteVersion {
//        versions.last!
//    }
    
    var body: some View {
        VStack {
            if isShowingEditor {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 22) {
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
                                
                                Image(systemName: "pencil")
                                    .help("Created: \(DateHelper.shortDateWithTime(note.postedDate))")
                                    .padding(8)
                                    .background(Theme.toolbarColour)
                                
                            }
                            
                            if note.starred {
                                FancyButton(text: "Un-favourite", action: starred, icon: "star.fill", showLabel: false)
                                    .keyboardShortcut("+")
                            } else {
                                FancyButton(text: "Favourite", action: starred, icon: "star", showLabel: false)
                            }
                        }

                        JobPicker(onChange: pickerChange, transparent: true, labelText: "Job: \(selectedJob?.jid.string ?? "N/A")", showLabel: true)
                        FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, disabled: revisionNotLatest(), text: $title)
                        FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, disabled: revisionNotLatest(), text: $content)
                        
                        Spacer()
                        
                        HStack {
                            NavigationLink {
                                NoteDashboard()
                                    .navigationTitle("Note dashboard")
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Dashboard")
                                }
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                            .font(.title3)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .onHover { inside in
                                if inside {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            
                            FancyButton(text: "Delete", action: delete)
                            Spacer()
                            
                            if revisionNotLatest() {
                                FancyButton(text: "Restore", action: update)
                                    .keyboardShortcut("s")
                            } else {
                                FancyButton(text: "Update", action: update)
                                    .keyboardShortcut("s")
                            }
                        }
                    }
                    .padding()
                }
                .background(Theme.toolbarColour)
            } else {
                NoteDashboard() // TODO: not a great idea, I think
            }
        }
        .onAppear(perform: {createBindings(note: note)})
        .onChange(of: note, perform: createBindings)
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
        selectedJob = note.job ?? nil
        lastUpdate = note.lastUpdate ?? nil
        isShowingEditor = true
        noteVersions = CoreDataNoteVersions(moc: moc).by(id: note.id!)
        currentVersion = noteVersions.count
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
