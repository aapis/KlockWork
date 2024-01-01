//
//  NoteFormWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteFormWidget: View {
    public var note: Note? = nil
    private var currentVersion: NoteVersion? = nil
    private var mode: EntityViewMode = .ready
    
    @State private var isDeleteAlertShowing: Bool = false

    @EnvironmentObject private var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            VStack(alignment: .leading) {
                HStack {
                    Text(mode == .create ? "Creating" : "Editing")
                        .font(Theme.fontSubTitle)
                    
                    Spacer()
                }
                Divider()
            }
            .padding(.bottom, 5)
            
            
            if mode == .create {
                TemplateChooser()
            }
            
            if mode == .update {
                VersionChooser(note: note)
                
            }

            JobChooser()

            HStack {
                if mode == .create {
                    FancySimpleButton(text: "Close", type: .clear, href: .notes)
                } else {
                    FancySimpleButton(
                        text: "Delete",
                        action: {isDeleteAlertShowing = true},
                        icon: "trash",
                        showLabel: false,
                        showIcon: true,
                        type: .destructive
                    )
                    .alert("Delete note titled \(note!.title!)", isPresented: $isDeleteAlertShowing) {
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
                        type: nav.forms.note.job == nil ? .error : .standard,
                        href: .notes
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
    }
    
    init(note: Note? = nil) {
        self.note = note
        
        if let note = self.note {
            self.mode = .update
            
            let versions = note.versions?.allObjects as! [NoteVersion]
            self.currentVersion = versions.last
        } else {
            self.mode = .create
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
            .onChange(of: selectedTemplate) { tmpl in
                if tmpl != nil {
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
                        Text(nav.forms.note.job != nil ? "Selected" : "")
                            .padding(3)
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
                        .help("Click to deselect this job, then show the Active Job prompt (if available)")
                        .padding(5)
                        .background(job.backgroundColor)
                    } else if let job = nav.session.job {
                        FancyButtonv2(
                            text: "Active job: \(job.jid.string)",
                            action: {nav.session.job = nil},
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

                VStack(spacing: 1) {
                    ForEach(filteredJobs) { job in
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
                
                FancyDivider()
            }
            .onChange(of: jobSearchText) { query in
                if query.count >= 2 {
                    filteredJobs = jobs.filter {$0.jid.string.starts(with: query)}
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
        @State private var selectedVersion: NoteVersion? = nil
        
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                ModuleHeader(text: "Version history")
                
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
                        // @TODO: not sure we want to prompt, test more
//                        .alert("Loading a different version will override your existing note content.\n\nAre you sure?", isPresented: $allowChangeVersions) {
//                            Button("Yes", role: .destructive) {
//                                nav.forms.note.version = selectedVersion
//                            }
//                            Button("No", role: .cancel) {}
//                        }
                        Spacer()
                    }
                    .padding(5)
                    .background(Color.lightGray())
                    
                    if let version = nav.forms.note.version {
                        FancyButtonv2(
                            text: version.created!.formatted(date: .complete, time: .shortened),
                            action: {nav.forms.note.version = nil ; showVersions = false},
                            fgColour: .black,
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .help(version.created!.formatted(date: .complete, time: .shortened))
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
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(versions) { version in
                                if let date = version.created {
                                    FancyButtonv2(
                                        text: date.formatted(date: .complete, time: .shortened),
                                        action: {showVersions.toggle() ; selectedVersion = version},
                                        showIcon: false,
                                        size: .link,
                                        type: .clear
                                    )
                                    .padding(5)
                                    .background(Color.lightGray().opacity(0.4))
                                }
                            }
                        }
                    }
                }
                
                FancyDivider()
            }
            .onChange(of: selectedVersion) { version in
                if version != nil {
                    allowChangeVersions = true
                }
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
    private func actionOnAppear() -> Void {
        if let n = note {
            nav.forms.note.job = n.mJob
        }
    }
}

extension NoteFormWidget.JobChooser {
    private func choose(_ job: Job) -> Void {
        nav.forms.note.job = job
        jobSearchText = ""
    }
}
