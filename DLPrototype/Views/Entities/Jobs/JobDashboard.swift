//
//  JobDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDashboard: View {
    var defaultSelectedJob: Job?

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    if defaultSelectedJob == nil {
                        Title(text: "Find or create a new job")
                    }
                    Spacer()
                    FancyButtonv2(
                        text: "New job",
                        action: {},
                        icon: "plus",
                        showLabel: false,
                        redirect: AnyView(JobCreate()),
                        pageType: .jobs,
                        sidebar: AnyView(JobDashboardSidebar())
                    )
                }

                About()

                if let jerb = defaultSelectedJob {
                    JobView(job: jerb)
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: defaultSelectedJob, perform: actionOnChange)
    }
}

extension JobDashboard {
    private func actionOnAppear() -> Void {

    }

    private func actionOnChange(job: Job?) -> Void {

    }
}

extension JobDashboard {
    struct About: View {
        private let copy: String = "Perform a search using the sidebar widget or create a new job using the \"New Job\" (or +) button."

        var body: some View {
            VStack {
                HStack {
                    Text(copy).padding(15)
                    Spacer()
                }
            }
            .background(Theme.cOrange)
        }
    }
}

struct JobDashboardRedux: View {
    @AppStorage("jobdashboard.explorerVisible") private var explorerVisible: Bool = true
    @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "hammer")
                        Text("Jobs")
                    }
                    .font(.title2)
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: {
                            editorVisible = true
                            explorerVisible = false

                            // Creates a new job entity so the user can customize it
                            let newJob = Job(context: moc)
                            newJob.id = UUID()
                            newJob.jid = 1.0
                            newJob.colour = Color.randomStorable()
                            newJob.alive = true
                            newJob.project = CoreDataProjects(moc: moc).alive().first(where: {$0.company?.isDefault == true})
                            newJob.created = Date()
                            newJob.lastUpdate = newJob.created
                            newJob.overview = "Edit this description"
                            newJob.title = "Sample job title"
                            nav.session.job = newJob
                            nav.forms.jobSelector.editor.job = newJob
                        },
                        icon: "plus",
                        showLabel: false
                    )
                }
                
                FancyDivider()
                
                JobExplorer()

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}

struct JobExplorer: View {
    @AppStorage("jobdashboard.explorerVisible") private var explorerVisible: Bool = true
    @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true

    @EnvironmentObject private var nav: Navigation

    @FetchRequest private var companies: FetchedResults<Company>

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Explorer").font(.title2)
                    Spacer()
                    FancySimpleButton(
                        text: explorerVisible ? "Close" : "Open",
                        action: {explorerVisible.toggle()},
                        icon: explorerVisible ? "minus.square.fill" : "plus.square.fill",
                        showLabel: false,
                        showIcon: true,
                        size: .tiny,
                        type: .clear
                    )
                }
                
                HStack {
                    Text("Choose a job by first selecting the company, then project, it is associated with.")
                        .font(.caption)
                    Spacer()
                }
            }
            .padding(5)
            .background(.white.opacity(0.2))
            .foregroundStyle(.white)
            
            if explorerVisible {
                ThreePanelGroup(orientation: .horizontal, data: companies)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Editor").font(.title2)
                    Spacer()
                    FancySimpleButton(
                        text: editorVisible ? "Close" : "Open",
                        action: {editorVisible.toggle()},
                        icon: editorVisible ? "minus.square.fill" : "plus.square.fill",
                        showLabel: false,
                        showIcon: true,
                        size: .tiny,
                        type: .clear
                    )
                }

                HStack {
                    Text("Modify the Active job.")
                        .font(.caption)
                    Spacer()
                }
            }
            .padding(5)
            .background(.white.opacity(0.2))
            .foregroundStyle(.white)
            
            if editorVisible {
                if let job = nav.session.job {
                    VStack {
                        JobViewRedux(job: job)
                    }
                    .padding(5)
                    .background(Theme.rowColour)
                    .foregroundStyle(.white)
                } else {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text("No job selected")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Theme.rowColour)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    init() {
        _companies = CoreDataCompanies.all()
    }
    
    public struct JobViewRedux: View {
        public var job: Job? = nil
        private var fields: [Navigation.Forms.Field] { job != nil ? job!.fields : [] }
        private let columnSplit: [Navigation.Forms.Field.LayoutType] = [.date, .projectDropdown]
        private var columns: [GridItem] {
            Array(repeating: .init(.flexible(minimum: 300)), count: 2)
        }

        @State private var isDeletePresented: Bool = false
        @State private var isInvalidJobIdWarningPresented: Bool = false

        @AppStorage("jobdashboard.explorerVisible") private var explorerVisible: Bool = true
        @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            ScrollView {
                if job != nil {
                    Grid(alignment: .topLeading, horizontalSpacing: 8, verticalSpacing: 10) {
                        LazyVGrid(columns: columns) {
                            VStack {
                                ForEach(fields.filter({!columnSplit.contains($0.type)})) { field in
                                    field.body
                                }
                                Spacer()
                            }
                            .padding([.top, .leading], 8)
                            
                            VStack {
                                ForEach(fields.filter({columnSplit.contains($0.type)})) { field in
                                    field.body
                                }
                                FancyDivider()
                                HStack(alignment: .bottom) {
                                    FancySimpleButton(text: "Delete", action: {isDeletePresented = true}, icon: "trash", showLabel: false, showIcon: true, type: .destructive)
                                        .alert("Are you sure you want to delete job ID \(job!.jid.string)? This is irreversible.", isPresented: $isDeletePresented) {
                                            Button("Yes", role: .destructive) {
                                                self.triggerDelete()
                                            }
                                            Button("No", role: .cancel) {}
                                        }
                                    Spacer()
                                    FancySimpleButton(text: "Save", action: triggerSave)
                                        .keyboardShortcut("s", modifiers: [.command])
                                        .alert("Please change the job ID to something other than 1.0", isPresented: $isInvalidJobIdWarningPresented) {
                                            Button("Ok", role: .cancel) {}
                                        }
                                }
                                Spacer()
                            }
                            .padding([.top, .trailing], 8)
                        }
                    }
                    .background(Theme.toolbarColour)
                    .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: Theme.rowColour)
                    .padding(8)
                }
            }
        }
    }
}

extension JobExplorer.JobViewRedux {
    /// Triggers a save event so all fields can be updated at once
    /// - Returns: Void
    private func triggerSave() -> Void {
        Task {
            await self.onSave()
        }
    }
    
    /// Update all fields at the same time
    /// - Returns: Void
    private func onSave() async -> Void {
        if job != nil && job!.jid > 1.0 {
            for field in job!.fields {
                field.save()
            }
        } else {
            isInvalidJobIdWarningPresented = true
        }
    }

    /// Deletes the current Job
    /// - Returns: Void
    private func triggerDelete() -> Void {
        // Temporary jobs will have a default JID value, they can be safely hard-deleted
        nav.session.job = nil
        editorVisible = false
        explorerVisible = true

        Task {
            await self.onDelete()
        }
    }
    
    /// If an object is a temporary job (has jid=1.0), hard delete the job. If not, soft delete it.
    /// - Returns: Void
    private func onDelete() async -> Void {
        if job != nil {
            if job!.jid == 1.0 {
                moc.delete(job!)
            } else {
                job!.alive = false
            }

            PersistenceController.shared.save()
        }
    }
}
