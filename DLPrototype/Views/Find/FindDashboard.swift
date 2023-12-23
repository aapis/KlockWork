//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct RecentSearch: Identifiable {
    let id: UUID = UUID()
    var term: String
}

struct FindDashboard: View {
    @Binding public var searching: Bool

    @State private var searchText: String = ""
    @State private var activeSearchText: String = ""
    @State private var showRecords: Bool = true
    @State private var showNotes: Bool = true
    @State private var showTasks: Bool = true
    @State private var showProjects: Bool = true
    @State private var showJobs: Bool = true
    @State private var allowAlive: Bool = true
    @State private var counts: (Int, Int, Int, Int) = (0, 0, 0, 0)
    @State private var advancedSearchResults: [SearchLanguage.Results.Result] = []
    @State private var buttons: [ToolbarButton] = []
    @State private var loading: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 1) {
            GridRow {
                SearchBar(
                    text: $activeSearchText,
                    disabled: false,
                    placeholder: "Search \(counts.0) records, \(counts.1) jobs, \(counts.2) tasks and \(counts.3) projects",
                    onSubmit: onSubmit,
                    onReset: onReset
                )
                .onChange(of: searchText) { searchQuery in
                    if searchQuery.count >= 2 {
                        onSubmit()
                    } else {
                        onReset()
                    }
                }
                .onChange(of: activeSearchText) { searchQuery in
                    nav.session.search.inspectingEntity = nil

                    if searchQuery.isEmpty {
                        onReset()
                    }
                }
            }
            
            if !searching && activeSearchText.count >= 2 {
                GridRow {
                    HStack(alignment: .top, spacing: 1) {
                        Suggestions(searchText: $activeSearchText)
                        
                        if nav.session.search.inspectingEntity != nil {
                            Inspector()
                        }
                    }
                }
            }
            
            GridRow {
                ZStack(alignment: .leading) {
                    Theme.subHeaderColour
                    
                    HStack {
                        Toggle("Records", isOn: $showRecords)
                        Toggle("Notes", isOn: $showNotes)
                        Toggle("Tasks", isOn: $showTasks)
                        Toggle("Projects", isOn: $showProjects)
                        Toggle("Jobs", isOn: $showJobs)
                        // TODO: re-add at some point
//                        Spacer()
//                        Toggle("Show alive", isOn: $allowAlive)
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
            .frame(height: 40)
            
            if searching {
                if loading {
                    Loading()
                } else {
                    FancyDivider()
                    FancyGenericToolbar(buttons: buttons, standalone: true, location: .content)
                }
            }
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension FindDashboard {
    private func onSubmit() -> Void {
        if !activeSearchText.isEmpty {
            searching = true
        } else {
            searching = false
        }

        if searching {
            let parser = SearchLanguage.Parser(with: activeSearchText).parse()

            if !parser.components.isEmpty {
                nav.session.search.components = parser.components
            }
            
            advancedSearchResults = nav.session.search.results()
        } else {
            advancedSearchResults = []
        }
        
        nav.session.search.text = activeSearchText
        searchText = activeSearchText

        // @TODO: find best place to call/construct tabs! This loads data but locks UI
        DispatchQueue.background(background: {
            loading = true
            createTabs()
        }, completion: {
            loading = false
        })
        
    }

    private func onReset() -> Void {
        searching = false
        nav.session.search.reset()
        loading = false
    }

    private func actionOnAppear() -> Void {
        counts = (
            CoreDataRecords(moc: moc).countAll(),
            CoreDataJob(moc: moc).countAll(),
            CoreDataTasks(moc: moc).countAll(),
            CoreDataProjects(moc: moc).countAll()
        )
    }
    
    private func createTabs() -> Void {
        // @TODO: convert to set or otherwise mitigate requirement to clear buttons here
        buttons = []

        if showRecords {
            buttons.append(
                ToolbarButton(
                    id: 0,
                    helpText: "Records",
                    label: AnyView(
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .font(.title2)
                            Text("Records")
                        }
                    ),
                    contents: AnyView(RecordsMatchingString(searchText))
                )
            )
        }
        
        if showNotes {
            buttons.append(
                ToolbarButton(
                    id: 1,
                    helpText: "Notes",
                    label: AnyView(
                        HStack {
                            Image(systemName: "note.text")
                                .font(.title2)
                            Text("Notes")
                        }
                    ),
                    contents: AnyView(NotesMatchingString(searchText))
                )
            )
        }
        
        if showTasks {
            buttons.append(
                ToolbarButton(
                    id: 2,
                    helpText: "Tasks",
                    label: AnyView(
                        HStack {
                            Image(systemName: "checklist")
                                .font(.title2)
                            Text("Tasks")
                        }
                    ),
                    contents: AnyView(TasksMatchingString(searchText))
                )
            )
        }
        
        if showProjects {
            buttons.append(
                ToolbarButton(
                    id: 3,
                    helpText: "Projects",
                    label: AnyView(
                        HStack {
                            Image(systemName: "folder")
                                .font(.title2)
                            Text("Projects")
                        }
                    ),
                    contents: AnyView(ProjectsMatchingString(searchText))
                )
            )
        }
        
        if showJobs {
            buttons.append(
                ToolbarButton(
                    id: 4,
                    helpText: "Jobs",
                    label: AnyView(
                        HStack {
                            Image(systemName: "hammer")
                                .font(.title2)
                            Text("Jobs")
                        }
                    ),
                    contents: AnyView(JobsMatchingString(searchText))
                )
            )
        }
    }
}

extension FindDashboard {
    struct Loading: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                }
                .padding([.top, .bottom], 20)
                Spacer()
            }
        }
    }
    
    struct Inspector: View {
        private let panelWidth: CGFloat = 400

        @State public var entity: NSManagedObject? = nil
        @State private var job: Job? = nil
        @State private var project: Project? = nil
        @State private var record: LogRecord? = nil
        @State private var company: Company? = nil
        @State private var person: Person? = nil
        @State private var note: Note? = nil
        @State private var task: LogTask? = nil

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            FancySubTitle(text: "Inspector")
                            Spacer()
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
                        }
                    }

                    Spacer()
                    FancyButtonv2(text: "Close", action: {nav.session.search.inspectingEntity = nil}, icon: "xmark", showLabel: false, size: .tiny, type: .clear)
                        .opacity(0.6)
                }
                Spacer()
            }
            .padding()
            .background(Theme.rowColour.opacity(0.7))
            .frame(maxWidth: panelWidth)
            .onAppear(perform: actionOnAppear)
            .onChange(of: nav.session.search.inspectingEntity) { newEntity in
                actionOnAppear()
            }
        }
        
        struct InspectingJob: View {
            public var item: Job
            
            var body: some View {
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
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "camera.filters").symbolRenderingMode(.hierarchical)
                        Rectangle()
                            .frame(width: 15, height: 15)
                            .background(item.colour_from_stored())
                        Spacer()
                    }
                    .help("Colour: \(item.colour_from_stored().description)")
                    Divider()

                    Spacer()
                    HStack(alignment: .top, spacing: 10) {
                        // TODO: throws a "serious application error" on load, issue probably in JobDashboard tho
                        FancyButtonv2(
                            text: "Open",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear,
                            redirect: AnyView(JobDashboard(defaultSelectedJob: item)),
                            pageType: .jobs,
                            sidebar: AnyView(JobDashboardSidebar())
                        )
                    }
                }
            }
        }
        
        struct InspectingRecord: View {
            public var item: LogRecord
            
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
                    
                    Spacer()
                    HStack(alignment: .top, spacing: 10) {
                        FancyButtonv2(
                            text: "Open day",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear
                        )
                    }
                }
            }
        }
        
        struct InspectingProject: View {
            public var item: Project
            
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
                    HStack(alignment: .top, spacing: 10) {
                        FancyButtonv2(
                            text: "Open project",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear
                        )
                    }
                }
            }
        }
        
        struct InspectingCompany: View {
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
                            type: .clear
                        )
                    }
                }
            }
        }
        
        struct InspectingPerson: View {
            public var item: Person
            
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
                    HStack(alignment: .top, spacing: 10) {
                        FancyButtonv2(
                            text: "Open",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear
                        )
                    }
                }
            }
        }
        
        struct InspectingNote: View {
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
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear
                        )
                    }
                }
            }
        }
        
        struct InspectingTask: View {
            public var item: LogTask
            
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
                    HStack(alignment: .top, spacing: 10) {
                        FancyButtonv2(
                            text: "Open",
                            icon: "arrow.right.square.fill",
                            showLabel: true,
                            size: .link,
                            type: .clear
                        )
                    }
                }
            }
        }
    }
    
    struct Suggestions: View {
        @Binding public var searchText: String

        private var columns: [GridItem] {
            Array(repeating: .init(.flexible(minimum: 100)), count: 1)
        }
        
        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            VStack {
                if searchText.count >= 2 {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Text("Hit \"return\" to perform a search and see all results")
                                Spacer()
                            }
                            
                            // @TODO: reduce this with a loop, each view is basically identical...
                            SuggestedJobs(searchText: $searchText)
                            SuggestedProjects(searchText: $searchText)
                            SuggestedNotes(searchText: $searchText)
                            SuggestedTasks(searchText: $searchText)
                            SuggestedRecords(searchText: $searchText)
                            SuggestedCompanies(searchText: $searchText)
                            SuggestedPeople(searchText: $searchText)
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.rowColour)
        }
        
        struct SuggestedJobs: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Job>
            
            @EnvironmentObject public var nav: Navigation
            
            var body: some View {
                if items.count > 0 {
                    VStack(alignment: .leading) {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) Jobs")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        
                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.jid.string, action: {choose(
                                                item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<Job> = Job.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Job.created, ascending: false),
                ]
                req.predicate = NSPredicate(format: "alive = true && jid.string BEGINSWITH %@", _searchText.wrappedValue)
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedProjects: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Project>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) Projects")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.name ?? "", action: {choose(item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<Project> = Project.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Project.name, ascending: true),
                ]
                req.predicate = NSPredicate(
                    format: "alive = true && (name BEGINSWITH %@ || pid BEGINSWITH %@)",
                    _searchText.wrappedValue,
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedNotes: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Note>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) Notes")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        
                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.title ?? "", action: {choose(item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                                .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<Note> = Note.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Note.title, ascending: true),
                ]
                req.predicate = NSPredicate(
                    format: "alive = true && (body CONTAINS[cd] %@ || title CONTAINS[cd] %@)",
                    _searchText.wrappedValue,
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedTasks: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<LogTask>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) Tasks")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.content ?? "", action: {choose(item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                                .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<LogTask> = LogTask.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \LogTask.created, ascending: true),
                ]
                req.predicate = NSPredicate(
                    format: "content CONTAINS[cd] %@",
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedRecords: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<LogRecord>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) Records")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.message ?? "", action: {choose(item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                                .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false),
                ]
                req.predicate = NSPredicate(
                    format: "message CONTAINS[cd] %@",
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedCompanies: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Company>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) Companies")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.name ?? "", action: {choose(item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                                .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<Company> = Company.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Company.name, ascending: true),
                ]
                req.predicate = NSPredicate(
                    format: "alive = true && name CONTAINS[cd] %@",
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedPeople: View {
            @Binding public var searchText: String
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Person>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            HStack(spacing: 1) {
                                Text("Showing \(items.prefix(5).count)/\(items.count) People")
                                    .font(Theme.fontSubTitle)
                                Spacer()
                                Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .padding()
                            .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(text: item.name ?? "", action: {choose(item)}, icon: "questionmark.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
                                                .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>) {
                _searchText = searchText
                
                let req: NSFetchRequest<Person> = Person.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Person.created, ascending: false),
                ]
                req.predicate = NSPredicate(
                    format: "name CONTAINS[cd] %@",
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
    }
    
    struct RecordsMatchingString: View {
        @State private var text: String = ""
        @State private var loaded: Bool = false
        @FetchRequest private var entities: FetchedResults<LogRecord>

        private let viewRequiresColumns: Set<RecordTableColumn> = [.extendedTimestamp, .job]

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Records")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities) { item in
                                let entry = Entry(
                                    timestamp: item.timestamp!,
                                    job: item.job!,
                                    message: item.message!
                                )
                                
                                LogRow(
                                    entry: entry,
                                    index: entities.firstIndex(of: item),
                                    colour: Color.fromStored(item.job!.colour ?? Theme.rowColourAsDouble),
                                    viewRequiresColumns: viewRequiresColumns,
                                    selectedJob: $text
                                )
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 records")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
            .onAppear(perform: actionOnAppear)
        }
        
        init(_ text: String) {
            let rr: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
            rr.predicate = NSPredicate(format: "message CONTAINS[cd] %@", text)
            rr.sortDescriptors = [
                NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: rr, animation: .easeInOut)
        }
    }
    
    struct NotesMatchingString: View {
        @FetchRequest private var entities: FetchedResults<Note>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Notes")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities) { item in
                                NoteRow(note: item)
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 Notes")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }
        
        init(_ text: String) {
            let req: NSFetchRequest<Note> = Note.fetchRequest()
            req.predicate = NSPredicate(format: "(body CONTAINS[cd] %@ OR title CONTAINS[cd] %@) AND alive = true", text, text)
            req.sortDescriptors = [
                NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: req, animation: .easeInOut)
        }
    }
    
    struct TasksMatchingString: View {
        @FetchRequest private var entities: FetchedResults<LogTask>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Tasks")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities) { item in
                                TaskView(task: item, showJobId: true, showCreated: true, showUpdated: true, showCompleted: true, colourizeRow: true)
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 Tasks")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }
        
        init(_ text: String) {
            let tr: NSFetchRequest<LogTask> = LogTask.fetchRequest()
            tr.predicate = NSPredicate(format: "content CONTAINS[c] %@", text)
            tr.sortDescriptors = [
                NSSortDescriptor(keyPath: \LogTask.created, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: tr, animation: .easeInOut)
        }
    }
    
    struct ProjectsMatchingString: View {
        @FetchRequest private var entities: FetchedResults<Project>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Projects")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities) { item in
                                ProjectRow(project: item)
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 Projects")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }
        
        init(_ text: String) {
            let pr: NSFetchRequest<Project> = Project.fetchRequest()
            pr.predicate = NSPredicate(format: "name CONTAINS[c] %@ AND alive = true", text)
            pr.sortDescriptors = [
                NSSortDescriptor(keyPath: \Project.created, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: pr, animation: .easeInOut)
        }
    }
    
    struct JobsMatchingString: View {
        @FetchRequest private var entities: FetchedResults<Job>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Jobs")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities) { item in
                                JobRow(job: item, colour: item.colour_from_stored())
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 Jobs")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }
        
        init(_ text: String) {
            let jr: NSFetchRequest<Job> = Job.fetchRequest()
            jr.predicate = NSPredicate(format: "(uri CONTAINS[c] %@ OR jid.string CONTAINS[c] %@) AND alive = true", text, text)
            jr.sortDescriptors = [
                NSSortDescriptor(keyPath: \Job.created, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        }
    }
}

extension FindDashboard.Suggestions.SuggestedJobs {
    private func choose(_ item: Job) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Suggestions.SuggestedProjects {
    private func choose(_ item: Project) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Suggestions.SuggestedNotes {
    private func choose(_ item: Note) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Suggestions.SuggestedTasks {
    private func choose(_ item: LogTask) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Suggestions.SuggestedCompanies {
    private func choose(_ item: Company) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Suggestions.SuggestedPeople {
    private func choose(_ item: Person) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Suggestions.SuggestedRecords {
    private func choose(_ item: LogRecord) -> Void {
        if nav.session.search.inspectingEntity != nil {
            nav.session.search.inspectingEntity = nil
        }

        nav.session.search.inspectingEntity = item
    }
}

extension FindDashboard.Inspector {
    private func actionOnAppear() -> Void {
        if let e = nav.session.search.inspectingEntity {
            entity = e
            
            switch entity {
            case let en as Job: job = en
            case let en as Project: project = en
            case let en as LogRecord: record = en
            case let en as Company: company = en
            case let en as Person: person = en
            case let en as Note: note = en
            case let en as LogTask: task = en
            default: print("[error] FindDashboard.Inspector Unknown entity type=\(e)")
            }
        }
    }
}

extension FindDashboard.RecordsMatchingString {
    private func actionOnAppear() -> Void {
        if entities.count > 0 {
            loaded = true
        }
    }
}
