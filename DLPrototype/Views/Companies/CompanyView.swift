//
//  CompanyView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyView: View {
    public var company: Company

    @State private var name: String = ""
    @State private var colour: String = ""
    @State private var colourChanged: Bool = false
    @State private var created: Date?
    @State private var lastUpdate: Date?
    @State private var alive: Bool = true
    @State private var assigned: [Project] = []
    @State private var unassignedProjects: [Project] = []
    @State private var selectAllToggleAssociated: Bool = false
    @State private var selectAllToggleUnassociated: Bool = false
    // toolbar
    @State private var isShowingAlert: Bool = false
    @State private var buttons: [ToolbarButton] = []

    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var pm: CoreDataProjects
    @EnvironmentObject public var cdc: CoreDataCompanies

    private var all: [Project] {
        cdc.all()
    }

    private var unownedJobs: [Project] {
        let unowned = cdc.unowned()

        
    }
    
    var body2: some View {
//        VStack(alignment: .leading) {
//            VStack(alignment: .leading, spacing: 13) {
//                TopBar
//
//                HStack(alignment: .top, spacing: 5) {
//                    VStack(alignment: .leading) {
//                        FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, disabled: revisionNotLatest(), text: $title)
//                        FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, disabled: revisionNotLatest(), text: $content)
//                            .scrollIndicators(.never)
//                    }
//
//                    if sidebarVisible {
//                        SideBar
//                    }
//                }
//
//                HelpBar
//            }
//            .padding()
//        }
//        .background(Theme.toolbarColour)
//        .onAppear(perform: {createBindings(note: note)})
//        .onChange(of: note, perform: createBindings)
        Text("Hello")
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Edit a company", image: "person.2")
                    Spacer()

                    if lastUpdate != nil {
                        Text("Last updated: \(DateHelper.shortDateWithTime(lastUpdate!))")
                            .font(Theme.font)
                            .onChange(of: company.lastUpdate) { _ in
                                lastUpdate = company.lastUpdate
                            }
                    }
                }

                HStack {
                    Toggle("Project is active", isOn: $alive)
                        .onAppear(perform: {
                            if company.alive {
                                alive = true
                            } else {
                                alive = false
                            }

                            company.alive = alive

                            PersistenceController.shared.save()
                        })
                }

                form.id(updater.ids["pv.form"])

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
        FancyTextField(placeholder: "Project name", lineLimit: 1, onSubmit: update, text: $name)
        FancyDivider()

        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 15)
                .background(Color.fromStored(company.colour ?? Theme.rowColourAsDouble))
                .foregroundColor(.clear)

            FancyTextField(
                placeholder: "Colour",
                lineLimit: 1,
                onSubmit: {},
                disabled: true,
                bgColour: Color.clear,
                text: $colour
            )
            .border(Color.black.opacity(0.1), width: 2)
            .frame(width: 200)
            .onAppear(perform: {
                colour = Color.fromStored(company.colour ?? Theme.rowColourAsDouble).description.debugDescription
            })

            FancyButton(text: "Regenerate colour", action: regenerateColour, icon: "arrow.counterclockwise", showLabel: false)
                .padding(.leading)
        }.frame(height: 40)

        FancyDivider()

        toolbar
    }

    @ViewBuilder private var toolbar: some View {
        FancyGenericToolbar(buttons: buttons)
            .onAppear(perform: createToolbar)
    }

    private func regenerateColour() -> Void {
        let rndColour = Color.randomStorable()
        colour = Color.fromStored(rndColour).description.debugDescription
        company.colour = rndColour
        colourChanged = true

        PersistenceController.shared.save()
        updater.update()
    }

    private func createToolbar() -> Void {
        // TODO: apply this pattern to Today view
        buttons = [
            ToolbarButton(
                id: 0,
                helpText: "Assign jobs to the project",
                label: AnyView(Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")),
                contents: AnyView(EmptyView())
            )
        ]
    }

    private func update() -> Void {
        company.name = name
        company.alive = alive
        company.lastUpdate = Date()

        if colourChanged {
            company.colour = Color.randomStorable()
        }

        lastUpdate = company.lastUpdate!

        saveSelected()

        PersistenceController.shared.save()
    }

    public func onAppear() -> Void {
        unassignedProjects = pm.unowned()
        name = company.name!
        created = company.createdDate!
        print("DERPO company \(company)")

        if company.lastUpdate != nil {
            lastUpdate = company.lastUpdate!
        }

        if let projects = company.projects {
            if projects.count > 0 {
                let existingJobs = projects.allObjects as! [Project]
                assigned = existingJobs.sorted(by: ({$0.name! < $1.name!}))
            }
        }
    }

    private func select(_ item: Project) -> Void {
        assigned.append(item)
        unassignedProjects.removeAll(where: ({$0 == item}))

        saveSelected()
        updater.update()
    }

    private func deSelect(_ item: Project) -> Void {
        assigned.removeAll(where: ({$0 == item}))
        unassignedProjects.append(item)

        saveSelected()
        updater.update()
    }

    private func selectAll() -> Void {
        for job in unassignedProjects {
            assigned.append(job)
            unassignedProjects.removeAll(where: ({$0 == job}))
        }

        saveSelected()
    }

    private func deselectAll() -> Void {
        unassignedProjects = unownedJobs
        assigned = []

        saveSelected()
    }

    private func saveSelected() -> Void {
        let existingJobs = company.projects?.allObjects as! [Project]
//        for job in existingJobs {
//            project.removeFromJobs(job)
//        }
//        lastUpdate = company.lastUpdate ?? Date()
//
//        for job in assigned {
//            project.addToJobs(job)
//        }

        PersistenceController.shared.save()
    }

}

//struct CompanyView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompanyView()
//    }
//}
