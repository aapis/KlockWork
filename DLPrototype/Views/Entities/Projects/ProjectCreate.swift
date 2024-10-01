//
//  ProjectCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectCreate: View {
    @State private var name: String = ""
    @State private var created: Date = Date()
    @State private var pid: Double = 0.0
    @State private var selectedJob: Job?
    @State private var selectedJobs: [Job] = []
    @State private var allUnOwned: [Job] = []
    @State private var selectAllToggle: Bool = false
    @State private var colour: Color = Color.clear
    @State private var selectedCompany: Int = 0

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)

    private var unownedJobs: [Job] {
        jm.unowned()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Create a project")
                    Spacer()
                }

                form

                HStack {
                    Spacer()
                    FancyButtonv2(
                        text: "Create project",
                        action: create,
                        size: .medium,
                        redirect: AnyView(ProjectsDashboard()),
                        pageType: .projects,
                        sidebar: AnyView(ProjectsDashboardSidebar())
                    )
                }
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .font(Theme.font)
        .onAppear(perform: onAppear)
        .onChange(of: selectAllToggle) { _ in
            if selectAllToggle == true {
                selectAll()
            } else {
                deselectAll()
            }
        }
    }
    
    @ViewBuilder
    var form: some View {
        FancyTextField(placeholder: "Project name", lineLimit: 1, onSubmit: {}, showLabel: true, text: $name)
        CompanyPicker(onChange: {company,_ in selectedCompany = company})
        FancyDivider()
        
        HStack {
            Text("Associate unowned jobs to this project")
                .font(Theme.font)
            Spacer()
            Text("\(selectedJobs.count)/\(unownedJobs.count) selected")
            Toggle("All?", isOn: $selectAllToggle)
        }
        
        ScrollView(showsIndicators: false) {
            Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    Group {
                        ZStack {
                            Theme.headerColour
                        }
                        
                    }
                    .frame(width: 60)
                    
                    Group {
                        ZStack(alignment: .leading) {
                            Theme.headerColour
                            Text("JID")
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
            
                ForEach(allUnOwned, id: \.objectID) { job in
                    GridRow {
                        Group {
                            ZStack {
                                Theme.rowColour
                                FancyButtonv2(text: "Associate job", action: {selectJob(job)}, icon: "plus", showLabel: false, size: .tiny, type: .clear)
                            }
                        }
                        .frame(width: 60)
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.rowColour
                                FancyLink(
                                    label: job.jid.string,
                                    showLabel: true,
                                    destination: AnyView(JobDashboard(defaultSelectedJob: job)),
                                    size: .link,
                                    pageType: .jobs,
                                    sidebar: AnyView(JobDashboardSidebar())
                                )
                                .padding(5)
                            }
                        }
                        
                        Group {
                            ZStack {
                                let colour = Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                                colour
                                Text(colour.description.debugDescription)
                                    .padding(5)
                                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func onAppear() -> Void {
        allUnOwned = jm.unowned()
    }
    
    private func create() -> Void {
        let project = Project(context: moc)
        project.pid = Int64.random(in: 1..<1000000000000001)
        project.name = name
        project.alive = true
        project.created = Date()
        project.id = UUID()
        project.colour = Color.randomStorable()

        if selectedCompany > 0 {
            project.company = CoreDataCompanies(moc: moc).byPid(selectedCompany)
        } else {
            project.company = CoreDataCompanies(moc: moc).findDefault()
        }

        for job in selectedJobs {
            project.addToJobs(job)
        }
        
        let configuration = ProjectConfiguration(context: moc)
        configuration.ignoredJobs = ""
        configuration.bannedWords = nil
        configuration.id = UUID()
        configuration.projects = NSSet(array: [project])
        configuration.exportFormat = UUID() // TODO: for future use
        
        PersistenceController.shared.save()
        
        name = ""
        selectedJobs = []
    }
    
    private func selectJob(_ job: Job) -> Void {
        selectedJobs.append(job)
        allUnOwned.removeAll(where: ({$0 == job}))
    }
    
    private func selectAll() -> Void {
        for job in allUnOwned {
            selectedJobs.append(job)
            allUnOwned.removeAll(where: ({$0 == job}))
        }
    }
    
    private func deselectAll() -> Void {
        allUnOwned = unownedJobs
        selectedJobs = []
    }
}
