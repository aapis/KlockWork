//
//  NoteFormWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteFormWidget: View {
    @State public var note: Note?
    @State private var currentVersion: NoteVersion?
    @State private var mode: EntityViewMode = .ready
    @State private var isDeleteAlertShowing: Bool = false

    @EnvironmentObject private var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(mode == .create ? "Creating" : "Editing")
                        .font(Theme.fontSubTitle)
                    Spacer()
                    if let version = nav.forms.note.version {
                        if let uuid = version.id?.uuidString.prefix(6) {
                            Text("#" + uuid)
                                .foregroundStyle(.white)
                                .font(Theme.fontSubTitle)
                                .opacity(0.5)
                        }
                    }
                }
                Divider()
            }
            .padding(.bottom, 5)
            
            
            if mode == .create {
                TemplateChooser()
            }
            
            StarChooser()
            
            if mode == .update {
                VersionChooser()
            }

            JobChooser()

            HStack {
                if mode == .create {
                    FancySimpleButton(text: "Close", type: .clear, href: .notes)
                } else if self.mode == .update {
                    FancySimpleButton(
                        text: "Delete",
                        action: {isDeleteAlertShowing = true},
                        icon: "trash",
                        showLabel: false,
                        showIcon: true,
                        type: .destructive
                    )
                    .alert("Delete note \"\(note!.title!)\"", isPresented: $isDeleteAlertShowing) {
                        Button("Yes", role: .destructive) {
                            if let n = note {
                                n.alive = false
                                PersistenceController.shared.save()
                                nav.to(.notes)
                            }
                        }
                        Button("No", role: .cancel) {}
                    }
                }
                Spacer()
                
                if mode == .update {
                    FancySimpleButton(
                        text: "Save & Close",
                        action: {nav.save()},
                        type: nav.forms.note.job == nil ? .error : .standard
                    )
                    .disabled(nav.forms.note.job == nil)
                }
                
                FancySimpleButton(
                    text: note == nil ? "Create" : "Save",
                    action: {nav.save()},
                    type: nav.forms.note.job == nil ? .error : .primary,
                    href: note == nil ? .notes : nil
                )
                .keyboardShortcut("s", modifiers: .command)
                .disabled(nav.forms.note.job == nil)
            }
        }
        .padding(8)
        .background(Theme.base.opacity(0.2))
        .onAppear(perform: actionOnAppear)
        .onChange(of: self.nav.session.job) {
            self.nav.forms.note.job = self.nav.session.job
        }
    }

    struct StarChooser: View {
        public var note: Note?

        @State private var starred: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                ModuleHeader(text: "Starred?")

                HStack(alignment: .top, spacing: 1) {
                    FancyButtonv2(
                        text: "Toggle",
                        action: {starred.toggle()},
                        fgColour: .white,
                        showLabel: true,
                        showIcon: false,
                        size: .link
                    )
                    .help("Change whether this note is favourited")
                    .padding(5)
                    .background(Color.lightGray())
                    
                    HStack {
                        Text(starred ? "Yes" : "No")
                            .padding(2)
                        Spacer()
                    }
                    .padding(5)
                    .foregroundColor(.black)
                    .background(starred ? .orange : .gray)
                }
                FancyDivider()
            }
            .onAppear(perform: {
                if let n = note {
                    starred = n.starred
                }
            })
            .onChange(of: starred) {
                if let n = note {
                    n.starred = self.starred
                }
            }
        }
    }

    struct TemplateChooser: View {
        @State private var showTemplates: Bool = false
        @State private var allowChangeTemplate: Bool = false
        @State private var selectedTemplate: NoteTemplates.Template? = nil
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                ModuleHeader(text: "Template")
                
                HStack(alignment: .top, spacing: 1) {
                    VStack {
                        FancyButtonv2(
                            text: nav.forms.note.template != nil ? "Selected" : "Choose",
                            action: {showTemplates.toggle()},
                            fgColour: .white,
                            showLabel: true,
                            showIcon: false,
                            size: .link
                        )
                        .help("Choose a template")
                        .padding(5)
                        .foregroundColor(.black)
                        .background(Color.lightGray())
                        .alert("Changing templates will override your existing note content.\n\nAre you sure?", isPresented: $allowChangeTemplate) {
                            Button("Yes", role: .destructive) {
                                nav.forms.note.template = selectedTemplate
                            }
                            Button("No", role: .cancel) {}
                        }
                    }
                    
                    if let template = nav.forms.note.template {
                        FancyButtonv2(
                            text: template.name,
                            action: {
                                nav.forms.note.template = nil
                            },
                            fgColour: .black,
                            showLabel: true,
                            showIcon: false,
                            size: .link
                        )
                        .help("Deselect this template")
                        .padding(5)
                        .background(.orange)
                    } else {
                        HStack {
                            Text("None")
                                .padding(3)
                                .foregroundColor(.black)
                                .opacity(0.6)
                            Spacer()
                        }
                        .padding(4)
                        .background(Color.accentColor)
                    }
                }
                
                if showTemplates {
                    ForEach(NoteTemplates.DefaultTemplateConfiguration.allCases, id: \.id) { config in
                        FancyButtonv2(
                            text: config.definition.name,
                            action: {showTemplates.toggle() ; selectedTemplate = config.definition},
                            showLabel: true,
                            showIcon: false,
                            size: .link
                        )
                        .help("Deselect this job, then show the Active Job prompt (if available)")
                        .padding(5)
                        .background(Color.lightGray().opacity(0.4))
                    }
                }
                
                FancyDivider()
            }
            .onChange(of: selectedTemplate) {
                if self.selectedTemplate != nil {
                    allowChangeTemplate = true
                }
            }
        }
    }
    
    struct JobChooser: View {
        @State private var jobSearchText: String = ""
        @State public var filteredJobs: [Job] = []
        
        @EnvironmentObject private var nav: Navigation
        
        @FetchRequest private var jobs: FetchedResults<Job>
        
        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                ModuleHeader(text: "Job")
                
                HStack(alignment: .top, spacing: 1) {
                    HStack {
                        Text(nav.forms.note.job != nil ? "Selected" : "Choose")
                            .padding(2)
                            .foregroundColor(.black)
                            .opacity(0.6)
                        Spacer()
                    }
                    .padding(5)
                    .background(Color.lightGray())
                    
                    if let job = nav.forms.note.job {
                        FancyButtonv2(
                            text: job.jid.string,
                            action: {nav.forms.note.job = nil},
                            fgColour: job.foregroundColor,
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .help("Click to deselect this job")
                        .padding(5)
                        .background(job.backgroundColor)
                    } else {
                        HStack {
                            Text("None")
                                .padding(3)
                                .foregroundColor(.black)
                                .opacity(0.6)
                            Spacer()
                        }
                        .padding(4)
                        .background(Color.accentColor)
                    }
                }
                SearchBar(text: $jobSearchText, placeholder: "Find jobs by ID...")

                if filteredJobs.count > 0 {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(filteredJobs, id: \.objectID) { job in
                                FancyButtonv2(
                                    text: job.jid.string,
                                    action: {choose(job)},
                                    fgColour: job.foregroundColor,
                                    showLabel: true,
                                    showIcon: false,
                                    size: .link,
                                    type: .clear
                                )
                                .padding(5)
                                .background(job.backgroundColor)
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                }
                
                FancyDivider()
            }
            .onChange(of: self.jobSearchText) {
                if self.jobSearchText.count >= 2 {
                    filteredJobs = jobs.filter {$0.jid.string.starts(with: self.jobSearchText)}
                } else {
                    filteredJobs = []
                }
            }
        }
        
        init() {
            _jobs = CoreDataJob.fetchAll()
        }
    }
    
    struct VersionChooser: View {
        public var note: Note? = nil
        private var mode: EntityViewMode = .ready
        private var versions: [NoteVersion] = []
        
        @State private var showVersions: Bool = false
        @State private var allowChangeVersions: Bool = false
        
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                ModuleHeader(text: "Content revision history")
                
                HStack(alignment: .top, spacing: 1) {
                    HStack {
                        FancyButtonv2(
                            text: nav.forms.note.version != nil ? "Selected" : "Choose",
                            action: {showVersions.toggle()},
                            fgColour: .white,
                            showLabel: true,
                            showIcon: false,
                            size: .link
                        )
                        .help("Choose a version of this note")
                        .foregroundColor(.black)
                        .background(Color.lightGray())
                        Spacer()
                    }
                    .padding(5)
                    .background(Color.lightGray())
                    
                    if let version = nav.forms.note.version {
                        FancyButtonv2(
                            text: version.created!.formatted(date: .omitted, time: .shortened),
                            action: {nav.forms.note.version = nil ; showVersions = false},
                            fgColour: .black,
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .help(version.created!.formatted(date: .numeric, time: .shortened))
                        .padding(5)
                        .background(.orange)
                    } else {
                        HStack {
                            Text("None")
                                .padding(3)
                                .foregroundColor(.black)
                                .opacity(0.6)
                            Spacer()
                        }
                        .padding(4)
                        .background(Color.accentColor)
                    }
                }
                
                if showVersions {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(versions, id: \.objectID) { version in
                                if let date = version.created {
                                    FancyButtonv2(
                                        text: self.labelText(date: date, version: version),
                                        action: {showVersions.toggle() ; nav.forms.note.version = version},
                                        fgColour: nav.forms.note.version == version ? .black : .white,
                                        showIcon: false,
                                        size: .link,
                                        type: .clear
                                    )
                                    .padding(5)
                                    .background(nav.forms.note.version == version ? Color.orange : Color.lightGray().opacity(0.4))
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                }
                
                FancyDivider()
            }
        }
        
        init(note: Note? = nil) {
            self.note = note
            
            if let note = self.note {
                self.versions = note.versions!.allObjects as! [NoteVersion]
                self.versions = self.versions.sorted(by: {$0.created! > $1.created!})
                self.mode = .update
            } else {
                self.mode = .create
            }
        }
    }
    
    private struct ModuleHeader: View {
        public var text: String
        
        var body: some View {
            HStack {
                Text(text)
                    .padding(3)
                Spacer()
            }
            .padding(5)
            .background(Theme.base.opacity(0.4))
        }
    }
}

extension NoteFormWidget {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.nav.session.note {
            self.note = stored
            self.mode = .update

            let versions = stored.versions?.allObjects as! [NoteVersion]
            self.currentVersion = versions.sorted(by: {$0.created! > $1.created!}).first
        } else {
            self.mode = .create
        }

        if let job = nav.session.job {
            nav.forms.note.job = job
        } else if let n = note {
            nav.forms.note.job = n.mJob
        }

        nav.forms.note.version = currentVersion
    }
}

extension NoteFormWidget.JobChooser {
    private func choose(_ job: Job) -> Void {
        nav.forms.note.job = job
        jobSearchText = ""
    }
}

extension NoteFormWidget.VersionChooser {
    private func labelText(date: Date, version: NoteVersion) -> String {
        var label = ""

        if let source = version.source {
            if source == "Automatic" {
                label += "[Auto] "
            }
        }
        
        label += date.formatted(date: .numeric, time: .shortened)
        
        return label
    }
}
