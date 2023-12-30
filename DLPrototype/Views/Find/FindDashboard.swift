//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FindDashboard: View {
    @Binding public var searching: Bool
    public var location: WidgetLocation = .content

    @State private var searchText: String = ""
    @State private var activeSearchText: String = ""
    @State private var showRecords: Bool = true
    @State private var showNotes: Bool = true
    @State private var showTasks: Bool = true
    @State private var showProjects: Bool = true
    @State private var showJobs: Bool = true
    @State private var showCompanies: Bool = true
    @State private var showPeople: Bool = true
    @State private var allowAlive: Bool = true
    @State private var counts: (Int, Int, Int, Int) = (0, 0, 0, 0)
    @State private var advancedSearchResults: [SearchLanguage.Results.Result] = []
    @State private var buttons: [ToolbarButton] = []
    @State private var loading: Bool = false
    @State private var showingTypes: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var nav: Navigation

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: 2)
    }

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 1) {
            GridRow {
                ZStack(alignment: .topLeading) {
                    SearchBar(
                        text: $activeSearchText,
                        disabled: false,
                        placeholder: location == .content ? "Search \(counts.0) records, \(counts.1) jobs, \(counts.2) tasks and \(counts.3) projects" : "Search for anything",
                        onSubmit: onSubmit,
                        onReset: onReset
                    )

                    if activeSearchText.count == 0 {
                        VStack(alignment: .trailing) {
                            Spacer()
                            HStack(spacing: 5) {
                                Spacer()
                                FancyButtonv2(
                                    text: "Entities",
                                    action: {showingTypes.toggle()},
                                    icon: showingTypes ? "arrow.up.square.fill" : "arrow.down.square.fill",
                                    showLabel: false,
                                    size: .tiny,
                                    type: .clear
                                )
                                .help("Choose the entities you want to search")
                                .padding(.trailing, 15)
                            }
                        }
                        .frame(height: 28)
                    }
                }
            }
            
            if !searching && activeSearchText.count >= 2 {
                GridRow {
                    if location == .content {
                        HStack(alignment: .top, spacing: 1) {
                            Suggestions(
                                searchText: $activeSearchText,
                                publishedOnly: $allowAlive,
                                showRecords: $showRecords,
                                showNotes: $showNotes,
                                showTasks: $showTasks,
                                showProjects: $showProjects,
                                showJobs: $showJobs,
                                showCompanies: $showCompanies,
                                showPeople: $showPeople,
                                location: location
                            )
                            
                            if nav.session.search.inspectingEntity != nil {
                                Inspector(entity: nav.session.search.inspectingEntity!)
                            }
                        }
                    } else if location == .sidebar {
                        Suggestions(
                            searchText: $activeSearchText,
                            publishedOnly: $allowAlive,
                            showRecords: $showRecords,
                            showNotes: $showNotes,
                            showTasks: $showTasks,
                            showProjects: $showProjects,
                            showJobs: $showJobs,
                            showCompanies: $showCompanies,
                            showPeople: $showPeople,
                            location: location
                        )
                    }
                }
            }
            
            if showingTypes {
                if location == .content {
                    GridRow {
                        ZStack(alignment: .leading) {
                            Theme.subHeaderColour

                            HStack {
                                Toggle("Records", isOn: $showRecords)
                                Toggle("Notes", isOn: $showNotes)
                                Toggle("Tasks", isOn: $showTasks)
                                Toggle("Projects", isOn: $showProjects)
                                Toggle("Jobs", isOn: $showJobs)
                                Toggle("Companies", isOn: $showCompanies)
                                Toggle("People", isOn: $showPeople)
                                Spacer()
                                Toggle("Published Only", isOn: $allowAlive)
                            }
                            .padding([.leading, .trailing], 10)
                        }
                    }
                    .frame(height: 40)
                } else if location == .sidebar {
                    GridRow {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            Toggle("Records", isOn: $showRecords)
                            Toggle("Notes", isOn: $showNotes)
                            Toggle("Tasks", isOn: $showTasks)
                            Toggle("Projects", isOn: $showProjects)
                            Toggle("Jobs", isOn: $showJobs)
                            Toggle("Companies", isOn: $showCompanies)
                            Toggle("People", isOn: $showPeople)
                            Toggle("Published Only", isOn: $allowAlive)
                        }
                        .padding(10)
                    }
                    .background(location == .sidebar ? Theme.rowColour : Theme.subHeaderColour)
                }
            }

            if searching {
                if loading {
                    Loading()
                } else {
                    FancyDivider()
                    FancyGenericToolbar(buttons: buttons, standalone: true, location: .content)
                    Spacer()
                }
            }
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: searchText) { searchQuery in
            if searchText != searchQuery {
                if searchQuery.count >= 2 {
                    onSubmit()
                } else {
                    onReset()
                }
            }
        }
        .onChange(of: activeSearchText) { searchQuery in
            nav.session.search.inspectingEntity = nil

            if searchQuery.isEmpty {
                onReset()
            }
        }
        .onChange(of: nav.session.search.inspectingEntity) { entity in
            if location == .sidebar {
                if entity != nil {
                    nav.setInspector(AnyView(Inspector(entity: entity!)))
                } else {
                    nav.setInspector()
                }
            }
        }
    }
}

extension FindDashboard {
    private func onSubmit() -> Void {
        if !activeSearchText.isEmpty {
            searching = true
        } else {
            searching = false
        }
        
        // Search appearing in other views should only provide suggestions due to lack of visual space
        if location == .content {
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
            createTabs()
        }

        searchText = activeSearchText
        loading = false
    }

    private func onReset() -> Void {
        searching = false
        nav.session.search.reset()
        nav.session.search.inspectingEntity = nil
        nav.setInspector()
        loading = false
    }

    private func actionOnAppear() -> Void {
        if location == .content {
            counts = (
                CoreDataRecords(moc: moc).countAll(),
                CoreDataJob(moc: moc).countAll(),
                CoreDataTasks(moc: moc).countAll(),
                CoreDataProjects(moc: moc).countAll()
            )
        }

        if location == .content {
            showingTypes = true
        }
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
                                    viewRequiresColumns: viewRequiresColumns
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
            jr.predicate = NSPredicate(format: "(uri CONTAINS[c] %@ OR jid.stringValue BEGINSWITH %@) AND alive = true", text, text)
            jr.sortDescriptors = [
                NSSortDescriptor(keyPath: \Job.created, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: jr, animation: .easeInOut)
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
