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
    @State private var abbreviation: String = ""
    @State private var created: Date? = nil
    @State private var updated: Date? = nil
    @State private var colour: Color = .clear
    @State private var hidden: Bool = false
    @State private var isDeleteAlertShowing: Bool = false
    @State private var tabs: [ToolbarButton] = []

    @FetchRequest private var projects: FetchedResults<Project>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Image(systemName: "building.2").font(Theme.fontTitle)
                    Title(text: "Editing: \(company.name!.capitalized)")
                    Spacer()
                }

                FancyTextField(placeholder: "Legal name", lineLimit: 1, onSubmit: {}, showLabel: true, text: $name)
                FancyTextField(placeholder: "Abbreviation", lineLimit: 1, onSubmit: {}, showLabel: true, text: $abbreviation)
                HStack {
                    FancyLabel(text: "Hidden")
                    FancyBoundToggle(label: "Hidden", value: $hidden, showLabel: false, onChange: self.onChangeToggle)
                }
                FancyColourPicker(initialColour: company.colour ?? Theme.rowColourAsDouble, onChange: {newColour in colour = newColour})

                if let created = created {
                    HStack {
                        FancyLabel(text: "Created")
                        HStack {
                            Text("\(DateHelper.shortDateWithTime(created))")
                                .padding()
                                .help("Not editable")
                            Spacer()
                        }
                        .background(Theme.textBackground)
                    }
                }
                
                if let updated = updated {
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
                
                FancyGenericToolbar(buttons: tabs)

                HStack {
                    FancyButtonv2(
                        text: "Delete",
                        action: {isDeleteAlertShowing = true},
                        icon: "trash",
                        showLabel: false,
                        type: .destructive
                    )
                    .alert("Are you sure you want to delete company \(company.name ?? "Invalid company name")?", isPresented: $isDeleteAlertShowing) {
                        Button("Yes", role: .destructive) {
                            actionSoftDelete()
                        }
                        Button("No", role: .cancel) {}
                    }
                    
                    Spacer()
                    FancyButtonv2(
                        text: "Save & Close",
                        action: save,
                        size: .medium,
                        redirect: AnyView(CompanyDashboard()),
                        pageType: .projects,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                }

                Spacer()

            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: name) { newName in
            abbreviation = StringHelper.abbreviate(newName)

            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.save()
            }
        }
        .onChange(of: colour) { newColour in
            self.save()
        }
    }
}

extension CompanyView {
    init(company: Company) {
        self.company = company

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true),
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company = %@", company)

        _projects = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
    
    private func actionOnAppear() -> Void {
        name = company.name!
        abbreviation = company.abbreviation!
        created = company.createdDate!
        colour = Color.fromStored(company.colour ?? Theme.rowColourAsDouble)
        hidden = company.hidden

        if let updatedAt = company.lastUpdate {
            updated = updatedAt
        }

        createToolbar()
    }

    private func save() -> Void {
        company.name = name
        company.abbreviation = abbreviation
        company.lastUpdate = Date()
        company.colour = colour.toStored()
        company.hidden = hidden

        // @TODO: possibly unnecessary, but sometimes projects disown themselves and this may fix it
        // @TODO: many months later, this did not fix it
        var projs: Set<Project> = []
        for p in projects { projs.insert(p)}
        company.projects = NSSet(set: projs)

        PersistenceController.shared.save()
    }

    private func actionSoftDelete() -> Void {
        company.alive = false
        
        if let projects = company.projects {
            let pArr = projects.allObjects as! [Project]

            for project in pArr {
                project.company = nil
            }
        }

        PersistenceController.shared.save()

        nav.setId()
        nav.setView(AnyView(CompanyDashboard()))
        nav.setParent(.companies)
        nav.setSidebar(AnyView(DefaultCompanySidebar()))
    }

    private func actionHardDelete() -> Void {
        moc.delete(company)
        PersistenceController.shared.save()

        nav.setId()
        nav.setView(AnyView(CompanyDashboard()))
        nav.setParent(.companies)
        nav.setSidebar(AnyView(DefaultCompanySidebar()))
    }

    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Manage associated projects",
                label: AnyView(
                    HStack {
                        Image(systemName: "folder")
                            .font(.title2)
                        Text("Projects")
                    }
                ),
                contents: AnyView(ManageOwnedProjects(company: company))
            ),
            ToolbarButton(
                id: 1,
                helpText: "Manage people who work for this company",
                label: AnyView(
                    HStack {
                        Image(systemName: "person.2")
                            .font(.title2)
                        Text("People")
                    }
                ),
                contents: AnyView(ManagePeople(company: company))
            )
        ]
    }

    private func onChangeToggle(value: Bool) -> Void {
        company.hidden = value
        PersistenceController.shared.save()
    }
}
