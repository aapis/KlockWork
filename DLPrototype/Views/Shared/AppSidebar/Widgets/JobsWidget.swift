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
        public let company: Company
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RowButton(text: self.company.name ?? "_COMPANY_NAME", alive: self.company.alive, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Text(self.company.abbreviation ?? "XXX")
                            .foregroundStyle(self.company.backgroundColor.isBright() ? Theme.base : .white)
                            .opacity(0.7)
                            .padding(.leading)
                        Spacer()
                        RowAddNavLink(
                            title: "+ Person",
                            target: AnyView(EmptyView())
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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.company.projects?.allObjects as? [Project] ?? [], id: \.objectID) { project in
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
        }
    }

    struct SingleProject: View {
        public let project: Project
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false
        @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RowButton(text: self.project.name ?? "_PROJECT_NAME", alive: self.project.alive, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.project.jobs?.allObjects as? [Job] ?? [], id: \.objectID) { job in
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
                RowButton(text: self.job.title ?? self.job.jid.string, alive: self.job.alive, callback: {
                    self.state.session.setJob(self.job)
                }, isPresented: $isPresented)
                .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                                .frame(height: 50)
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
                            }
                            .padding(.leading, 15)
                        }
                    }
                }
            }
            .background(self.job.alive ? self.highlighted ? self.job.backgroundColor.opacity(0.9) : self.job.backgroundColor : .gray.opacity(0.8))
            .foregroundStyle((self.job.alive ? self.job.backgroundColor : .gray).isBright() ? Theme.base : .white)
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
                EntityRowButton(text: "\(self.tasks.count) Tasks", isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        RowAddNavLink(
                            title: "+ Task",
                            target: AnyView(EmptyView())
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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.tasks, id: \.objectID) { task in
                                    if task.content != nil {
                                        Button {
                                            self.state.to(.taskDetail)
                                        } label: {
                                            Text(task.content!)
                                        }
                                        .buttonStyle(.plain)
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
                EntityRowButton(text: "\(self.notes.count) Notes", isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        RowAddNavLink(
                            title: "+ Note",
                            target: AnyView(EmptyView())
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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.notes, id: \.objectID) { note in
                                    if note.title != nil {
                                        Button {
                                            self.state.to(.taskDetail)
                                        } label: {
                                            Text(note.title!)
                                        }
                                        .buttonStyle(.plain)
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
                EntityRowButton(text: "\(self.definitions.count) Definitions", isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        RowAddNavLink(
                            title: "+ Definition",
                            target: AnyView(EmptyView())
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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.definitions, id: \.objectID) { def in
                                    if def.definition != nil {
                                        Button {
//                                            self.state.to(.taskDetail)
                                        } label: {
                                            Text(def.definition ?? "_NO_DEFINITION")
                                        }
                                        .buttonStyle(.plain)
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
        }
    }

    struct People: View {
        @EnvironmentObject private var state: Navigation
        public let entity: Company
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RowButton(text: "People", alive: self.entity.alive, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        RowAddNavLink(
                            title: "+ Task",
                            target: AnyView(EmptyView())
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
                                .frame(height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.entity.people?.allObjects as? [Person] ?? [], id: \.objectID) { person in
                                    if person.name != nil {
                                        Button {
                                            self.state.to(.taskDetail)
                                        } label: {
                                            Text(person.name!)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.leading, 15)
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
                    ZStack {
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
                ZStack {
                    Theme.base.opacity(0.6).blendMode(.softLight)
                    HStack(alignment: .center, spacing: 8) {
                        ZStack {
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
}
