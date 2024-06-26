//
//  Inspector.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI


public struct Inspector: View, Identifiable {
    public let id: UUID = UUID()
    public var entity: NSManagedObject

    private let panelWidth: CGFloat = 400
    private var job: Job? = nil
    private var project: Project? = nil
    private var record: LogRecord? = nil
    private var company: Company? = nil
    private var person: Person? = nil
    private var note: Note? = nil
    private var task: LogTask? = nil

    @EnvironmentObject public var nav: Navigation

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "Inspector")
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: {nav.session.search.cancel() ; nav.setInspector()},
                    icon: "xmark",
                    showLabel: false,
                    size: .tiny,
                    type: .clear
                )
            }
            Divider()
                .padding(.bottom, 10)

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
            } else {
                Text("Unable to inspect this item")
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: panelWidth)
    }

    init(entity: NSManagedObject) {
        self.entity = entity

        switch self.entity {
        case let en as Job: self.job = en
        case let en as Project: self.project = en
        case let en as LogRecord: self.record = en
        case let en as Company: self.company = en
        case let en as Person: self.person = en
        case let en as Note: self.note = en
        case let en as LogTask: self.task = en
        default: print("[error] FindDashboard.Inspector Unknown entity type=\(self.entity)")
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

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "camera.filters").symbolRenderingMode(.hierarchical)
                        ZStack {
                            Theme.base
                            item.colour_from_stored()
                        }
                        .frame(width: 15, height: 15)
                        Text(item.colour_from_stored().description)
                            .contextMenu {
                                Button {
                                    ClipboardHelper.copy(item.colour_from_stored().description)
                                } label: {
                                    Text("Copy colour HEX to clipboard")
                                }
                            }
                        Spacer()
                    }
                    .help("Colour: \(item.colour_from_stored().description)")
                    Divider()

                    Context(item: item)

                    Spacer()
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 10) {
                            FancyButtonv2(
                                text: "Open",
                                action: {nav.session.search.cancel() ; nav.setInspector()},
                                icon: "arrow.right.square.fill",
                                showLabel: true,
                                size: .link,
                                type: .clear,
                                redirect: AnyView(JobDashboard(defaultSelectedJob: item)),
                                pageType: .jobs,
                                sidebar: AnyView(JobDashboardSidebar())
                            )

                            FancyButtonv2(
                                text: nav.session.job != nil ?
                                (
                                    nav.session.job == item ? "Current job" : "Overwrite Active Job"
                                ):
                                    "Set to Active Job",
                                action: {nav.session.job = item},
                                icon: "arrow.right.square.fill",
                                showLabel: true,
                                size: .link,
                                type: .clear
                            )
                            .disabled(nav.session.job == item)
                            .help(nav.session.job != nil ? "Current: \(nav.session.job!.jid)" : "Flags this as the current job on other pages and in widgets.")
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
                        Image(systemName: "doc.text.fill").symbolRenderingMode(.hierarchical)
                        Text("Full message:")
                        Spacer()
                    }
                    Divider()
                    Text(message)
                        .padding(.leading, 25)
                        .contextMenu {
                            Button("Copy") {
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

                if let date = item.created {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.plus").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Created: \(date.description)")
                    Divider()
                }

                Spacer()
                if let company = item.company {
                    HStack(alignment: .top, spacing: 10) {
                        FancyButtonv2(
                            text: "Open project",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear,
                            redirect: AnyView(CompanyDashboard(company: company)),
                            pageType: .companies,
                            sidebar: AnyView(DefaultCompanySidebar())
                        )
                    }
                }
            }
        }
    }

    struct InspectingCompany: View {
        public var item: Company

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Company")
                    Spacer()
                }
                .help("Type: Company entity")
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

                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    FancyButtonv2(
                        text: "Open company",
                        icon: "arrow.right.square.fill",
                        showLabel: true,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(CompanyDashboard(company: item)),
                        pageType: .companies,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                }
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
                if let company = item.company {
                    HStack(alignment: .top, spacing: 10) {
                        FancyButtonv2(
                            text: "Open",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear,
                            redirect: AnyView(CompanyDashboard(company: company)),
                            pageType: .companies,
                            sidebar: AnyView(DefaultCompanySidebar())
                        )
                    }
                }
            }
        }
    }

    struct InspectingNote: View {
        public var item: Note

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "questionmark.square.fill").symbolRenderingMode(.hierarchical)
                    Text("Type: Note")
                    Spacer()
                }
                .help("Type: Note entity")
                Divider()

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

                if let date = item.completedDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
                        Spacer()
                    }
                    .help("Completed on \(date.description)")
                    Divider()
                }

                if let date = item.cancelledDate {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "calendar.badge.clock").symbolRenderingMode(.hierarchical)
                        Text(date.description)
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
}

