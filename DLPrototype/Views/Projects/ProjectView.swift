//
//  ProjectView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectView: View {
    public var project: Project
    
    @State private var name: String = ""
    @State private var created: Date?
    @State private var lastUpdate: Date?
    @State private var alive: Bool = true
    @State private var selectedJob: Job?
    @State private var selectedJobs: [Job] = []
    @State private var allUnOwned: [Job] = []
    @State private var selectAllToggleAssociated: Bool = false
    @State private var selectAllToggleUnassociated: Bool = false
    // for Toolbar
    @State private var selectedTab: Int = 0
    @State private var isShowingAlert: Bool = false
    @State private var buttons: [ToolbarButton] = []
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    private var all: [Job] {
        CoreDataJob(moc: moc).all()
    }
    
    private var unownedJobs: [Job] {
        CoreDataJob(moc: moc).unowned()
    }
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Edit a project", image: "folder")
                    Spacer()
                    
                    if lastUpdate != nil {
                        Text("Last updated: \(DateHelper.shortDateWithTime(lastUpdate!))")
                            .font(Theme.font)
                    }
                }
                
                HStack {
                    Toggle("Project is active", isOn: $alive)
                        .onAppear(perform: {
                            if project.alive {
                                alive = true
                            } else {
                                alive = false
                            }
                        })
                }
                
                form

                HStack {
                    Spacer()
                    FancyButton(text: "Update project", action: update)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .font(Theme.font)
        .onAppear(perform: onAppear)
        .onChange(of: selectAllToggleAssociated) { _ in
            if selectAllToggleAssociated == true {
                selectAll()
            } else {
                deselectAll()
            }
        }
        .onChange(of: selectAllToggleUnassociated) { _ in
            if selectAllToggleUnassociated == true {
                selectAll()
            } else {
                deselectAll()
            }
        }
    }
    
    // MARK: form view
    @ViewBuilder
    var form: some View {
        FancyTextField(placeholder: "Project name", lineLimit: 1, onSubmit: {}, text: $name)
        FancyDivider()
        
        toolbar
    }
    
    // MARK: jobAssignment view, job tab view
    @ViewBuilder
    var jobAssignment: some View {
        associatedJobs
        unOwnedJobs
    }
    
    // MARK: toolbar view
    @ViewBuilder
    var toolbar: some View {
        FancyGenericToolbar(buttons: buttons)
            .onAppear(perform: createToolbar)
    }
    
    // MARK: associated jobs view
    @ViewBuilder
    var associatedJobs: some View {
        HStack {
            Text("Jobs associated to this project")
                .font(Theme.font)
            Spacer()
            Text("\(selectedJobs.count)/\(all.count) selected")
            Toggle("All?", isOn: $selectAllToggleAssociated)
        }
        
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    Group {
                        ZStack {
                            Theme.headerColour
                        }
                        
                    }
                    .frame(width: 80)
                    
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
            
                ForEach(selectedJobs, id: \.jid) { job in
                    GridRow {
                        Group {
                            ZStack {
                                Theme.rowColour
                                Button(action: {deSelectJob(job)}) {
                                    Text("Remove")
                                }
                            }
                        }
                        .frame(width: 80)
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.rowColour
                                Text(job.jid.string)
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
    
    // MARK: unowned jobs view
    @ViewBuilder
    var unOwnedJobs: some View {
        HStack {
            Text("Unowned jobs (no project association)")
                .font(Theme.font)
            Spacer()
            Text("\(allUnOwned.count)/\(all.count) selected")
            Toggle("All?", isOn: $selectAllToggleUnassociated)
        }
        
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    Group {
                        ZStack {
                            Theme.headerColour
                        }
                        
                    }
                    .frame(width: 80)
                    
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
            
                ForEach(allUnOwned, id: \.jid) { job in
                    GridRow {
                        Group {
                            ZStack {
                                Theme.rowColour
                                Button(action: {selectJob(job)}) {
                                    Text("Add")
                                }
                            }
                        }
                        .frame(width: 80)
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.rowColour
                                Text(job.jid.string)
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
    
    private func createToolbar() -> Void {
        // TODO: apply this pattern to Today view
        buttons = [
            ToolbarButton(id: 0, helpText: "Assign jobs to the project", label: AnyView(Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")), contents: AnyView(jobAssignment)),
            ToolbarButton(id: 1, helpText: "Create/assign configurations to the project", label: AnyView(Image(systemName: "circles.hexagongrid.fill")))
        ]
    }
    
    private func update() -> Void {
        project.name = name
        project.jobs = []
        project.alive = alive
        project.lastUpdate = Date()
        lastUpdate = project.lastUpdate!
        
        for job in selectedJobs {
            project.addToJobs(job)
        }
        
        PersistenceController.shared.save()
    }
    
    public func onAppear() -> Void {
        allUnOwned = CoreDataJob(moc: moc).unowned()
        name = project.name!
        created = project.created!
        
        if project.lastUpdate != nil {
            lastUpdate = project.lastUpdate!
        }
        
        if project.jobs!.count > 0 {
            let existingJobs = project.jobs?.allObjects as! [Job]
            selectedJobs = existingJobs.sorted(by: ({$0.jid < $1.jid}))
        }
    }
    
    private func selectJob(_ job: Job) -> Void {
        selectedJobs.append(job)
        allUnOwned.removeAll(where: ({$0 == job}))
    }
    
    private func deSelectJob(_ job: Job) -> Void {
        selectedJobs.removeAll(where: ({$0 == job}))
        allUnOwned.append(job)
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
