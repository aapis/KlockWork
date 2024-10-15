//
//  CompanyView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct CompanyView: View {
    @EnvironmentObject public var nav: Navigation
    @State private var id: UUID = UUID()
    @State public var company: Company?
    @State private var name: String = ""
    @State private var abbreviation: String = ""
    @State private var created: Date? = nil
    @State private var updated: Date? = nil
    @State private var colour: Color?
    @State private var hidden: Bool = false
    @State private var alive: Bool = false
    @State private var isDefault: Bool = false
    @State private var isDeleteAlertShowing: Bool = false
    @State private var tabs: [ToolbarButton] = []
    @State private var projects: [Project] = []
    @State private var isChangingCompanies: Bool = false
    private let eType: PageConfiguration.EntityType = .companies

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                Title(text: self.name, imageAsImage: self.eType.icon)
                FancyTextField(placeholder: "Legal name", lineLimit: 1, onSubmit: {}, showLabel: true, text: $name)
                FancyTextField(placeholder: "Abbreviation", lineLimit: 1, onSubmit: {}, showLabel: true, text: $abbreviation)
                HStack {
                    FancyLabel(text: "Hidden")
                    FancyBoundToggle(label: "Hidden", value: $hidden, showLabel: false, onChange: self.onChangeToggle)
                }
                HStack {
                    FancyLabel(text: "Published")
                    FancyBoundToggle(label: "Published", value: $alive, showLabel: false, onChange: self.onChangePublishStatus)
                }
                HStack {
                    FancyLabel(text: "Default?")
                    FancyBoundToggle(label: "Default", value: $isDefault, showLabel: false, onChange: self.onChangeDefaultStatus)
                }
                FancyColourPicker(initialColour: self.colour ?? self.nav.session.company?.backgroundColor ?? .clear, onChange: {newColour in self.colour = newColour})

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
                    .alert("Are you sure you want to delete company \(company?.name ?? "Invalid company name")?", isPresented: $isDeleteAlertShowing) {
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
        .id(self.id)
        .background(self.nav.parent?.appPage.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.nav.session.company) { self.actionAttemptCompanyChange() }
//        .onChange(of: self.name) {
//            abbreviation = StringHelper.abbreviate(self.name)
//
//            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
//                self.save()
//            }
//        }
//        .onChange(of: colour) {
//            self.save()
//        }
        .alert("Change companies? You're currently editing one.", isPresented: $isChangingCompanies, actions: {
            Button("Cancel", role: .cancel) {
                self.isChangingCompanies = false
            }
            Button("Yes", role: .destructive) {
                self.isChangingCompanies = false
                self.id = UUID()
                self.actionOnAppear()
            }
        })
    }
}

extension CompanyView {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.nav.session.company {
            self.company = stored
        } else if let stored = self.nav.session.project {
            self.company = stored.company
        }

        self.projects = []
        if let projects = self.company?.projects?.allObjects as? [Project] {
            if projects.count > 0 {
                self.projects = projects.filter({$0.alive == true})
            }
        }

        self.name = self.company?.name ?? ""
        self.abbreviation = self.company?.abbreviation ?? ""
        self.created = self.company?.createdDate ?? Date()
        self.colour = self.company?.backgroundColor ?? .clear
        self.hidden = self.company?.hidden ?? false
        self.alive = self.company?.alive ?? false
        self.isDefault = self.company?.isDefault ?? false

        if let updatedAt = self.company?.lastUpdate {
            self.updated = updatedAt
        }

        self.createToolbar()
    }

    private func save() -> Void {
        if self.company != nil {
            self.company!.name = name
            self.company!.abbreviation = abbreviation
            self.company!.lastUpdate = Date()
            if self.colour != nil { self.company!.colour = self.colour!.toStored() }
            // Note: we don't set the boolean fields here because they are set on change

            // @TODO: possibly unnecessary, but sometimes projects disown themselves and this may fix it
            // @TODO: many months later, this did not fix it
            var projs: Set<Project> = []
            for p in self.projects { projs.insert(p)}
            self.company!.projects = NSSet(set: projs)
        }

        PersistenceController.shared.save()
    }

    private func actionSoftDelete() -> Void {
        self.company?.alive = false

        if let projects = self.company?.projects {
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
        if let company = self.company {
            self.nav.moc.delete(company)
        }

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
                contents: AnyView(ManageOwnedProjects())
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
                contents: AnyView(ManagePeople())
            )
        ]
    }

    private func onChangeToggle(value: Bool) -> Void {
        self.company?.hidden = value
        PersistenceController.shared.save()
    }
    
    /// Publish or unpublish a company
    /// - Parameter value: Bool
    /// - Returns: Void
    private func onChangePublishStatus(value: Bool) -> Void {
        self.company?.alive = value
        PersistenceController.shared.save()
    }

    /// Set or unset company as default
    /// - Parameter value: Bool
    /// - Returns: Void
    private func onChangeDefaultStatus(value: Bool) -> Void {
        self.company?.isDefault = value
        PersistenceController.shared.save()
    }


    /// Fires when company changes while editing
    /// - Returns: Void
    private func actionAttemptCompanyChange() -> Void {
        if self.company != self.nav.session.company && self.nav.session.company != nil {
            self.isChangingCompanies = true
        }
    }
}
