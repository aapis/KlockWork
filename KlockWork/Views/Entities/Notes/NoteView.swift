//
//  Note.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteView: View {
    @EnvironmentObject public var state: Navigation
    @State public var note: Note?

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var lastUpdate: Date?
    @State private var star: Bool? = false
    @State private var selectedJob: Job?
    @State private var autoSelectedJobId: String = ""
    @State private var currentVersion: Int = 0
    @State private var disableNextButton: Bool = false
    @State private var disablePreviousButton: Bool = false
    @State private var noteVersions: [NoteVersion] = []
    // TODO: remove above (moved to NVNW)
    @State private var sidebarVisible: Bool = false // TODO: move to app settings
    @State private var isShareAlertVisible: Bool = false

    private var jobs: [Job] {
        CoreDataJob(moc: self.state.moc).all()
    }
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Change associated job", tag: 0)]
        
        for job in jobs {
            items.append(CustomPickerItem(title: job.jid.string, tag: Int(job.jid)))
        }
        
        return items
    }
    
    private var versions: [NoteVersion] {
        if let id = note?.id {
            return CoreDataNoteVersions(moc: self.state.moc).by(id: id)
        }

        return []
    }

    public var body: some View {
        NoteView.Detail(
            note: note,
            ref: self,
            jobs: jobs,
            title: $title,
            content: $content,
            lastUpdate: $lastUpdate,
            star: $star,
            selectedJob: $selectedJob,
            autoSelectedJobId: $autoSelectedJobId,
            currentVersion: $currentVersion,
            disableNextButton: $disableNextButton,
            disablePreviousButton: $disablePreviousButton,
            noteVersions: $noteVersions,
            isShareAlertVisible: $isShareAlertVisible
        )
    }

    public init(note: Note? = nil) {
        self.note = note
        self.title = self.note?.title ?? ""
        self.content = self.note?.body ?? ""
        self.lastUpdate = self.note?.lastUpdate
        self.star = self.note?.starred
    }

    // TODO: should not be part of this view
    public func pickerChange(selected: Int, sender: String?) -> Void {
        let matchedJob = jobs.filter({$0.jid == Double(selected)})

        if matchedJob.count == 1 {
            selectedJob = matchedJob[0]
        }
    }

    public func revisionNotLatest() -> Bool {
        return currentVersion < noteVersions.count
    }
}

extension NoteView {
    public struct Detail: View {
        @EnvironmentObject public var state: Navigation
        @State public var note: Note?
        public var ref: NoteView
        public var jobs: [Job]

        @Binding public var title: String
        @Binding public var content: String
        @Binding public var lastUpdate: Date?
        @Binding public var star: Bool?
        @Binding public var selectedJob: Job?
        @Binding public var autoSelectedJobId: String
        @Binding public var currentVersion: Int
        @Binding public var disableNextButton: Bool
        @Binding public var disablePreviousButton: Bool
        @Binding public var noteVersions: [NoteVersion]
        @Binding public var isShareAlertVisible: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 13) {
                    TopBar
                    
                    JobPickerUsing(onChange: {selected,sender in ref.pickerChange(selected: selected, sender: sender)}, jobId: $autoSelectedJobId)
                    
                    HStack(alignment: .top, spacing: 5) {
                        VStack(alignment: .leading) {
                            FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, disabled: ref.revisionNotLatest(), text: $title)
                            FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, disabled: ref.revisionNotLatest(), text: $content)
                                .scrollIndicators(.never)
                        }
                    }
                    
                    HelpBar
                }
                .padding()
            }
            .background(Theme.toolbarColour)
            .onAppear(perform: createBindings)
        }
        
        var TopBar: some View {
            HStack {
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
                    
                    FancyButtonv2(
                        text: "Share \(note?.title ?? "_NO_TITLE")",
                        action: share,
                        icon: "square.and.arrow.up",
                        showLabel: false
                    )
                    .alert("Copied note contents to clipboard", isPresented: $isShareAlertVisible) {
                        Button("OK", role: .cancel) {}
                    }
                }
                
                if star == true {
                    FancyButtonv2(text: "Un-favourite", action: starred, icon: "star.fill", showLabel: false, type: .star)
                        .keyboardShortcut("+", modifiers: .command)
                } else {
                    FancyButtonv2(text: "Favourite", action: starred, icon: "star", showLabel: false)
                        .keyboardShortcut("+", modifiers: .command)
                }
            }
        }
        
        
        @ViewBuilder private var HelpBar: some View {
            Spacer()
            ZStack(alignment: .topLeading) {
                Theme.darkBtnColour
                
                HStack(spacing: 10) {
                    FancyButtonv2(
                        text: "Delete",
                        action: delete,
                        icon: "trash",
                        showLabel: false,
                        type: .destructive,
                        redirect: AnyView(NoteDashboard()),
                        pageType: .notes,
                        sidebar: AnyView(NoteDashboardSidebar())
                    )
                    
                    Spacer()
                    FancyButtonv2(
                        text: "Cancel",
                        action: {},
                        icon: "xmark",
                        showLabel: false,
                        redirect: AnyView(NoteDashboard()),
                        pageType: .notes,
                        sidebar: AnyView(NoteDashboardSidebar())
                    )
                    if ref.revisionNotLatest() {
                        FancyButtonv2(text: "Restore", action: update, size: .medium, type: .primary)
                            .keyboardShortcut("s", modifiers: .command)
                    } else {
                        FancyButtonv2(text: "Save", action: update, size: .medium, type: .primary)
                            .keyboardShortcut("s", modifiers: .command)
                    }
                }
                .font(.callout)
                .padding()
            }
            .frame(height: 30)
        }

        public func previousVersion() -> Void {
            if self.note != nil {
                let all = CoreDataNoteVersions(moc: self.state.moc).by(id: note!.id!)

                if currentVersion > 0 {
                    disableNextButton = false
                    // change text fields
                    let prev = all[currentVersion - 1]
                    title = prev.title!
                    content = prev.content!
                    lastUpdate = prev.created!

                    if currentVersion == noteVersions.count {
                        CoreDataNoteVersions(moc: self.state.moc).from(note!)
                    }

                    currentVersion -= 1
                } else {
                    disablePreviousButton = true
                }
            }
        }
        
        public func nextVersion() -> Void {
            if self.note != nil {
                let all = CoreDataNoteVersions(moc: self.state.moc).by(id: note!.id!)

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
        }
        

        
        private func starred() -> Void {
            note?.starred.toggle()

            update()
        }
        
        public func update() -> Void {
            if note != nil {
                note!.title = title // TODO: REMOVE
                note!.body = content // TODO: REMOVE
                note!.lastUpdate = Date()
                lastUpdate = note!.lastUpdate
                note!.mJob = selectedJob
                note!.alive = true

                CoreDataNoteVersions(moc: self.state.moc).from(note!)

                noteVersions = CoreDataNoteVersions(moc: self.state.moc).by(id: note!.id!)
                currentVersion = noteVersions.count

                PersistenceController.shared.save()
            }
        }
        
        public func delete() -> Void {
            note?.alive = false

            PersistenceController.shared.save()
        }
        
        private func hardDelete() -> Void {
            if self.note != nil {
                delete() // soft delete
                self.state.moc.delete(note!)

                PersistenceController.shared.save()
            }
        }
        
        public func createBindings() -> Void {
            if let stored = self.state.session.note {
                self.note = stored
            }

            if self.note != nil {
                selectedJob = note!.mJob ?? nil
                lastUpdate = note!.lastUpdate ?? nil
                noteVersions = CoreDataNoteVersions(moc: self.state.moc).by(id: note!.id!)
                currentVersion = noteVersions.count
                autoSelectedJobId = selectedJob?.jid.string ?? ""
                self.content = noteVersions.last?.content ?? ""
                self.title = noteVersions.last?.title ?? ""
            }
        }
        
        private func share() -> Void {
            if self.note != nil {
                isShareAlertVisible = true

                var exportableNote = ""

                if let title = note!.title {
                    exportableNote += "\(title)\n"
                }

                if let job = note!.mJob {
                    if let uri = job.uri {
                        exportableNote += "Job ID \(job.jid.string) - \(uri.absoluteString)\n"
                    } else {
                        exportableNote += "Job ID \(job.jid.string)\n"
                    }
                }

                if let body = note!.body {
                    exportableNote += body
                }

                if !exportableNote.isEmpty {
                    ClipboardHelper.copy(exportableNote)
                }
            }
        }
    }
}
