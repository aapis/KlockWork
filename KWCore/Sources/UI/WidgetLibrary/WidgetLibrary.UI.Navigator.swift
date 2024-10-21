//
//  WidgetLibrary.UI.Navigator.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-20.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    enum Mode: CaseIterable {
        case list, folders

        var id: Int {
            switch self {
            case .folders: return 1
            default: return 0
            }
        }

        var helpText: String {
            switch self {
            case .list: return "Entities as a list"
            case .folders: return "Entities as files and folders"
            }
        }

        var icon: String {
            switch self {
            case .folders: return "folder"
            default: return "list.bullet.indent"
            }
        }

        var labelText: String {
            switch self {
            case .list: return "List"
            case .folders: return "Files & Folders"
            }
        }

        var view: AnyView {
            switch self {
            case .folders: return AnyView(Navigator.Folders())
            default: return AnyView(Navigator.List())
            }
        }

        var button: ToolbarButton {
            ToolbarButton(
                id: self.id,
                helpText: self.helpText,
                icon: self.icon,
                labelText: self.labelText,
                contents: self.view
            )
        }
    }

    struct Navigator: View {
        private var buttons: [ToolbarButton] = []

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                FancyGenericToolbar(
                    buttons: buttons,
                    standalone: true,
                    location: .content,
                    mode: .compact
                )
            }
            .padding()
            .background(Theme.toolbarColour)
        }

        init() {
            Mode.allCases.forEach { tab in
                buttons.append(tab.button)
            }
        }
    }
}

extension WidgetLibrary.UI.Navigator {
    struct List: View {
        typealias UI = WidgetLibrary.UI
        typealias US = UI.UnifiedSidebar
        @EnvironmentObject private var state: Navigation
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true
        @State private var companies: [Company] = []

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("Modified")
                    Text("Created")
                }
                .font(.caption)
                .padding(4)
                Divider()

                if self.companies.count(where: {$0.alive == true}) > 0 {
                    ForEach(self.companies, id: \.objectID) { company in
                        Row(entity: company)
                    }
                } else {
                    FancyHelpText(text: "Create a company first.")
                }
            }
            .background(Theme.textBackground)
            .onAppear(perform: self.actionOnAppear)
        }

        struct Row: View {
            typealias UI = WidgetLibrary.UI
            @EnvironmentObject private var state: Navigation
            public let entity: NSManagedObject
            public let stripe: Bool = false
            @State private var label: String = ""
            @State private var lastModified: Date? = nil
            @State private var created: Date? = nil
            @State private var children: [NSManagedObject]? = nil
            @State private var colour: Color = .white
            @State private var relatedEntities: [PageConfiguration.EntityType] = []
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    Button {
                        self.actionOnTap()
                        self.isPresented.toggle()
                    } label: {
                        HStack {
                            ZStack(alignment: .center) {
                                if self.isPresented {
                                    Theme.base.opacity(0.6).blendMode(.softLight)
                                }
                                Image(systemName: self.isPresented ? "minus" : self.isHighlighted ? "folder.fill" : "folder")
                                    .foregroundStyle(self.isPresented ? .white : self.colour)
                            }
                            .frame(width: 30, height: 30)
                            .cornerRadius(5)

                            Text(self.label)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(self.isPresented ? .white : self.isHighlighted ? .white : Theme.lightWhite)
                            Spacer()

                            HStack {
                                if let modifiedDate = self.lastModified {
                                    Text(modifiedDate.formatted())
                                }

                                if let createdDate = self.created {
                                    Text(createdDate.formatted())
                                }
                            }
                            .foregroundStyle(.gray)
                        }
                        .padding(8)
                        .background(.gray.opacity(self.isPresented ? 0.3 : self.isHighlighted ? 0.3 : 0.1))
                        .useDefaultHover({ hover in self.isHighlighted = hover })
                    }
                    .buttonStyle(.plain)
                    .onAppear(perform: self.actionOnAppear)

                    if self.isPresented {
                        if self.children != nil && self.children?.count ?? 0 > 0 {
                            ForEach(self.children!, id: \.objectID) { child in
                                Row(entity: child)
                            }
                            .padding(.leading)
                        }

                        if self.relatedEntities.count > 0 {
                            ForEach(self.relatedEntities, id: \.self) { entity in
                                switch entity {
                                case .people: US.People(entity: self.state.session.company!)
                                case .tasks: US.Tasks(job: self.state.session.job!, tasks: [])
                                case .records: US.Records(job: self.state.session.job!, records: [])
                                case .notes: US.Notes(job: self.state.session.job!, notes: [])
                                case .definitions: US.Definitions(job: self.state.session.job!, definitions: [])
                                default: EmptyView()
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
        }
    }

    struct Folders: View {
        var body: some View {
            Text("Folder view to come")
        }
    }
}

extension WidgetLibrary.UI.Navigator.List {
    /// Onload handler. Finds companies
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.companies = CoreDataCompanies(moc: self.state.moc).all(
            allowKilled: self.showPublished,
            allowPlanMembersOnly: self.state.session.gif == .focus,
            planMembers: self.state.planning.companies
        )
    }
}

extension WidgetLibrary.UI.Navigator.List.Row {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        switch self.entity {
        case is Company:
            let company = self.entity as! Company
            self.label = company.name ?? "Error: Invalid company name"
            self.children = (company.projects?.allObjects as? [Project] ?? []).sorted(by: {$0.lastUpdate ?? Date.now > $1.lastUpdate ?? Date.now})
            self.lastModified = company.lastUpdate
            self.created = company.createdDate
            self.colour = company.backgroundColor
            self.relatedEntities = [.people]
        case is Project:
            let project = self.entity as! Project
            self.label = project.name ?? "Error: Invalid project name"
            self.children = (project.jobs?.allObjects as? [Job] ?? []).sorted(by: {$0.lastUpdate ?? Date.now > $1.lastUpdate ?? Date.now})
            self.lastModified = project.lastUpdate
            self.created = project.created
            self.colour = project.backgroundColor
        case is Job:
            let job = self.entity as! Job
            self.label = job.title ?? job.jid.string
            self.children = []
            self.lastModified = job.lastUpdate
            self.created = job.created
            self.colour = job.backgroundColor
            self.relatedEntities = [.tasks, .records, .notes, .definitions]
        default:
            self.label = "Error: Invalid company name"
            self.children = []
        }
    }

    /// Fires when a row is tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        switch self.entity {
        case is Company:
            let company = self.entity as! Company
            self.state.session.company = company
            self.state.session.project = nil
            self.state.session.job = nil
        case is Project:
            let project = self.entity as! Project
            self.state.session.project = project
            self.state.session.job = nil
        case is Job:
            let job = self.entity as! Job
            self.state.session.setJob(job)
        default:
            print("noop")
        }
    }
}


extension WidgetLibrary.UI.Navigator.Folders {
    /// Onload handler. Finds companies
    /// - Returns: Void
    private func actionOnAppear() -> Void {
//        self.companies = CoreDataCompanies(moc: self.state.moc).all(
//            allowKilled: self.showPublished,
//            allowPlanMembersOnly: self.state.session.gif == .focus,
//            planMembers: self.state.planning.companies
//        )
    }
}
