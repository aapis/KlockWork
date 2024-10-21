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
            case .folders: return "Entities as icons"
            }
        }

        var icon: String {
            switch self {
            case .folders: return "square.grid.3x3.square"
            default: return "list.bullet"
            }
        }

        var labelText: String {
            switch self {
            case .list: return "List"
            case .folders: return "Icons"
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

    enum Style {
        case plain, fullColour

        var id: Int {
            switch self {
            case .fullColour: return 1
            default: return 0
            }
        }
    }

    struct Navigator: View {
        private var buttons: [ToolbarButton] = []

        var body: some View {
            FancyGenericToolbar(
                buttons: buttons,
                standalone: true,
                location: .content,
                mode: .compact,
                page: .explore
            )
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
        @AppStorage("widget.navigator.altViewModeEnabled") private var altViewModeEnabled: Bool = true
        @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
        @AppStorage("widget.navigator.sortModifiedOrder") private var navigatorSortModifiedOrder: Bool = false
        @AppStorage("widget.navigator.sortCreatedOrder") private var navigatorSortCreatedOrder: Bool = false
        @State private var companies: [Company] = []
        public let location: WidgetLocation = .content

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    UI.Toggle("Published", isOn: $showPublished, icon: "checkmark.square", selectedIcon: "checkmark.square.fill")
                        .help("Show or hide unpublished items")
                        .padding(3)
                        .background(Theme.textBackground)
                        .clipShape(.rect(cornerRadius: 5))

                    UI.Toggle("Full Colour", isOn: $altViewModeEnabled, icon: "checkmark.square", selectedIcon: "checkmark.square.fill")
                        .help("Navigator becomes colourful")
                        .padding(3)
                        .background(Theme.textBackground)
                        .clipShape(.rect(cornerRadius: 5))
                    Spacer()
                }
                .padding(8)
                .background(self.state.session.appPage.primaryColour)

                HStack {
                    Text("Name")
                    Spacer()
                    Button {
                        self.navigatorSortModifiedOrder.toggle()
                    } label: {
                        Text("Modified")
                    }
                    .buttonStyle(.plain)
                    Button {
                        self.navigatorSortCreatedOrder.toggle()
                    } label: {
                        Text("Created")
                    }
                    .buttonStyle(.plain)
                }
                .font(.caption)
                .padding(4)
                Divider()

                if self.companies.count(where: {$0.alive == true}) > 0 {
                    ForEach(self.companies, id: \.objectID) { company in
                        Row(entity: company)
                    }

//                    HStack {
//                        Text("\(self.companies.count) Companies")
//                            .font(.caption)
//                    }
//                    .padding(4)
                } else {
                    FancyHelpText(text: "Create a company first.")
                }
            }
            .background(Theme.textBackground)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.showPublished) { self.actionOnAppear() }
            .onChange(of: self.state.session.gif) { self.actionOnAppear() }
            .onChange(of: self.altViewModeEnabled) {
                if self.altViewModeEnabled {
                    self.viewModeIndex = 1
                } else {
                    self.viewModeIndex = 0
                }
            }
        }

        struct Row: View {
            typealias UI = WidgetLibrary.UI
            @EnvironmentObject private var state: Navigation
            @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            @AppStorage("widget.navigator.sortModifiedOrder") private var navigatorSortModifiedOrder: Bool = false
            @AppStorage("widget.navigator.sortCreatedOrder") private var navigatorSortCreatedOrder: Bool = false
            public let entity: NSManagedObject
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
                        self.ButtonContent
                    }
                    .buttonStyle(.plain)

                    if self.isPresented {
                        if self.children != nil && self.children?.count ?? 0 > 0 {
                            ForEach(self.children!, id: \.objectID) { child in
                                if self.state.session.gif == .focus {
                                    switch self.entity {
                                    case is Company:
                                        if self.state.planning.companies.contains(child as! Company) {
                                            Row(entity: child)
                                        }
                                    case is Project:
                                        if self.state.planning.projects.contains(child as! Project) {
                                            Row(entity: child)
                                        }
                                    case is Job:
                                        if self.state.planning.jobs.contains(child as! Job) {
                                            Row(entity: child)
                                        }
                                    default: EmptyView()
                                    }
                                } else {
                                    Row(entity: child)
                                }
                            }
                            .padding(.leading)
                        }

                        if self.relatedEntities.count > 0 {
                            ForEach(self.relatedEntities, id: \.self) { entity in
                                if self.state.session.company != nil {
                                    switch entity {
                                    case .people: US.People(entity: self.state.session.company!)
                                    default: EmptyView()
                                    }
                                }

                                if self.state.session.job != nil {
                                    switch entity {
                                    case .tasks: US.Tasks(job: self.state.session.job!, tasks: [])
                                    case .records: US.Records(job: self.state.session.job!, records: [])
                                    case .notes: US.Notes(job: self.state.session.job!, notes: [])
                                    case .definitions: US.Definitions(job: self.state.session.job!, definitions: [])
                                    default: EmptyView()
                                    }
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.viewModeIndex) { self.actionOnAppear() }
                .onChange(of: self.showPublished) { self.actionOnAppear() }
//                .onChange(of: self.navigatorSortCreatedOrder) { self.actionOnAppear() }
//                .onChange(of: self.navigatorSortModifiedOrder) { self.actionOnAppear() }
            }

            var ButtonContent: some View {
                HStack {
                    ZStack(alignment: .center) {
                        if self.isPresented {
                            Theme.base.opacity(0.6).blendMode(.softLight)
                        }
                        Image(systemName: self.isPresented ? "minus" : self.isHighlighted ? "folder.fill" : "folder")
                            // @TODO: create a ShapeStyle for this
                            .foregroundStyle(self.isPresented ? .white : self.viewModeIndex == 1 ? self.colour.isBright() ? Theme.base : .white : self.colour)
                    }
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)

                    Text(self.label)
                        .multilineTextAlignment(.leading)
                        // @TODO: create a ShapeStyle for this
                        .foregroundStyle(
                            self.isPresented ? .white : self.isHighlighted ? .white : self.viewModeIndex == 1 ? self.colour.isBright() ? Theme.base : .white : .white
                        )
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
                .background(
                    self.viewModeIndex == 1 ? self.isHighlighted ? self.colour.opacity(0.9) : self.colour : Color.white.opacity(self.isPresented ? 0.3 : self.isHighlighted ? 0.3 : 0.1)
                )
                .useDefaultHover({ hover in self.isHighlighted = hover })
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
            let projects = (company.projects?.allObjects as? [Project] ?? [])
                .sorted(by: {
                    if self.navigatorSortCreatedOrder {
                        return $0.created ?? Date.now > $1.created ?? Date.now
                    } else {
                        return $0.lastUpdate ?? Date.now > $1.lastUpdate ?? Date.now
                    }
                })
            self.label = company.name ?? "Error: Invalid company name"
            self.children = projects
            if self.showPublished {
                self.children = projects
                    .filter({$0.alive == true})
            }
            self.lastModified = company.lastUpdate
            self.created = company.createdDate
            self.colour = company.alive ? company.backgroundColor : .gray.opacity(0.7)
            self.relatedEntities = [.people]
            self.isPresented = company == self.state.session.company
        case is Project:
            let project = self.entity as! Project
            let jobs = (project.jobs?.allObjects as? [Job] ?? [])
                .sorted(by: {$0.lastUpdate ?? Date.now > $1.lastUpdate ?? Date.now})
            self.label = project.name ?? "Error: Invalid project name"
            self.children = jobs
            if self.showPublished {
                self.children = jobs
                    .filter({$0.alive == true})
            }
            self.lastModified = project.lastUpdate
            self.created = project.created
            self.colour = project.alive ? project.backgroundColor : .gray.opacity(0.7)
            self.isPresented = project == self.state.session.project
        case is Job:
            let job = self.entity as! Job
            self.label = job.title ?? job.jid.string
            self.children = []
            self.lastModified = job.lastUpdate
            self.created = job.created
            self.colour = job.alive ? job.backgroundColor : .gray.opacity(0.7)
            self.relatedEntities = [.tasks, .records, .notes, .definitions]
            self.isPresented = job == self.state.session.job
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
            self.state.session.company = nil
            let company = self.entity as! Company
            self.state.session.company = company
            self.state.session.project = nil
            self.state.session.job = nil
        case is Project:
            self.state.session.project = nil
            let project = self.entity as! Project
            self.state.session.project = project
            self.state.session.job = nil
        case is Job:
            self.state.session.job = nil
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
