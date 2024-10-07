//
//  RecentJobsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct UnifiedSidebar {
    struct Widget: View {
        @EnvironmentObject public var state: Navigation
        @State private var companies: [Company] = []
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Theme.base.opacity(0.2)

                    HStack(alignment: .center, spacing: 8) {
                        Text("\(self.companies.count) Companies")
                            .padding(6)
                            .background(Theme.textBackground)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        Spacer()
                        Toggle("Published", isOn: $showPublished)
                            .padding(6)
                            .background(self.showPublished ? Theme.textBackground : .white.opacity(0.5))
                            .foregroundStyle(self.showPublished ? .white : Theme.base)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .help("Show or hide unpublished items")
                            .font(.caption)
                    }
                    .padding(8)
                }
                Divider()

                ForEach(self.companies, id: \.objectID) { company in
                    SingleCompany(entity: company)
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.showPublished) { self.actionOnAppear() }
        }
    }

    struct SingleCompany: View {
        @EnvironmentObject private var state: Navigation
        public let entity: Company
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @State private var bgColour: Color = .clear
        @State private var fgColour: Color = .clear
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    RowButton(text: self.entity.name ?? "_COMPANY_NAME", alive: self.entity.alive, callback: {
                        self.state.session.company = self.entity
                    }, isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                        .contextMenu {
                            GroupHeaderContextMenu(page: self.entity.pageDetailType, entity: self.entity)
                        }

                    if self.entity == self.state.session.company {
                        FancyStarv2()
                            .help("Active company")
                    }
                }

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Text(self.entity.abbreviation ?? "XXX")
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : .white)
                            .opacity(0.7)
                            .padding(.leading)
                        Spacer()
                        RowAddNavLink(
                            title: "+ Person",
                            target: AnyView(PeopleDetail())
                        )
                        .buttonStyle(.plain)
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
                                ForEach((self.entity.projects?.allObjects as? [Project] ?? []).sorted(by: {$0.created! > $1.created!}), id: \.objectID) { project in
                                    if !showPublished || project.alive {
                                        SingleProject(entity: project)
                                    }
                                }

                                People(entity: self.entity)
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.highlighted ? self.bgColour.opacity(0.9) : self.bgColour)
            .foregroundStyle(self.fgColour)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.company) { self.actionOnChangeEntity() }
            .onChange(of: self.isPresented) {
                // Group is minimized
                if self.isPresented == false {
                    self.actionOnMinimize()
                }
            }
        }
    }

    struct SingleProject: View {
        @EnvironmentObject private var state: Navigation
        public let entity: Project
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @State private var bgColour: Color = .clear
        @State private var fgColour: Color = .clear
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    RowButton(text: self.entity.name ?? "_PROJECT_NAME", alive: self.entity.alive, callback: {
                        self.state.session.project = self.entity
                    }, isPresented: $isPresented)
                        .useDefaultHover({ inside in self.highlighted = inside})
                        .contextMenu {
                            GroupHeaderContextMenu(page: self.entity.pageDetailType, entity: self.entity)
                        }

                    if self.entity == self.state.session.project {
                        FancyStarv2()
                            .help("Active project")
                    }
                }

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Text("\(self.entity.company?.abbreviation ?? "XXX").\(self.entity.abbreviation ?? "YYY")")
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : .white)
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
                                ForEach((self.entity.jobs?.allObjects as? [Job] ?? []).sorted(by: {$0.created ?? Date() > $1.created ?? Date()}), id: \.objectID) { job in
                                    if !showPublished || job.alive {
                                        SingleJob(entity: job)
                                    }
                                }
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.highlighted ? self.bgColour.opacity(0.9) : self.bgColour)
            .foregroundStyle(self.fgColour)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.project) { self.actionOnChangeEntity() }
            .onChange(of: self.isPresented) {
                // Group is minimized
                if self.isPresented == false {
                    self.actionOnMinimize()
                }
            }
        }
    }

    struct SingleJob: View {
        @EnvironmentObject private var state: Navigation
        public let entity: Job
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @State private var bgColour: Color = .clear
        @State private var fgColour: Color = .clear
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .trailing) {
                    RowButton(text: self.entity.title ?? self.entity.jid.string, alive: self.entity.alive, callback: {
                        self.state.session.setJob(self.entity)

                        if self.state.parent == .planning {
                            self.state.planning.jobs.insert(entity)
                            self.state.planning.projects.insert(entity.project!)

                            // projects are allowed to be unowned
                            if let company = entity.project!.company {
                                self.state.planning.companies.insert(company)
                            }
                        }
                    }, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})
                    .contextMenu {
                        GroupHeaderContextMenu(page: self.entity.pageDetailType, entity: self.entity)
                    }

                    if self.entity == self.state.session.job {
                        FancyStarv2()
                            .help("Active job")
                    }
                }

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            VStack(alignment: .leading, spacing: 0) {
                                if let tasks = self.entity.tasks?.allObjects as? [LogTask] {
                                    if tasks.count > 0 {
                                        Tasks(job: self.entity, tasks: tasks)
                                    }
                                }
                                if let notes = self.entity.mNotes?.allObjects as? [Note] {
                                    if notes.count > 0 {
                                        Notes(job: self.entity, notes: notes)
                                    }
                                }
                                if let definitions = self.entity.definitions?.allObjects as? [TaxonomyTermDefinitions] {
                                    if definitions.count > 0 {
                                        Definitions(job: self.entity, definitions: definitions)
                                    }
                                }
                                if let records = self.entity.records?.allObjects as? [LogRecord] {
                                    if records.count > 0 {
                                        Records(job: self.entity, records: records)
                                    }
                                }
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.highlighted ? self.bgColour.opacity(0.9) : self.bgColour)
            .foregroundStyle(self.fgColour)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.job) { self.actionOnChangeEntity() }
            .onChange(of: self.isPresented) {
                // Group is minimized
                if self.isPresented == false {
                    self.actionOnMinimize()
                }
            }
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
                        target: AnyView(TaskDetail())
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
                    RowAddNavLink(
                        title: "Add",
                        target: AnyView(PeopleDetail())
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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.entity.people?.allObjects as? [Person] ?? [], id: \.objectID) { person in
                                    if person.name != nil {
                                        EntityTypeRowButton(label: person.name!, redirect: .peopleDetail, resource: person)
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
                self.isPresented.toggle()
                self.callback?()
            } label: {
                ZStack(alignment: .topLeading) {
                    Color.white.opacity(0.01).blendMode(.softLight)
                    HStack(alignment: .center, spacing: 8) {
                        ZStack(alignment: .center) {
                            Theme.base.opacity(0.6).blendMode(.softLight)
                            Image(systemName: self.isPresented ? "minus" : "plus")
                        }
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)

                        Text(self.text)
                            .multilineTextAlignment(.leading)
                        Spacer()

                        if !self.alive {
                            Image(systemName: "snowflake")
                                .opacity(0.5)
                                .help("Unpublished")
                        }
                    }
                    .padding(8)
                }
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
                self.setSessionParameter()
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
        }
    }

    struct GroupHeaderContextMenu: View {
        @EnvironmentObject private var state: Navigation
        public let page: Page
        public let entity: NSManagedObject

        var body: some View {
            Button(action: self.actionEdit, label: {
                Text("Edit...")
            })
            Divider()
            Button(action: self.actionInspect, label: {
                Text("Inspect")
            })
        }
    }
}

extension UnifiedSidebar.Widget {
    /// Onload handler. Finds companies
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.companies = CoreDataCompanies(moc: self.state.moc).all(allowKilled: self.showPublished)
    }
}

extension UnifiedSidebar.SingleCompany {
    /// Onload handler. Sets background colour for the row
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.entity.alive {
            self.bgColour = self.entity.backgroundColor
            self.fgColour = self.bgColour.isBright() ? Theme.base : .white
        } else {
            self.bgColour = .gray
            self.fgColour = Theme.base
        }

        if let company = self.state.session.company {
            self.isPresented = company == self.entity
        } else if let job = self.state.session.job {
            self.isPresented = job.project?.company == self.entity
        }
    }
    
    /// Fires when state entity changes
    /// - Returns: Void
    private func actionOnChangeEntity() -> Void {
        if self.state.session.company != nil {
            if self.state.session.company != self.entity {
                self.isPresented = false
                // @TODO: decide whether to attempt to finish this "focus on current open group" functionality
//                self.bgColour = .gray
//                self.fgColour = Theme.base
            } else {
                self.bgColour = self.entity.backgroundColor
                self.fgColour = self.bgColour.isBright() ? Theme.base : .white
            }
        } else {
            self.bgColour = self.entity.backgroundColor
            self.fgColour = self.bgColour.isBright() ? Theme.base : .white
        }
    }
    
    /// Fires when a group is minimized
    /// - Returns: Void
    private func actionOnMinimize() -> Void {
        if self.state.session.company == self.entity {
            self.state.session.company = nil
            self.state.session.project = nil
            self.state.session.job = nil
        }
        self.bgColour = self.entity.backgroundColor
        self.fgColour = self.bgColour.isBright() ? Theme.base : .white
    }
}

extension UnifiedSidebar.SingleProject {
    /// Onload handler. Sets background colour for the row
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.entity.alive {
            self.bgColour = self.entity.backgroundColor
            self.fgColour = self.bgColour.isBright() ? Theme.base : .white
        } else {
            self.bgColour = .gray
            self.fgColour = Theme.base
        }

        if let project = self.state.session.project {
            self.isPresented = project == self.entity
        } else if let job = self.state.session.job {
            self.isPresented = job.project == self.entity
        }
    }

    /// Fires when state entity changes
    /// - Returns: Void
    private func actionOnChangeEntity() -> Void {
        if self.state.session.project != nil {
            if self.state.session.project != self.entity {
                self.isPresented = false
                // @TODO: decide whether to attempt to finish this "focus on current open group" functionality
//                self.bgColour = .gray
//                self.fgColour = Theme.base
            } else {
                self.bgColour = self.entity.backgroundColor
                self.fgColour = self.bgColour.isBright() ? Theme.base : .white
            }
        } else {
            self.bgColour = self.entity.backgroundColor
            self.fgColour = self.bgColour.isBright() ? Theme.base : .white
        }
    }

    /// Fires when a group is minimized
    /// - Returns: Void
    private func actionOnMinimize() -> Void {
        if self.state.session.project == self.entity {
            self.state.session.project = nil
            self.state.session.job = nil
        }
        self.bgColour = self.entity.backgroundColor
        self.fgColour = self.bgColour.isBright() ? Theme.base : .white
    }
}

extension UnifiedSidebar.SingleJob {
    /// Onload handler. Sets background colour for the row
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.entity.alive {
            self.bgColour = self.entity.backgroundColor
            self.fgColour = self.bgColour.isBright() ? Theme.base : .white
        } else {
            self.bgColour = .gray
            self.fgColour = Theme.base
        }

        if let job = self.state.session.job {
            self.isPresented = job == self.entity
        }
    }

    /// Fires when state entity changes
    /// - Returns: Void
    private func actionOnChangeEntity() -> Void {
        if self.state.session.job != nil {
            if self.state.session.job != self.entity {
                self.isPresented = false
                // @TODO: decide whether to attempt to finish this "focus on current open group" functionality
//                self.bgColour = .gray
//                self.fgColour = Theme.base
            } else {
                self.bgColour = self.entity.backgroundColor
                self.fgColour = self.bgColour.isBright() ? Theme.base : .white
            }
        } else {
            self.bgColour = self.entity.backgroundColor
            self.fgColour = self.bgColour.isBright() ? Theme.base : .white
        }
    }

    /// Fires when a group is minimized
    /// - Returns: Void
    private func actionOnMinimize() -> Void {
        if self.state.session.job == self.entity {
            self.state.session.job = nil
        }
        self.bgColour = self.entity.backgroundColor
        self.fgColour = self.bgColour.isBright() ? Theme.base : .white
    }
}

extension UnifiedSidebar.EntityTypeRowButton {
    /// Onload handler. Sets appropriate link data for the given Page
    /// - Returns: Void
    private func setSessionParameter() -> Void {
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
        case .taskDetail:
            self.state.session.task = self.resource as? LogTask
        case .noteDetail, .notes:
            self.state.session.note = self.resource as? Note
        case .peopleDetail, .people:
            self.state.session.person = self.resource as? Person
        default:
            self.noLinkAvailable = true
        }
    }
}

extension UnifiedSidebar.GroupHeaderContextMenu {
    /// Navigate to an edit page
    /// - Returns: Void
    private func actionEdit() -> Void {
        switch self.page {
        case .jobs:
            self.state.session.job = self.entity as? Job
        case .companyDetail:
            self.state.session.company = self.entity as? Company
        case .projectDetail:
            self.state.session.project = self.entity as? Project
        case .definitionDetail:
            self.state.session.definition = self.entity as? TaxonomyTermDefinitions
        case .taskDetail:
            self.state.session.task = self.entity as? LogTask
        case .noteDetail:
            self.state.session.note = self.entity as? Note
        case .peopleDetail:
            self.state.session.person = self.entity as? Person
        default:
            print("noop")
        }
        self.state.to(self.page)
    }

    /// Inspect an entity
    /// - Returns: Void
    private func actionInspect() -> Void {
        self.state.session.search.inspectingEntity = self.entity
        self.state.setInspector(AnyView(Inspector(entity: self.entity)))
    }
}
