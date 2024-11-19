//
//  Inspector.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

public struct Inspector: View, Identifiable {
    @EnvironmentObject public var nav: Navigation
    @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    public let id: UUID = UUID()
    public var entity: NSManagedObject? = nil
    public var event: EKEvent? = nil
    public var location: WidgetLocation = .inspector
    private let panelWidth: CGFloat = 400
    private var job: Job? = nil
    private var project: Project? = nil
    private var record: LogRecord? = nil
    private var company: Company? = nil
    private var person: Person? = nil
    private var note: Note? = nil
    private var task: LogTask? = nil
    private var term: TaxonomyTerm?
    private var definition: TaxonomyTermDefinitions?

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                UI.ListLinkTitle(text: "Inspector")
                Spacer()
                UI.Buttons.Close(
                    action: {
                        self.nav.session.search.cancel()
                        self.nav.setInspector()
                        self.isSearchStackShowing = false
                    }
                )
            }
            Divider()
            FancyDivider(height: 5)

            ScrollView(showsIndicators: false) {
                if self.entity != nil {
                    EntityInspectorBody
                } else if let event = self.event {
                    InspectingEvent(item: event)
                }
            }
            Spacer()
        }
        .padding([.trailing, .top, .bottom])
        .padding(.leading, self.location == .content ? 0 : 20)
        .frame(maxWidth: panelWidth)
        .background(self.location == .content ? [.opaque, .classic, .hybrid].contains(self.nav.theme.style) ? self.nav.session.appPage.primaryColour : self.nav.session.appPage.primaryColour.opacity(0.3) : .clear)
    }
    public var EntityInspectorBody: some View {
        VStack(alignment: .leading) {
            if let job = job {
                InspectingJob(item: job)
            } else if let record = record {
                InspectingRecord(item: record)
            } else if let project = project {
                InspectingProject(item: project)
            } else if let company = company {
                InspectingCompany(item: company)
            } else if let person = person {
                InspectingPerson(item: person)
            } else if let note = note {
                InspectingNote(item: note)
            } else if let task = task {
                InspectingTask(item: task)
            } else if let term = term {
                InspectingTerm(item: term)
            } else if let definition = definition {
                InspectingDefinition(item: definition)
            } else {
                Text("Unable to inspect this item")
            }
        }
    }

    init(entity: NSManagedObject? = nil, event: EKEvent? = nil, location: WidgetLocation = .inspector) {
        self.entity = entity
        self.event = event
        self.location = location

        if entity != nil {
            switch self.entity {
            case let en as Job: self.job = en
            case let en as Project: self.project = en
            case let en as LogRecord: self.record = en
            case let en as Company: self.company = en
            case let en as Person: self.person = en
            case let en as Note: self.note = en
            case let en as LogTask: self.task = en
            case let en as TaxonomyTerm: self.term = en
            case let en as TaxonomyTermDefinitions: self.definition = en
            default: print("[error] FindDashboard.Inspector Unknown entity type=\(self.entity?.description ?? "nil")")
            }
        }
    }

    struct InspectingJob: View {
        public var item: Job

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                        Text("Type: Job")
                        Spacer()
                    }
                    .help("Type: Job entity")
                    Divider()
                    UI.Blocks.GenericBlock(item: self.item)
                    Divider()

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "number").symbolRenderingMode(.hierarchical)
                        Text(item.jid.string)
                        Spacer()
                    }
                    .help("ID: \(item.jid.string)")
                    Divider()

                    if let date = item.created {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                            Text(date.description)
                            Spacer()
                        }
                        .help("Created: \(date.description)")
                        Divider()
                    }

                    if let date = item.lastUpdate {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                            Text(date.description)
                            Spacer()
                        }
                        .help("Last updated: \(date.description)")
                        Divider()
                    }

                    if let uri = item.uri {
                        if uri.absoluteString != "https://" {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "link").symbolRenderingMode(.hierarchical)
                                    Link(destination: uri, label: {
                                        Text(uri.absoluteString)
                                    })
                                    .help("Open in browser")
                                    .underline()
                                    .useDefaultHover({_ in})
                                    .contextMenu {
                                        Button {
                                            ClipboardHelper.copy(uri.absoluteString)
                                        } label: {
                                            Text("Copy to clipboard")
                                        }
                                    }
                                    Spacer()
                                }
                                Divider()
                            }
                        }
                    }
                    Context(item: item)
                    Spacer()
                    if self.nav.session.job != self.item {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top, spacing: 10) {
                                FancyButtonv2(
                                    text: "Overwrite Active Job",
                                    action: {self.nav.session.job = self.item},
                                    icon: "arrow.right.square.fill",
                                    showLabel: true,
                                    size: .link,
                                    type: .clear
                                )
                                .help(self.nav.session.job != nil ? "Current: \(self.nav.session.job!.jid)" : "Set as Active Job.")
                            }
                        }
                    }
                }
            }
        }
    }

    struct InspectingRecord: View {
        public var item: LogRecord

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Record")
                    Spacer()
                }
                .help("Type: Record entity")
                Divider()
                UI.Blocks.GenericBlock(item: self.item)
                Divider()

                if let date = item.timestamp {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let message = item.message {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "tray").symbolRenderingMode(.hierarchical)
                        Text("Message")
                        Spacer()
                    }
                    Divider()
                    Text(message)
                        .contextMenu {
                            Button("Copy to clipboard") {
                                ClipboardHelper.copy(message)
                            }
                        }
                        .help("Full contents of this message")
                }

                Divider()

                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    FancyButtonv2(
                        text: "Open day",
                        action: {nav.session.date = item.timestamp ?? Date() ; nav.setInspector()},
                        icon: "arrow.right.square.fill",
                        showLabel: true,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(Today()),
                        pageType: .today,
                        sidebar: AnyView(TodaySidebar())
                    )
                }
            }
        }
    }

    struct InspectingProject: View {
        public var item: Project

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Project")
                    Spacer()
                }
                .help("Type: Project entity")
                Divider()
                UI.Blocks.GenericBlock(item: self.item)
                Divider()

                if let date = item.created {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let date = item.lastUpdate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                }

                if let jobs = self.item.jobs?.allObjects as? [Job] {
                    if jobs.count(where: {$0.alive == true}) > 0 {
                        Divider()
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "folder.fill").symbolRenderingMode(.hierarchical)
                            Text("Jobs")
                            Spacer()
                        }
                        ForEach(jobs.filter({$0.alive == true}).sorted(by: {$0.lastUpdate ?? Date.now > $1.lastUpdate ?? Date.now}), id: \.objectID) { entity in
                            UI.Links.ToJob(entity: entity)
                        }
                    }
                }
                Divider()
                Spacer()
            }
        }
    }

    struct InspectingCompany: View {
        @EnvironmentObject public var nav: Navigation
        public var item: Company

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Company")
                    Spacer()
                }
                .help("Type: Company entity")
                Divider()
                UI.Blocks.GenericBlock(item: self.item)
                Divider()
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: self.item.alive ? "heart.fill" : "heart").symbolRenderingMode(.hierarchical)
                        .foregroundStyle(self.item.alive ? .red : .gray)
                    Text(self.item.alive ? "Published" : "Unpublished")
                    Spacer()
                }
                .help(self.item.alive ? "Unpublish" : "Publish")
                Divider()
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: self.item.isDefault ? "building.2.fill" : "building.2").symbolRenderingMode(.hierarchical)
                    Text(self.item.isDefault ? "Default Company: Yes" : "Default Company: No")
                    Spacer()
                }
                .help(self.item.isDefault ? "This is your default company" : "")
                Divider()
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: self.item.hidden ? "eye.slash" : "eye").symbolRenderingMode(.hierarchical)
                    Text(self.item.hidden ? "Hidden from UI/search" : "Visible in UI/search results")
                    Spacer()
                }
                .help(self.item.hidden ? "Hidden? Yes" : "Hidden? No")
                Divider()

                if let date = item.createdDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let projects = self.item.projects?.allObjects as? [Project] {
                    if projects.count(where: {$0.alive == true}) > 0 {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "folder.fill").symbolRenderingMode(.hierarchical)
                            Text("Projects")
                            Spacer()
                        }
                        ForEach(projects.filter({$0.alive == true}).sorted(by: {$0.lastUpdate ?? Date.now > $1.lastUpdate ?? Date.now}), id: \.objectID) { project in
                            UI.Links.ToProject(entity: project)
                        }
                    }
                }
                Spacer()
            }
        }
    }

    struct InspectingPerson: View {
        public var item: Person

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Person")
                    Spacer()
                }
                .help("Type: Person entity")
                Divider()

                if let name = item.name {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                        Text(name)
                        Spacer()
                    }
                    .help(name)
                    Divider()
                }

                if let title = item.title {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                        Text(title)
                        Spacer()
                    }
                    .help(title)
                    Divider()
                }

                if let date = item.created {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let date = item.lastUpdate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Last update: \(date.description)")
                    Divider()
                }

                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    FancyButtonv2(
                        text: "Open",
                        action: {self.nav.session.person = self.item; self.nav.to(.peopleDetail)},
                        icon: "arrow.right.square.fill",
                        showLabel: true,
                        size: .link,
                        type: .clear,
                        pageType: .people
                    )
                }
            }
        }
    }

    struct InspectingNote: View {
        @EnvironmentObject public var nav: Navigation
        public var item: Note

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Note")
                    Spacer()
                }
                .help("Type: Note entity")
                Divider()
                UI.Blocks.GenericBlock(item: self.item)
                Divider()
                if let versions = self.item.versions?.allObjects as? [NoteVersion] {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "number").symbolRenderingMode(.hierarchical)
                        Text("\(versions.count) Versions")
                        Spacer()
                    }
                    .help("\(versions.count) saved versions of this note")
                    Divider()
                }
                if let date = item.postedDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }
                if let date = item.lastUpdate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Last update: \(date.description)")
                    Divider()
                }
                if let versions = self.item.versions?.allObjects as? [NoteVersion] {
                    if versions.count > 0 {
                        if let content = versions.first?.content {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                                Text("Preview")
                                Spacer()
                            }
                            Divider()
                            HStack(alignment: .top, spacing: 10) {
                                if content.count > 150 {
                                    Text("\(content.prefix(150))...")
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Text(content)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                }
                Divider()
                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    FancyButtonv2(
                        text: "Open",
                        action: {nav.session.search.cancel() ; nav.setInspector()},
                        icon: "arrow.right.square.fill",
                        showLabel: true,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(NoteCreate(note: item)),
                        pageType: .notes,
                        sidebar: AnyView(NoteCreateSidebar(note: item))
                    )
                }
            }
        }
    }

    struct InspectingTask: View {
        public var item: LogTask

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Task")
                    Spacer()
                }
                .help("Type: Task entity")
                Divider()
                UI.Blocks.GenericBlock(item: self.item)
                Divider()

                if let date = item.created {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text("Created: " + date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let date = item.lastUpdate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar").symbolRenderingMode(.hierarchical)
                        Text("Last update: " + date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                    }
                    .help("Last update: \(date.description)")
                    Divider()
                }

                if item.cancelledDate == nil && item.completedDate == nil {
                    if let date = item.due {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                            Text("Due: " + date.formatted(date: .abbreviated, time: .shortened))
                            Spacer()
                        }
                        .help("Due at: \(date.description)")
                        Divider()
                    }
                }

                if let date = item.completedDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text("Completed on: " + date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                    }
                    .help("Completed on \(date.description)")
                    Divider()
                }

                if let date = item.cancelledDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text("Cancelled on: " + date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                    }
                    .help("Cancelled on \(date.description)")
                    Divider()
                }

                Spacer()
                if let job = item.owner {
                    if let project = job.project {
                        HStack(alignment: .top, spacing: 10) {
                            FancyButtonv2(
                                text: "Open",
                                icon: "arrow.right.square.fill",
                                showLabel: true,
                                size: .link,
                                type: .clear,
                                redirect: AnyView(TaskDashboardByProject(project: project)),
                                pageType: .companies,
                                sidebar: AnyView(DefaultCompanySidebar())
                            )
                        }
                    }
                }
            }
        }
    }

    struct InspectingTerm: View {
        public var item: TaxonomyTerm

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Taxonomy term")
                    Spacer()
                }
                .help("Type: Taxonomy term")
                Divider()

                if let date = item.created {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let date = item.lastUpdate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Last update: \(date.description)")
                    Divider()
                }

                if let name = item.name {
                    HStack(alignment: .center) {
                        Image(systemName: "list.bullet.rectangle").symbolRenderingMode(.hierarchical)
                        FancyButtonv2(
                            text: name,
                            action: {nav.session.search.cancel() ; nav.setInspector() ; self.nav.to(.terms)},
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .help("Term: \(name)")
                    }
                    Divider()
                }

                if let defs = item.definitions?.allObjects as? [TaxonomyTermDefinitions] {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "list.bullet").symbolRenderingMode(.hierarchical)
                        Text("\(defs.count(where: {$0.alive == true})) definition(s)")
                        Spacer()
                    }
                    Divider()
                    VStack(spacing: 1) {
                        ForEach(defs, id: \.objectID) { definition in
                            UI.Blocks.Definition(definition: definition)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 5))
                }

                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    FancyButtonv2(
                        text: "Open",
                        action: {nav.session.search.cancel() ; nav.setInspector()},
                        icon: "arrow.right.square.fill",
                        showLabel: true,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(TermsDashboard()),
                        pageType: .terms,
                        sidebar: AnyView(DefinitionSidebar())
                    )
                }
            }
        }
    }

    struct InspectingDefinition: View {
        public var item: TaxonomyTermDefinitions

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Taxonomy definition")
                    Spacer()
                }
                .help("Type: Taxonomy definition")
                Divider()
                UI.Blocks.GenericBlock(item: self.item)
                Divider()

                if let date = item.created {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                if let date = item.lastUpdate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Last update: \(date.description)")
                    Divider()
                }

                if let term = self.item.term {
                    HStack(alignment: .center) {
                        Image(systemName: "list.bullet.rectangle").symbolRenderingMode(.hierarchical)
                        FancyButtonv2(
                            text: term.name ?? "Not Found",
                            action: {nav.session.search.cancel() ; nav.setInspector()},
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear,
                            redirect: AnyView(TermsDashboard()),
                            pageType: .terms,
                            sidebar: AnyView(TermsDashboardSidebar())
                        )
                    }
                    Divider()
                }

                HStack(alignment: .center) {
                    Image(systemName: "list.bullet").symbolRenderingMode(.hierarchical)
                    Text("Definition")
                }
                Divider()
                VStack(alignment: .leading, spacing: 1) {
                    UI.Blocks.Definition(definition: self.item)
                        .help("Full definition text")
                }
                .clipShape(.rect(cornerRadius: 5))
                Divider()
                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    FancyButtonv2(
                        text: "Open",
                        action: {nav.session.search.cancel() ; nav.setInspector()},
                        icon: "arrow.right.square.fill",
                        showLabel: true,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(DefinitionDetail(definition: item)),
                        pageType: .terms,
                        sidebar: AnyView(DefinitionSidebar())
                    )
                }
            }
        }
    }

    struct InspectingEvent: View {
        public var item: EKEvent

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Calendar event")
                    Spacer()
                }
                .help("Type: Calendar event")
                Divider()

                if let date = item.startDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Starts at \(date.description)")
                    Divider()
                }

                if let date = item.endDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Ends at \(date.description)")
                    Divider()
                }

                if item.isAllDay {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "arrow.trianglehead.clockwise.rotate.90").symbolRenderingMode(.hierarchical)
                        Text("All day event")
                        Spacer()
                    }
                    .help("All-day event")
                    Divider()
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Title: \(item.title)")
                    Spacer()
                }
                .help("Title: \(item.title)")
                Divider()

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Calendar: \(item.calendar.title)")
                    Spacer()
                }
                .help("Calendar: \(item.calendar.title)")
                Divider()

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "camera.filters").symbolRenderingMode(.hierarchical)
                    ZStack {
                        Theme.base
                        Color(item.calendar.color)
                    }
                    .frame(width: 15, height: 15)
                    Text("Colour")
                    Spacer()
                }
                .help("Colour: \(item.calendar.cgColor.debugDescription)")
                Divider()
            }
        }
    }
}
