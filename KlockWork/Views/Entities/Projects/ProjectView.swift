//
//  ProjectView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct ProjectView: View {
    @State public var project: Project?
    @State private var name: String = ""
    @State private var colour: Color = .clear
    @State private var colourChanged: Bool = false
    @State private var created: Date?
    @State private var lastUpdate: Date?
    @State private var alive: Bool = true
    @State private var selectedJobs: [Job] = []
    @State private var allUnOwned: [Job] = []
    @State private var selectAllToggleAssociated: Bool = false
    @State private var selectAllToggleUnassociated: Bool = false
    @State private var isDeleteAlertShowing: Bool = false
    @State private var selectedCompany: Int = 0
    @State private var abbreviation: String = ""
    // for Toolbar
    @State private var isShowingAlert: Bool = false
    @State private var buttons: [ToolbarButton] = []
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @EnvironmentObject public var nav: Navigation
    
    private var all: [Job] {
        jm.all()
    }
    
    private var unownedJobs: [Job] {
        jm.unowned()
    }
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                form.id(updater.ids["pv.form"])

                HStack {
                    FancyButtonv2(
                        text: "Delete",
                        action: {isDeleteAlertShowing = true},
                        icon: "trash",
                        showLabel: false,
                        type: .destructive
                    )
                    .alert("Are you sure you want to delete project \(project?.name ?? "Invalid project name")?", isPresented: $isDeleteAlertShowing) {
                        Button("Yes", role: .destructive) {
                            actionHardDelete()
                        }
                        Button("No", role: .cancel) {}
                    }

                    Spacer()
                    FancyButtonv2(text: "Save & Close", action: {
                        self.update()
                        self.nav.to(.projects)
                    })
                }
                
                Spacer()
            }
            .padding()
        }
        .id(updater.get("project.view"))
        .background(
            ZStack {
                self.nav.session.appPage.primaryColour
                Theme.base.opacity(0.6)
            }
        )
        .onAppear(perform: onAppear)
        .onChange(of: selectAllToggleAssociated) {
            if self.selectAllToggleAssociated {
                selectAll()
            } else {
                deselectAll()
            }
        }
        .onChange(of: self.selectAllToggleUnassociated) {
            if self.selectAllToggleUnassociated {
                selectAll()
            } else {
                deselectAll()
            }
        }
        .onChange(of: self.name) {
            if self.nav.session.project == self.project {
                self.abbreviation = StringHelper.abbreviate(self.name)
            }
        }
        .onChange(of: self.project?.lastUpdate) {
            self.lastUpdate = self.project?.lastUpdate
        }
        .onChange(of: self.nav.session.project) { self.onAppear() }
    }
    
    // MARK: form view
    @ViewBuilder
    var form: some View {
        HStack {
            Image(systemName: "folder").font(Theme.fontTitle)
            Title(text: "Editing: \($name.wrappedValue)")
            Spacer()
        }
        FancyTextField(placeholder: "Name", lineLimit: 1, onSubmit: update, showLabel: true, text: $name)
        FancyTextField(placeholder: "Abbreviation", lineLimit: 1, onSubmit: {}, showLabel: true, text: $abbreviation)
        CompanyPicker(onChange: {company,_ in selectedCompany = company}, selected: project?.company != nil ? Int(project?.company?.pid ?? 0) : 0)
        if let project = self.project {
            FancyProjectActiveToggle(entity: project)
        }
        FancyColourPicker(initialColour: project?.colour ?? Theme.rowColourAsDouble, onChange: {newColour in colour = newColour})

        if let createdAt = created {
            HStack {
                FancyLabel(text: "Created")
                HStack {
                    Text("\(DateHelper.shortDateWithTime(createdAt))")
                        .padding()
                        .help("Not editable")
                    Spacer()
                }
                .background(Theme.textBackground)
            }
        }

        if let updated = lastUpdate {
            HStack {
                FancyLabel(text: "Last updated")
                HStack {
                    Text("\(DateHelper.shortDateWithTime(updated))")
                        .padding()
                        .help("Not editable")
                    Spacer()
                }
                .background(Theme.textBackground)
            }
        }

        FancyDivider()
        
        toolbar
    }
    
    // MARK: jobAssignment view, job tab view
    @ViewBuilder
    var jobAssignment: some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 20) {
                    FancySubTitle(text: "Associated jobs", image: "checkmark")
                        .padding([.leading, .top])
                    Divider()
                    HStack(spacing: 1) {
                        Text("\(selectedJobs.count)/\(all.count) selected")
                            .font(Theme.fontCaption)
                        Spacer()
                        Toggle("All", isOn: $selectAllToggleAssociated)
                            .font(Theme.fontCaption)
                    }
                }
                
                if selectedJobs.count > 0 {
                    associatedJobs
                }
            }
        
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 20) {
                    FancySubTitle(text: "Unowned jobs", image: "questionmark")
                        .padding([.leading, .top])
                    Divider()
                    HStack(spacing: 1) {
                        Text("\(allUnOwned.count)/\(all.count) selected")
                            .font(Theme.fontCaption)
                        Spacer()
                        Toggle("All", isOn: $selectAllToggleUnassociated)
                            .font(Theme.fontCaption)
                    }
                }
                
                if allUnOwned.count > 0 {
                    unOwnedJobs
                }
            }
        }
        .background(self.nav.session.appPage.primaryColour)
    }
    
    // MARK: toolbar view
    @ViewBuilder
    var toolbar: some View {
        FancyGenericToolbar(
            buttons: self.buttons,
            standalone: true,
            location: .content,
            mode: .compact,
            page: .explore,
            alwaysShowTab: true
        )
        .onAppear(perform: self.createToolbar)
    }
    
    // MARK: associated jobs view
    @ViewBuilder
    var associatedJobs: some View {
        Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow {
                Group {
                    ZStack {
                        Theme.headerColour
                    }
                    
                }
                .frame(width: 30)
                
                Group {
                    ZStack(alignment: .leading) {
                        Theme.headerColour
                        Text("Job ID")
                            .padding(5)
                    }
                }
                Group {
                    ZStack {
                        Theme.headerColour
                        Text("Colour")
                            .padding(5)
                    }
                }
            }
            .frame(height: 40)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(selectedJobs, id: \.jid) { job in
                        HStack(alignment: .top, spacing: 1) {
                            GridRow {
                                Group {
                                    ZStack {
                                        Theme.rowColour
                                        
                                        FancyButton(text: "Remove job", action: {deSelectJob(job)}, icon: "multiply", transparent: true, showLabel: false)
                                    }
                                }
                                .frame(width: 30)
                                
                                Group {
                                    ZStack(alignment: .leading) {
                                        Theme.rowColour
                                        
                                        HStack {
                                            FancyLink(
                                                icon: "xmark",
                                                showIcon: false,
                                                label: job.jid.string,
                                                showLabel: true,
                                                destination: AnyView(JobDashboard(defaultSelectedJob: job)),
                                                size: .link,
                                                pageType: .jobs,
                                                sidebar: AnyView(JobDashboardSidebar())
                                            )
                                            .help("Open job \(job.jid.string)")
                                            Spacer()

                                            if let uri = job.uri {
                                                Link(destination: uri, label: {
                                                    Image(systemName: "link")
                                                        .help("Open \(uri) in browser")
                                                })
                                            }

                                            if let conf = project?.configuration {
                                                if let ignored = conf.ignoredJobs {
                                                    if ignored.contains(job.jid.string) {
                                                        FancyButton(text: "Hide from exports", action: {disableExport(job.jid.string)}, icon: "eye.slash", transparent: true, showLabel: false)
                                                            .opacity(0.3)
                                                    } else {
                                                        FancyButton(text: "Included in exports", action: {enableExport(job.jid.string)}, icon: "eye", transparent: true, showLabel: false)
                                                    }
                                                }
                                            }
                                        }
                                        .padding([.leading, .trailing], 5)
                                    }
                                }
                                
                                Group {
                                    ZStack {
                                        let colour = Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                                        colour
                                        Text(colour.description.debugDescription)
                                            .padding(5)
                                            .foregroundColor(colour.isBright() ? Theme.base : Color.white)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: unowned jobs view
    @ViewBuilder
    var unOwnedJobs: some View {
        Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow {
                Group {
                    ZStack {
                        Theme.headerColour
                    }
                    
                }
                .frame(width: 30)
                
                Group {
                    ZStack(alignment: .leading) {
                        Theme.headerColour
                        Text("Job ID")
                            .padding(5)
                    }
                }
                
                Group {
                    ZStack {
                        Theme.headerColour
                        Text("Colour")
                            .padding(5)
                    }
                }
            }
            .frame(height: 40)
        
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(allUnOwned, id: \.objectID) { job in
                        HStack(alignment: .top, spacing: 1) {
                            GridRow {
                                Group {
                                    ZStack {
                                        Theme.rowColour
                                        
                                        FancyButton(text: "Add job", action: {selectJob(job)}, icon: "plus", transparent: true, showLabel: false)
                                    }
                                }
                                .frame(width: 30)
                                
                                Group {
                                    ZStack(alignment: .leading) {
                                        Theme.rowColour

                                        HStack {
                                            FancyLink(
                                                icon: "xmark",
                                                showIcon: false,
                                                label: job.jid.string,
                                                showLabel: true,
                                                destination: AnyView(JobDashboard(defaultSelectedJob: job)),
                                                size: .link,
                                                pageType: .jobs,
                                                sidebar: AnyView(JobDashboardSidebar())
                                            )
                                            .help("Open job \(job.jid.string)")
                                            Spacer()

                                            if let uri = job.uri {
                                                Link(destination: uri, label: {
                                                    Image(systemName: "link")
                                                        .help("Open \(uri) in browser")
                                                })
                                            }
                                        }
                                        .padding([.leading, .trailing], 5)
                                    }
                                }
                                
                                Group {
                                    ZStack {
                                        let colour = Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                                        colour
                                        Text(colour.description.debugDescription)
                                            .padding(5)
                                            .foregroundColor(colour.isBright() ? Theme.base : Color.white)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ProjectView {
//    private func regenerateColour() -> Void {
//        let rndColour = Color.randomStorable()
//        colour = Color.fromStored(rndColour).description.debugDescription
//        project?.colour = rndColour
//        colourChanged = true
//
//        PersistenceController.shared.save()
//        updater.update()
//    }

    private func createToolbar() -> Void {
        self.buttons = [
            ToolbarButton(
                id: 0,
                helpText: "Assign jobs to the project",
                icon: "square.grid.3x1.fill.below.line.grid.1x2",
                labelText: "Jobs",
                contents: AnyView(jobAssignment)
            ),
            ToolbarButton(
                id: 1,
                helpText: "Create/assign configurations to the project",
                icon: "circles.hexagongrid.fill",
                labelText: "Configuration",
                contents: AnyView(ProjectConfig(project: project))
            )
        ]
    }

    private func update() -> Void {
        project?.name = self.name
        project?.jobs = []
        project?.alive = self.alive
        project?.lastUpdate = Date()
        project?.company = CoreDataCompanies(moc: moc).byPid(selectedCompany)
        project?.abbreviation = self.abbreviation

        // @TODO: this is no longer what we want
        if colourChanged {
            project?.colour = Color.randomStorable()
        }

        lastUpdate = project?.lastUpdate!

        saveSelectedJobs()

        PersistenceController.shared.save()
    }

    private func isJobOnIgnoreList(_ jid: String) -> Bool {
        if let ignoredJobs = project?.configuration!.ignoredJobs {
            do {
                let dec = JSONDecoder()
                let data = ignoredJobs.data(using: .utf8)
                let decodedIgnoredJobs = try dec.decode([String].self, from: data!)

                return decodedIgnoredJobs.contains(jid)
            } catch {
                print("Couldn't decode ignored")
            }
        }

        return false
    }

    private func enableExport(_ jid: String) -> Void {
        if let ignoredJobs = project?.configuration!.ignoredJobs {
            do {
                let dec = JSONDecoder()
                let data = ignoredJobs.data(using: .utf8)
                var decodedIgnoredJobs = try dec.decode([String].self, from: data!)

                if !decodedIgnoredJobs.contains(jid) {
                    decodedIgnoredJobs.append(jid)
                }

                let enc = JSONEncoder()
                let json = try enc.encode(decodedIgnoredJobs)

                project?.configuration!.ignoredJobs = String(data: json, encoding: .utf8)!

                updater.update()
            } catch {
                print("Couldn't encode ignoredJobs")
            }
        }

        PersistenceController.shared.save()
    }

    private func disableExport(_ jid: String) -> Void {
        if let ignoredJobs = project?.configuration!.ignoredJobs {
            do {
                let dec = JSONDecoder()
                let data = ignoredJobs.data(using: .utf8)
                var decodedIgnoredJobs = try dec.decode([String].self, from: data!)

                decodedIgnoredJobs.removeAll(where: ({$0 == jid}))

                let enc = JSONEncoder()
                let json = try enc.encode(decodedIgnoredJobs)

                project?.configuration!.ignoredJobs = String(data: json, encoding: .utf8)!

                updater.update()
            } catch {
                print("Couldn't parse ignoredJobs")
            }
        }

        PersistenceController.shared.save()
    }

    public func onAppear() -> Void {
        if let stored = self.nav.session.project {
            self.project = stored
        }

        self.allUnOwned = jm.unowned()
        self.name = project?.name ?? ""
        self.created = project?.created!

        if let company = project?.company {
            self.selectedCompany = Int(company.pid)
        }

        if self.project?.lastUpdate != nil {
            self.lastUpdate = project?.lastUpdate!
        }
        
        if let abb = project?.abbreviation {
            self.abbreviation = abb
        }

        if self.project?.jobs?.count ?? 0 > 0 {
            let existingJobs = self.project?.jobs?.allObjects as! [Job]
            selectedJobs = existingJobs.sorted(by: ({$0.jid < $1.jid}))
        }
    }

    private func selectJob(_ job: Job) -> Void {
        selectedJobs.append(job)
        allUnOwned.removeAll(where: ({$0 == job}))

        saveSelectedJobs()
        updater.update()
    }

    private func deSelectJob(_ job: Job) -> Void {
        selectedJobs.removeAll(where: ({$0 == job}))
        allUnOwned.append(job)

        saveSelectedJobs()
        updater.update()
    }

    private func selectAll() -> Void {
        for job in allUnOwned {
            selectedJobs.append(job)
            allUnOwned.removeAll(where: ({$0 == job}))
        }

        saveSelectedJobs()
    }

    private func deselectAll() -> Void {
        allUnOwned = unownedJobs
        selectedJobs = []

        saveSelectedJobs()
    }

    private func saveSelectedJobs() -> Void {
        let existingJobs = project?.jobs?.allObjects as! [Job]
        for job in existingJobs {
            project?.removeFromJobs(job)
        }
        lastUpdate = project?.lastUpdate ?? Date()

        for job in selectedJobs {
            project?.addToJobs(job)
        }

        PersistenceController.shared.save()
    }

    private func actionHardDelete() -> Void {
        if let project = self.project {
            moc.delete(project)
            PersistenceController.shared.save()
        }

        self.nav.session.project = nil
        self.nav.to(.projects)
    }
}
