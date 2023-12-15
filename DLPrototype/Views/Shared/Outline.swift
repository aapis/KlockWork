//
//  Outline.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Outline: View {
    @AppStorage("general.defaultCompany") public var defaultCompany: Int = 0

    @FetchRequest public var companies: FetchedResults<Company>
    @FetchRequest public var unowned: FetchedResults<Project>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "menucard")
                    Text("Outline view")
                }
                Divider()

                if companies.count > 0 {
                    ForEach(companies) { company in
                        Group {
                            HStack {
                                if company.isDefault {
                                    Image(systemName: "building.2")
                                }
                                FancyTextLink(text: company.name!.capitalized, destination: AnyView(CompanyView(company: company)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                                    .help("Edit company: \(company.name!.capitalized)")
                                Spacer()
                            }
                            ProjectOutline(company: company)
                        }
                    }
                } else {
                    HStack {
                        FancyTextLink(text: "No companies yet, create one!", destination: AnyView(CompanyCreate()), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                        Spacer()
                    }
                }

                if unowned.count > 0 {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Unowned Projects")
                        ForEach(unowned) { project in
                            HStack {
                                Image(systemName: "folder")
                                FancyTextLink(text: "[\(project.abbreviation != nil ? project.abbreviation!.uppercased() : "NOPE")] \(project.name!.capitalized)", destination: AnyView(ProjectView(project: project)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                                    .help("Edit project: \(project.name!.capitalized)")
                            }
                            .padding([.leading], 10)
                        }
                    }
                }
            }
            .padding(10)
        }
        .background(Theme.base.opacity(0.2))
        .onAppear(perform: actionOnAppear)
        .onChange(of: defaultCompany) { _ in
            actionOnAppear()
        }
    }
}

extension Outline {
    init(company: Company? = nil) {
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true)
        ]
        request.predicate = NSPredicate(format: "alive = true")

        _companies = FetchRequest(fetchRequest: request, animation: .easeInOut)

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true)
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = nil")

        _unowned = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }

    private func actionOnAppear() -> Void {
        if let company = CoreDataCompanies(moc: moc).byPid(defaultCompany) {
            company.isDefault = true
        }
    }
}

struct ProjectOutline: View {
    public var company: Company

    @FetchRequest public var projects: FetchedResults<Project>

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if projects.count > 0 {
                ForEach(projects) { project in
                    Row(project: project)
                }
            } else {
                Text("No projects")
                    .padding([.leading], 10)
            }
        }
    }
}

extension ProjectOutline {
    public init(company: Company) {
        self.company = company

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true)
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = %d", company.pid)

        _projects = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
}

extension ProjectOutline {
    struct Row: View {
        public var project: Project

        @State private var aboutPanelOpen: Bool = false

        var body: some View {
            HStack(alignment: .top, spacing: 5) {
                Image(systemName: "folder")
                FancyTextLink(text: "[\(project.abbreviation != nil ? project.abbreviation!.uppercased() : "NOPE")] \(project.name!.capitalized)", destination: AnyView(ProjectView(project: project)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                    .help("Edit project: \(project.name!.capitalized)")
                Spacer()
                FancyButtonv2(text: "Action", action: {aboutPanelOpen.toggle()}, icon: aboutPanelOpen ? "chevron.up.square.fill" : "chevron.down.square", showLabel: false, size: .tiny, type: .clear)
                    .useDefaultHover({_ in})
            }
            .padding([.leading], 10)

            if aboutPanelOpen {
                FancyDivider(height: 5)
            }
            AboutPanel(project: project, panelOpen: $aboutPanelOpen)
        }
    }

    struct AboutPanel: View {
        public var project: Project
        
        @Binding public var panelOpen: Bool

        @State private var jobs: Int = 0
        @State private var notes: Int = 0
        @State private var tasks: Int = 0

        var body: some View {
            VStack {
                if panelOpen {
                    panelContents
                }
            }
            .onChange(of: panelOpen) { newStatus in
                // only calculate when opening the panel
                if newStatus == true {
                    self.generateStatisticsFor(project)
                }
            }
        }
        
        @ViewBuilder var panelContents: some View {
            VStack {
                HStack(spacing: 0) {
                    HStack {
                        Image(systemName: "hammer")
                        Text(String(jobs))
                    }
                    .help("\(jobs) Jobs")
                    .padding(10)

                    HStack {
                        Image(systemName: "note.text")
                        Text(String(notes))
                    }
                    .help("\(notes) Notes")
                    .padding(10)

                    HStack {
                        Image(systemName: "checklist")
                        Text(String(tasks))
                    }
                    .help("\(tasks) Tasks")
                    .padding(10)

                    Spacer()
                }
                .frame(height: 40)
                .padding(10)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 2) {
                        FancyTextLink(text: "Show jobs", destination: AnyView(ProjectView(project: project)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                        Image(systemName: "arrow.right.square.fill")
                        Spacer()
                    }

                    HStack(spacing: 2) {
                        FancyTextLink(text: "Show notes", destination: AnyView(NoteDashboard(project: project)), pageType: .notes, sidebar: AnyView(NoteDashboardSidebar()))
                        Image(systemName: "arrow.right.square.fill")
                        Spacer()
                    }

                    HStack(spacing: 2) {
                        FancyTextLink(text: "Show tasks", destination: AnyView(TaskDashboard(project: project)), pageType: .tasks, sidebar: AnyView(TaskDashboardSidebar()))
                        Image(systemName: "arrow.right.square.fill")
                        Spacer()
                    }
                }
                .padding([.leading, .trailing, .bottom], 10)
            }
            .background(Theme.darkBtnColour)
            .padding([.leading, .trailing], -10)
            FancyDivider(height: 5)
        }
    }
}

extension ProjectOutline.AboutPanel {
    private func generateStatisticsFor(_ project: Project) -> Void {
        if let jerbs = project.jobs {
            let list = jerbs.allObjects as! [Job]
            jobs = list.count
            notes = list.map {$0.mNotes!.count}.reduce(0, +)
            tasks = list.map {$0.tasks!.count}.reduce(0, +)
        }
    }
}
