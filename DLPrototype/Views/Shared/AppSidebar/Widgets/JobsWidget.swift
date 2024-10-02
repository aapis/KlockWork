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
    @FetchRequest public var companies: FetchedResults<Company>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(self.companies, id: \.objectID) { company in
                UnifiedSidebar.SingleCompany(company: company)
            }
        }
    }
}

extension JobsWidgetRedux {
    public init() {
        _companies = CoreDataCompanies.fetch(true)
    }
}

struct UnifiedSidebar {
    struct SingleCompany: View {
        public let company: Company
        @State private var isPresented: Bool = false
        @State private var highlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RowButton(text: self.company.name ?? "_COMPANY_NAME", alive: self.company.alive, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
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
                                    SingleProject(project: project)
                                }
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

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RowButton(text: self.project.name ?? "_PROJECT_NAME", alive: self.project.alive, isPresented: $isPresented)
                    .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
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
                                ForEach(self.project.jobs?.allObjects as? [Job] ?? [], id: \.objectID) { job in
                                    SingleJob(job: job)
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

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RowButton(text: self.job.title ?? self.job.jid.string, alive: self.job.alive, callback: {
                    self.state.session.setJob(self.job)
                }, isPresented: $isPresented)
                .useDefaultHover({ inside in self.highlighted = inside})

                if self.isPresented {
                    HStack(alignment: .center, spacing: 0) {
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
                                if let tasks = self.job.tasks?.allObjects as? [LogTask] {
                                    Tasks(job: self.job, tasks: tasks)
                                }
                                if let notes = self.job.mNotes?.allObjects as? [Note] {
                                    Notes(job: self.job, notes: notes)
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
                RowButton(text: "Tasks", alive: self.job.alive, isPresented: $isPresented)
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
                RowButton(text: "Notes", alive: self.job.alive, isPresented: $isPresented)
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
            }
            .padding(8)
            .buttonStyle(.plain)
        }
    }
}
