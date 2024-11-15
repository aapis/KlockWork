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
            case .folders: return AnyView(Navigator.List(type: .folders))
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
        public var location: WidgetLocation = .content
        private var buttons: [ToolbarButton] = []

        var body: some View {
            FancyGenericToolbar(
                buttons: buttons,
                standalone: true,
                location: self.location,
                mode: .compact,
                page: .explore
            )
        }

        init(location: WidgetLocation = .content) {
            self.location = location
            // @TODO: temp removing folders so it can be finished or removed later
            Mode.allCases.filter({$0 != .folders}).forEach { tab in
                buttons.append(tab.button)
            }
        }
    }
}

extension WidgetLibrary.UI.Navigator {
    // @TODO: merge Folders and List
    struct List: View {
        typealias US = UI.UnifiedSidebar
        @EnvironmentObject private var state: Navigation
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true
        @AppStorage("widget.navigator.altViewModeEnabled") private var altViewModeEnabled: Bool = true
        @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
        @AppStorage("widget.navigator.sortModifiedOrder") private var navigatorSortModifiedOrder: Bool = false
        @AppStorage("widget.navigator.sortCreatedOrder") private var navigatorSortCreatedOrder: Bool = false
        @AppStorage("widget.navigator.depth") private var depth: Int = 0
        public var type: UI.Mode = .list
        @State private var companies: [Company] = []
        @State private var projects: [Project] = []
        @State private var jobs: [Job] = []
        @State private var newProjectName: String = ""
        @State private var id: UUID = UUID()
        public var location: WidgetLocation = .content // @TODO: need to be able to set this in Mode.view, somehow
        private var columns: [GridItem] {
            return Array(repeating: .init(.flexible(minimum: 100)), count: 6)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                    self.ListHeader
                    UI.ResourcePath(
                        company: self.state.session.company,
                        project: self.state.session.project,
                        job: self.state.session.job,
                        showRoot: true
                    )
                    self.ListLegend
                }

                if self.companies.count(where: {$0.alive == true}) > 0 {
                    if self.type == .folders {
                        LazyVGrid(columns: self.columns, alignment: .leading) {
                            ForEach(self.companies, id: \.objectID) { company in
                                Folder(entity: company)
                            }
//                            switch self.depth {
//                            case 0:
//                                if self.companies.count  > 0 {
//                                    ForEach(self.companies, id: \.objectID) { company in
//                                        Folder(entity: company)
//                                    }
//                                }
//                            case 1:
//                                if self.projects.count > 0 {
//                                    ForEach(self.projects, id: \.objectID) { project in
//                                        Folder(entity: project)
//                                    }
//                                }
//                            case 2:
//                                if self.jobs.count > 0 {
//                                    ForEach(self.jobs, id: \.objectID) { job in
//                                        Folder(entity: job)
//                                    }
//                                }
//                            default: EmptyView()
//                            }
                        }
                        .frame(maxWidth: 800)
                        .padding()
                    } else {
                        ForEach(self.companies, id: \.objectID) { company in
                            Row(entity: company, location: self.location)
                        }
                    }
                } else {
                    FancyHelpText(text: "Create a company first.")
                }
            }
            .id(self.id)
            .background(
                ZStack {
                    self.state.session.appPage.primaryColour
                    Theme.textBackground
                }
            )
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.showPublished) { self.actionOnAppear() }
            .onChange(of: self.state.session.gif) { self.actionOnAppear() }
            .onChange(of: self.state.session.company) { self.setInitialDepth() }
            .onChange(of: self.state.session.project) { self.setInitialDepth() }
            .onChange(of: self.state.session.job) { self.setInitialDepth() }
            .onChange(of: self.altViewModeEnabled) {
                if self.altViewModeEnabled {
                    self.viewModeIndex = 1
                } else {
                    self.viewModeIndex = 0
                }
            }
        }

        var ListHeader: some View {
            HStack {
                UI.Toggle(isOn: $showPublished, icon: "heart", selectedIcon: "heart.fill")
                    .help("Show or hide unpublished items")
                UI.Toggle("Full Colour", isOn: $altViewModeEnabled, icon: "checkmark.square", selectedIcon: "checkmark.square.fill")
                    .help("Navigator becomes colourful")
                    .padding(3)
                    .background(Theme.textBackground)
                    .clipShape(.rect(cornerRadius: 5))
                Spacer()
                FancyGenericToolbar.ActionButton(icon: "arrow.up", callback: self.actionOnUp, helpText: "Up a directory")
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                    .disabled(self.depth == 0)
            }
            .padding(8)
            .background(self.state.session.appPage.primaryColour)
        }

        @ViewBuilder var ListLegend: some View {
            HStack {
                Text("Name")
                Spacer()
                if self.location == .content {
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
            }
            .font(.caption)
            .padding(4)
            .background(self.state.session.appPage.primaryColour)
            Divider()
        }

        var ListFooter: some View {
            HStack {
                Text("\(self.companies.count) Companies")
                    .font(.caption)
            }
            .padding(4)
        }

        struct Row: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            @AppStorage("widget.navigator.sortModifiedOrder") private var navigatorSortModifiedOrder: Bool = false
            @AppStorage("widget.navigator.sortCreatedOrder") private var navigatorSortCreatedOrder: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateCompany") private var shouldCreateCompany: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateProject") private var shouldCreateProject: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateJob") private var shouldCreateJob: Bool = false
            @AppStorage("widget.navigator.depth") private var depth: Int = 0
            public let entity: NSManagedObject
            public let location: WidgetLocation
            @State private var label: String = ""
            @State private var lastModified: Date? = nil
            @State private var created: Date? = nil
            @State private var children: [NSManagedObject]? = nil
            @State private var colour: Color = .white
            @State private var relatedEntities: [PageConfiguration.EntityType] = []
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var id: UUID = UUID()

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    if !self.label.isEmpty {
                        Main
                    }
                }
                .id(self.id)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.viewModeIndex) { self.actionOnAppear() }
                .onChange(of: self.showPublished) { self.actionOnAppear() }
                .onChange(of: self.state.session.company) { self.actionMinOrMax() }
                .onChange(of: self.state.session.project) { self.actionMinOrMax() }
                .onChange(of: self.state.session.job) { self.actionMinOrMax() }
                .onChange(of: self.shouldCreateCompany) { self.actionOnAppear() }
                .onChange(of: self.shouldCreateProject) { self.actionOnAppear() }
                .onChange(of: self.shouldCreateJob) { self.actionOnAppear() }
//                .onChange(of: self.navigatorSortCreatedOrder) { self.actionOnAppear() }
//                .onChange(of: self.navigatorSortModifiedOrder) { self.actionOnAppear() }
            }

            var Main: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.label == "EDIT ME" {
                        UI.InlineEntityCreate(
                            label: self.label,
                            onCreateChild: self.actionOnCreateNewChild,
                            onAbortChild: self.actionOnAbort
                        )
                    } else {
                        Button {
                            self.actionOnTap()
                            self.isPresented.toggle()
                        } label: {
                            self.ButtonContent
                        }
                        .buttonStyle(.plain)
                    }

                    if self.isPresented {
                        if self.children != nil && self.children?.count ?? 0 > 0 {
                            self.Children
                        }

                        if self.relatedEntities.count > 0 {
                            self.RelatedEntities
                        }
                    }
                }
                .contextMenu {
                    self.ContextMenu
                }
            }

            @ViewBuilder var Children: some View {
                VStack(spacing: 1) {
                    ForEach(self.children!, id: \.objectID) { child in
                        if self.state.session.gif == .focus {
                            switch self.entity {
                            case is Company:
                                if let child = child as? Company {
                                    // @TODO: do this check in actionOnAppear instead
                                    if self.state.planning.companies.contains(child) {
                                        Row(entity: child, location: self.location)
                                    }
                                }
                            case is Project:
                                if let child = child as? Project {
                                    if self.state.planning.projects.contains(child) {
                                        Row(entity: child, location: self.location)
                                    }
                                }
                            case is Job:
                                if let child = child as? Job {
                                    if self.state.planning.jobs.contains(child) {
                                        Row(entity: child, location: self.location)
                                    }
                                }
                            default: EmptyView()
                            }
                        } else {
                            Row(entity: child, location: self.location)
                        }
                    }
                }
                .padding(.leading)
            }

            var RelatedEntities: some View {
                VStack(spacing: 1) {
                    ForEach(self.relatedEntities, id: \.self) { entity in
                        if self.state.session.company != nil {
                            switch entity {
                            case .people: US.People(entity: self.state.session.company!)
                            default: EmptyView()
                            }
                        }

                        if self.state.session.job != nil {
                            switch entity {
                            case .tasks: US.Tasks(job: self.state.session.job!)
                            case .records: US.Records(job: self.state.session.job!)
                            case .notes: US.Notes(job: self.state.session.job!)
                            case .definitions: US.Definitions(job: self.state.session.job!)
                            default: EmptyView()
                            }
                        }
                    }
                }
                .padding(.leading)
            }

            @ViewBuilder var ContextMenu: some View {
                switch self.entity {
                case is Company:
                    if let entity = self.entity as? Company {
                        UI.GroupHeaderContextMenu(page: entity.pageDetailType, entity: entity)
                    }
                case is Project:
                    if let entity = self.entity as? Project {
                        UI.GroupHeaderContextMenu(page: entity.pageDetailType, entity: entity)
                    }
                case is Job:
                    if let entity = self.entity as? Job {
                        UI.GroupHeaderContextMenu(page: entity.pageDetailType, entity: entity)
                    }
                default: EmptyView()
                }
            }

            var ButtonContent: some View {
                HStack {
                    ZStack(alignment: .center) {
                        if self.isPresented {
                            self.colour.blendMode(.softLight)
                        }
                        Image(systemName: self.isPresented ? "star.fill" : self.isHighlighted ? "folder.fill" : "folder")
                            // @TODO: create a ShapeStyle for this
                            .foregroundStyle(self.isPresented ? self.state.theme.tint : self.viewModeIndex == 1 ? self.colour.isBright() ? Theme.base : .white : self.colour)
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

                    if self.location == .content {
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
                }
                .padding(8)
                .background(
                    self.viewModeIndex == 1 ? self.isHighlighted ? self.colour.opacity(0.9) : self.colour : Color.white.opacity(self.isPresented ? 0.07 : self.isHighlighted ? 0.07 : 0.03)
                )
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        struct Folder: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            @AppStorage("widget.navigator.sortModifiedOrder") private var navigatorSortModifiedOrder: Bool = false
            @AppStorage("widget.navigator.sortCreatedOrder") private var navigatorSortCreatedOrder: Bool = false
            @AppStorage("widget.navigator.depth") private var depth: Int = 0
            public let entity: NSManagedObject
            @State private var label: String = ""
            @State private var lastModified: Date? = nil
            @State private var created: Date? = nil
            @State private var children: [NSManagedObject]? = nil
            @State private var colour: Color = .white
            @State private var relatedEntities: [PageConfiguration.EntityType] = []
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            private var columns: [GridItem] {
                return Array(repeating: .init(.flexible(minimum: 100)), count: 6)
            }

            var body: some View {
                VStack {
                    switch self.depth {
                    case 0:
                        Text("Companies")
                        if self.entity is Company {
                            Main
                        }
                    case 1:
                        Text("Projects")
                        if self.entity is Project {
                            Main
                        }
                    case 2:
                        Text("Jobs")
                        if self.entity is Job {
                            Main
                        }
                    default: EmptyView()
                    }
                }
                .onChange(of: self.depth) { self.actionOnAppear() }
            }

            var Main: some View {
                VStack {
                    Button {
                        self.actionOnTap()
                        self.isPresented.toggle()
                    } label: {
//                        if !self.isPresented {
                        UI.Blocks.Icon(type: .projects, text: self.label, colour: self.colour)
//                        }
                    }
                    .help(self.label)
                    .buttonStyle(.plain)

                    if self.isPresented {
                        if self.children != nil && self.children?.count ?? 0 > 0 {
                            self.Children
                        }
                    }
                }
                .contextMenu { self.ContextMenu }
                .onAppear(perform: self.actionOnAppear)
//                .onChange(of: self.depth) { self.actionOnAppear() }
//                .onChange(of: self.viewModeIndex) { self.actionOnAppear() }
//                .onChange(of: self.showPublished) { self.actionOnAppear() }
            }

            var ButtonContent: some View {
                VStack {
                    HStack {
                        Image(systemName: "folder")
                    }
                    .font(.largeTitle)
                }
            }

            @ViewBuilder var Children: some View {
                LazyVGrid(columns: self.columns, alignment: .leading) {
                    ForEach(self.children!, id: \.objectID) { child in
                        if self.state.session.gif == .focus {
                            switch self.entity {
                            case is Company:
                                if let child = child as? Company {
                                    if self.state.planning.companies.contains(child) {
                                        Folder(entity: child)
                                    }
                                }
                            case is Project:
                                if let child = child as? Project {
                                    if self.state.planning.projects.contains(child) {
                                        Folder(entity: child)
                                    }
                                }
                            case is Job:
                                if let child = child as? Job {
                                    if self.state.planning.jobs.contains(child) {
                                        Folder(entity: child)
                                    }
                                }
                            default: EmptyView()
                            }
                        } else {
                            Folder(entity: child)
                        }
                    }
                }
                .padding(.leading)
            }

            @ViewBuilder var ContextMenu: some View {
                switch self.entity {
                case is Company:
                    if let entity = self.entity as? Company {
                        UI.GroupHeaderContextMenu(page: entity.pageDetailType, entity: entity)
                    }
                case is Project:
                    if let entity = self.entity as? Project {
                        UI.GroupHeaderContextMenu(page: entity.pageDetailType, entity: entity)
                    }
                case is Job:
                    if let entity = self.entity as? Job {
                        UI.GroupHeaderContextMenu(page: entity.pageDetailType, entity: entity)
                    }
                default: EmptyView()
                }
            }
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

        if self.companies.count(where: {$0.alive == true}) > 0 {
            if let stored = self.state.session.company {
                self.projects = CoreDataProjects(moc: self.state.moc).byCompany(stored)
            }

            if let stored = self.state.session.project {
                self.jobs = CoreDataJob(moc: self.state.moc).byProject(stored)
            }
        } else {
            self.companies = []
            self.projects = []
            self.jobs = []
        }

        self.setInitialDepth()
        self.id = UUID()
    }
    
    /// Set depth based on project/job/company
    /// - Returns: Void
    private func setInitialDepth() -> Void {
        self.id = UUID()
        self.depth = 0
        if self.state.session.company != nil {
            self.depth = 1
        }
        if self.state.session.project != nil {
            self.depth = 2
        }
        if self.state.session.job != nil {
            self.depth = 3
        }
    }

    /// Fires when the Up button is tapped
    /// - Returns: Void
    private func actionOnUp() -> Void {
        if self.depth == 0 {
            self.state.session.company = nil
            self.state.session.project = nil
            self.state.session.job = nil
        } else if self.depth == 1 {
            self.depth = 0
            self.state.session.company = nil
        } else if self.depth == 2 {
            self.depth = 1
            self.state.session.project = nil
            self.state.session.job = nil
        } else if self.depth == 3 {
            self.depth = 2
            self.state.session.job = nil
        }
    }
}

// @TODO: This and Folder are essentially identical, refactor
extension WidgetLibrary.UI.Navigator.List.Row {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        switch self.entity {
        case is Company:
            let company = self.entity as! Company
            self.label = company.name ?? ""
            self.children = CoreDataProjects(moc: self.state.moc).byCompany(company, allowKilled: self.showPublished)
            self.lastModified = company.lastUpdate
            self.created = company.createdDate
            self.colour = company.alive ? company.backgroundColor : .gray.opacity(0.7)
            self.relatedEntities = [.people]
            self.isPresented = company == self.state.session.company
        case is Project:
            let project = self.entity as! Project
            self.label = project.name ?? ""
            self.children = CoreDataJob(moc: self.state.moc).byProject(project, allowKilled: self.showPublished)
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
            self.label = ""
            self.children = []
            self.isPresented = false
        }
    }

    /// Fires when a row is tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        switch self.entity {
        case is Company:
            let company = self.entity as! Company
            self.state.session.company = self.state.session.company == company ? nil : company
            self.state.session.project = nil
            self.state.session.job = nil
            self.depth = 0
        case is Project:
            let project = self.entity as! Project
            self.state.session.project = self.state.session.project == project ? nil : project
            self.state.session.company = project.company
            self.state.session.job = nil
            self.depth = 1
        case is Job:
            let job = self.entity as! Job
            self.state.session.setJob(self.state.session.job == job ? nil : job)
            self.state.session.project = job.project
            self.state.session.company = job.project?.company
            self.depth = 2
        default:
            print("noop")
        }
    }
    
    /// Open or close the group when entity matches the current company/project/job
    /// - Returns: Void
    private func actionMinOrMax() -> Void {
        switch self.entity {
        case is Company:
            let company = self.entity as! Company
            self.isPresented = self.state.session.company == company
        case is Project:
            let project = self.entity as! Project
            self.isPresented = self.state.session.project == project
        case is Job:
            let job = self.entity as! Job
            self.isPresented = self.state.session.job == job
        default:
            print("noop")
        }
    }
    
    /// Fires when you hit enter/save on a editable row
    /// - Returns: Void
    private func actionOnCreateNewChild(name: String) -> Void {
        if name.isEmpty {
            return
        }

        switch self.entity {
        case is Company:
            let company = self.entity as! Company
            company.name = name
            self.id = company.id ?? UUID()
        case is Project:
            let project = self.entity as! Project
            project.name = name
            self.id = project.id ?? UUID()
        case is Job:
            let job = self.entity as! Job
            job.title = name
            self.id = job.id ?? UUID()
        default:
            print("noop")
        }

        PersistenceController.shared.save()
    }
    
    /// Fires when you cancel creating a new project/job
    /// - Returns: Void
    private func actionOnAbort() -> Void {
        var entity: NSManagedObject?

        switch self.entity {
        case is Company: entity = self.entity as! Company
        case is Project: entity = self.entity as! Project
        case is Job: entity = self.entity as! Job
        default:
            entity = nil
        }

        if let deleteableEntity = entity {
            self.state.moc.delete(deleteableEntity)
        }

        self.label = ""
        self.shouldCreateCompany = false
        self.shouldCreateProject = false
        self.shouldCreateJob = false
        self.id = UUID()
    }
}

extension WidgetLibrary.UI.Navigator.List.Folder {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        print("DERPO depth=\(self.depth)")
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
            self.isPresented = self.depth == 0 && company == self.state.session.company
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
            self.isPresented = self.depth == 1 && project == self.state.session.project
        case is Job:
            let job = self.entity as! Job
            self.label = job.title ?? job.jid.string
            self.children = []
            self.lastModified = job.lastUpdate
            self.created = job.created
            self.colour = job.alive ? job.backgroundColor : .gray.opacity(0.7)
            self.relatedEntities = [.tasks, .records, .notes, .definitions]
            self.isPresented = self.depth == 2 && job == self.state.session.job
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
            self.state.session.company = self.state.session.company == company ? nil : company
            self.state.session.project = nil
            self.state.session.job = nil
            self.depth = 0
        case is Project:
            let project = self.entity as! Project
            self.state.session.project = self.state.session.project == project ? nil : project
            self.state.session.job = nil
            self.depth = 1
        case is Job:
            let job = self.entity as! Job
            self.state.session.setJob(self.state.session.job == job ? nil : job)
            self.depth = 2
        default:
            print("noop")
        }

        print("DERPO onTapFolder depth=\(self.depth)")
    }
}
