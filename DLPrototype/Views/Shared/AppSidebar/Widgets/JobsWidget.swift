//
//  RecentJobsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobsWidget: View {
    public var title: String = "Jobs"
    public var location: WidgetLocation = .sidebar

    @FetchRequest public var resource: FetchedResults<Job>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                Spacer()
            }
            .padding(10)
            .background(Theme.base.opacity(0.2))

            VStack(alignment: .leading, spacing: 5) {
                ForEach(resource) { job in
                    JobRowPlain(job: job, location: location)
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}

extension JobsWidget {
    public init(location: WidgetLocation? = nil) {
        _resource = CoreDataJob.fetchAll()
        
        if let loc = location {
            self.location = loc
        }
    }

    private func actionSettings() -> Void {
//        isSettingsPresented.toggle()
    }

}

struct JobsWidgetRedux: View {
    @EnvironmentObject public var state: Navigation
    @State private var companies: [Company] = []
    @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Theme.base.opacity(0.2)
                LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                    .opacity(0.6)
                    .blendMode(.softLight)
                    .frame(height: 50)
                
                HStack(alignment: .center, spacing: 8) {
                    Text("\(self.companies.count) Companies")
                    Spacer()
                    Toggle("Published", isOn: $showPublished)
                        .padding(6)
                        .background(self.showPublished ? Theme.textBackground : .white.opacity(0.5))
                        .foregroundStyle(self.showPublished ? .white : Theme.base)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .help("Show or hide unpublished items")
                }
                .font(.caption)
                .padding(8)
            }

            ForEach(self.companies, id: \.objectID) { company in
                UnifiedSidebar.SingleCompany(company: company)
            }
        }
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.showPublished) { self.actionOnAppear() }
    }
}

extension JobsWidgetRedux {
    /// Onload handler. Finds companies
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.companies = CoreDataCompanies(moc: self.state.moc).all(allowKilled: self.showPublished)
    }
}

struct UnifiedSidebar {
    struct SingleCompany: View {
        @EnvironmentObject private var state: Navigation
        public let company: Company
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    RowButton(text: self.company.name ?? "_COMPANY_NAME", alive: self.company.alive, isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})

                    if self.company == self.state.session.job?.project?.company {
                        FancyStarv2()
                            .help("Currently selected job")
                    }
                }

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Text(self.company.abbreviation ?? "XXX")
                            .foregroundStyle(self.company.backgroundColor.isBright() ? Theme.base : .white)
                            .opacity(0.7)
                            .padding(.leading)
                        Spacer()
                        // @TODO: uncomment when people entities has been implemented
//                        RowAddNavLink(
//                            title: "+ Person",
//                            target: AnyView(EmptyView())
//                        )
//                        .buttonStyle(.plain)
                        RowAddNavLink(
                            title: "+ Project",
                            target: AnyView(ProjectCreate())
                        )
                        .buttonStyle(.plain)
                    }
                    .padding([.top, .bottom], 8)
                    .background(Theme.base.opacity(0.6).blendMode(.softLight))

                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach((self.company.projects?.allObjects as? [Project] ?? []).sorted(by: {$0.created! > $1.created!}), id: \.objectID) { project in
                                    if !showPublished || project.alive {
                                        SingleProject(project: project)
                                    }
                                }

                                People(entity: self.company)
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.company.alive ? self.highlighted ? self.company.backgroundColor.opacity(0.9) : self.company.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.company.alive ? self.company.backgroundColor : .gray).isBright() ? Theme.base : .white)
            .onAppear(perform: {
                if let job = self.state.session.job {
                    self.isPresented = job.project?.company == self.company
                }
            })
        }
    }

    struct SingleProject: View {
        @EnvironmentObject private var state: Navigation
        public let project: Project
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    RowButton(text: self.project.name ?? "_PROJECT_NAME", alive: self.project.alive, isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})

                    if self.project == self.state.session.job?.project {
                        FancyStarv2()
                            .help("Currently selected job")
                    }
                }

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Text("\(self.project.company?.abbreviation ?? "XXX").\(self.project.abbreviation ?? "YYY")")
                            .foregroundStyle(self.project.backgroundColor.isBright() ? Theme.base : .white)
                            .opacity(0.7)
                            .padding(.leading)
                        Spacer()
                        RowAddNavLink(
                            title: "+ Job",
                            target: AnyView(JobCreate())
                        )
                        .buttonStyle(.plain)
                    }
                    .padding([.top, .bottom], 8)
                    .background(Theme.base.opacity(0.6).blendMode(.softLight))

                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach((self.project.jobs?.allObjects as? [Job] ?? []).sorted(by: {$0.created ?? Date() > $1.created ?? Date()}), id: \.objectID) { job in
                                    if !showPublished || job.alive {
                                        SingleJob(job: job)
                                    }
                                }
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.project.alive ? self.highlighted ? self.project.backgroundColor.opacity(0.9) : self.project.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.project.alive ? self.project.backgroundColor : .gray).isBright() ? Theme.base : .white)
            .onAppear(perform: {
                if let job = self.state.session.job {
                    self.isPresented = job.project == self.project
                }
            })
        }
    }

    struct SingleJob: View {
        @EnvironmentObject private var state: Navigation
        public let job: Job
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    RowButton(text: self.job.title ?? self.job.jid.string, alive: self.job.alive, callback: {
                        self.state.session.setJob(self.job)
                    }, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                    if self.job == self.state.session.job {
                        FancyStarv2()
                            .help("Currently selected job")
                    }
                }

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                if let tasks = self.job.tasks?.allObjects as? [LogTask] {
                                    if tasks.count > 0 {
                                        Tasks(job: self.job, tasks: tasks)
                                    }
                                }
                                if let notes = self.job.mNotes?.allObjects as? [Note] {
                                    if notes.count > 0 {
                                        Notes(job: self.job, notes: notes)
                                    }
                                }
                                if let definitions = self.job.definitions?.allObjects as? [TaxonomyTermDefinitions] {
                                    if definitions.count > 0 {
                                        Definitions(job: self.job, definitions: definitions)
                                    }
                                }
                                if let records = self.job.records?.allObjects as? [LogRecord] {
                                    if records.count > 0 {
                                        Records(job: self.job, records: records)
                                    }
                                }
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.job.alive ? self.highlighted ? self.job.backgroundColor.opacity(0.9) : self.job.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.job.alive ? self.job.backgroundColor : .gray).isBright() ? Theme.base : .white)
            .onAppear(perform: {
                if self.state.session.job == self.job {
                    self.isPresented = true
                }
            })
        }
    }

    struct Tasks: View {
        @EnvironmentObject private var state: Navigation
        public let job: Job
        public let tasks: [LogTask]
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    EntityRowButton(text: "\(self.tasks.count) Tasks", isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                    RowAddNavLink(
                        title: "Add",
                        target: AnyView(TaskDashboard())
                    )
                    .buttonStyle(.plain)
                }
                .background(Theme.base.opacity(0.6).blendMode(.softLight))

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.tasks, id: \.objectID) { task in
                                    if task.content != nil {
                                        EntityTypeRowButton(label: task.content!, redirect: .taskDetail, resource: task)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(self.job.alive ? self.highlighted ? self.job.backgroundColor.opacity(0.9) : self.job.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.job.alive ? self.job.backgroundColor : .gray).isBright() ? Theme.base : .white)
        }
    }

    struct Notes: View {
        @EnvironmentObject private var state: Navigation
        public let job: Job
        public let notes: [Note]
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    EntityRowButton(text: "\(self.notes.count) Notes", isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                    RowAddNavLink(
                        title: "Add",
                        target: AnyView(NoteCreate())
                    )
                    .buttonStyle(.plain)
                }
                .background(Theme.base.opacity(0.6).blendMode(.softLight))

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.notes, id: \.objectID) { note in
                                    if note.title != nil {
                                        EntityTypeRowButton(label: note.title!, redirect: .noteDetail, resource: note)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(self.job.alive ? self.highlighted ? self.job.backgroundColor.opacity(0.9) : self.job.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.job.alive ? self.job.backgroundColor : .gray).isBright() ? Theme.base : .white)
        }
    }

    struct Definitions: View {
        @EnvironmentObject private var state: Navigation
        public let job: Job
        public let definitions: [TaxonomyTermDefinitions]
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    EntityRowButton(text: "\(self.definitions.count) Definitions", isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                    RowAddNavLink(
                        title: "Add",
                        target: AnyView(DefinitionDetail())
                    )
                    .buttonStyle(.plain)
                }
                .background(Theme.base.opacity(0.6).blendMode(.softLight))

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.definitions, id: \.objectID) { def in
                                    if def.definition != nil {
                                        EntityTypeRowButton(label: def.definition!, redirect: .definitionDetail, resource: def)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(self.job.alive ? self.highlighted ? self.job.backgroundColor.opacity(0.9) : self.job.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.job.alive ? self.job.backgroundColor : .gray).isBright() ? Theme.base : .white)
        }
    }

    struct Records: View {
        @EnvironmentObject private var state: Navigation
        public let job: Job
        public let records: [LogRecord]
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    EntityRowButton(text: "\(self.records.count) Records", isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                }
                .background(Theme.base.opacity(0.6).blendMode(.softLight))

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.records, id: \.objectID) { record in
                                    if record.message != nil {
                                        EntityTypeRowButton(label: record.message!, redirect: .today, resource: record)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(self.job.alive ? self.highlighted ? self.job.backgroundColor.opacity(0.9) : self.job.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.job.alive ? self.job.backgroundColor : .gray).isBright() ? Theme.base : .white)
        }
    }

    struct People: View {
        @EnvironmentObject private var state: Navigation
        public let entity: Company
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    EntityRowButton(text: "People", isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                    // @TODO: uncomment when people entities has been implemented
//                    RowAddNavLink(
//                        title: "Add",
//                        target: AnyView(EmptyView())
//                    )
//                    .buttonStyle(.plain)
                }
                .background(Theme.base.opacity(0.6).blendMode(.softLight))

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.entity.people?.allObjects as? [Person] ?? [], id: \.objectID) { person in
                                    if person.name != nil {
                                        EntityTypeRowButton(label: person.name!, redirect: .taskDetail, resource: person)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(self.entity.alive ? self.highlighted ? self.entity.backgroundColor.opacity(0.9) : self.entity.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.entity.alive ? self.entity.backgroundColor : .gray).isBright() ? Theme.base : .white)
        }
    }

    struct RowButton: View {
        public let text: String
        public let alive: Bool
        public var callback: (() -> Void)?
        @Binding public var isPresented: Bool

        var body: some View {
            Button {
                isPresented.toggle()
                self.callback?()
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    ZStack(alignment: .center) {
                        Theme.base.opacity(0.6).blendMode(.softLight)
                        Image(systemName: self.isPresented ? "minus" : "plus")
                    }
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)

                    Text(self.text)
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                    Spacer()

                    if !self.alive {
                        Image(systemName: "snowflake")
                            .font(.title3)
                            .opacity(0.5)
                            .help("Unpublished")
                    }
                }
                .padding(8)
            }
            .buttonStyle(.plain)
        }
    }

    struct EntityRowButton: View {
        public let text: String
        public var callback: (() -> Void)?
        @Binding public var isPresented: Bool

        var body: some View {
            Button {
                isPresented.toggle()
                self.callback?()
            } label: {
                ZStack(alignment: .topLeading) {
                    Theme.base.opacity(0.6).blendMode(.softLight)
                    HStack(alignment: .center, spacing: 8) {
                        ZStack(alignment: .center) {
                            Theme.base.opacity(0.6).blendMode(.softLight)
                            Image(systemName: self.isPresented ? "minus" : "plus")
                        }
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)

                        Text(self.text)
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .buttonStyle(.plain)
        }
    }

    struct EntityTypeRowButton: View {
        @EnvironmentObject private var state: Navigation
        public var label: String
        public var redirect: Page
        public var resource: NSManagedObject
        @State private var highlighted: Bool = false
        @State private var noLinkAvailable: Bool = false // @TODO: this should be removed after all entity detail pages have been implemented

        var body: some View {
            Button {
                self.state.to(self.redirect)
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: self.noLinkAvailable ? "questionmark.square.fill" : "link")
                        .opacity(0.4)
                    Text(self.label)
                    Spacer()
                }
                .padding(8)
                .background(self.highlighted ? .white.opacity(0.2) : .clear)
                .useDefaultHover({ inside in self.highlighted = inside})
            }
            .disabled(self.noLinkAvailable)
            .help(self.noLinkAvailable ? "Link not found" : self.label)
            .buttonStyle(.plain)
            .onAppear(perform: self.actionOnAppear)
        }
    }
}

extension UnifiedSidebar.EntityTypeRowButton {
    /// Onload handler. Sets appropriate link data for the given Page
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        switch self.redirect {
            // @TODO: uncomment after this detail view has been implemented
//        case .today:
//            self.state.session.record = self.resource as? LogRecord
        case .projects:
            self.state.session.project = self.resource as? Project
        case .jobs:
            self.state.session.job = self.resource as? Job
        case .companies:
            self.state.session.company = self.resource as? Company
        case .terms:
            self.state.session.term = self.resource as? TaxonomyTerm
        case .definitionDetail:
            self.state.session.definition = self.resource as? TaxonomyTermDefinitions
        // @TODO: uncomment after this detail view has been implemented
//        case .taskDetail, .tasks:
//            self.state.session.task = self.resource as? LogTask
        case .noteDetail, .notes:
            self.state.session.note = self.resource as? Note
        default:
            self.noLinkAvailable = true
        }
    }
}
