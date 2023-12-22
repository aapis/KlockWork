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

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 1) {
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
//                    if searchQuery.count >= 2 {
//                        onSubmit()
//                    } else {
//                        onReset()
//                    }
                    
                    if searchQuery.isEmpty {
                        onReset()
                    }
                }
            }
            
            if activeSearchText.filter({"0123456789".contains($0)}) != "" {
                GridRow {
                    Suggestions(searchText: $activeSearchText)
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
                FancyDivider()
                FancyGenericToolbar(buttons: buttons, standalone: true, location: .content)
            }
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension FindDashboard {
    private func onSubmit() -> Void {
        if activeSearchText != "" {
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
        
        createTabs()
    }

    private func onReset() -> Void {
        searching = false
        nav.session.search.reset()
    }

    private func actionOnAppear() -> Void {
        counts = (
            CoreDataRecords(moc: moc).countAll(),
            CoreDataJob(moc: moc).countAll(),
            CoreDataTasks(moc: moc).countAll(),
            CoreDataProjects(moc: moc).countAll()
        )
    }
    
    private func actionOnDisappear() -> Void {
        
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
                HStack {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                }
                .padding([.top, .bottom], 20)
//                .onDisappear(perform: actionOnDisappear)
            }
        }
    }
    
    struct Suggestions: View {
        @Binding public var searchText: String

        // @TODO: should support any NSManagedObject in the future so we can suggest projects, tasks, etc
        @State private var jobs: [Job] = []
        
        private var columns: [GridItem] {
            Array(repeating: .init(.flexible(minimum: 100)), count: 2)
        }
        
        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("\(jobs.count) Suggestions for query \"\(searchText.filter {"0123456789".contains($0)})\"")

                HStack(spacing: 1) {
                    ForEach(jobs) { job in
                        FancyButtonv2(text: job.jid.string, action: {choose(job.id_int())}, icon: "hammer", fgColour: job.fgColour(), bgColour: job.colour_from_stored(), showIcon: true, size: .link)
                                .padding(3)
                                .background(job.colour_from_stored())
                                .frame(maxWidth: 100)
                    }
                    Spacer()
                }
                .padding()
            }
            .background(Theme.rowColour)
            .onAppear(perform: actionOnAppear)
            .onChange(of: searchText) { query in
                actionOnAppear()
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
                if !loaded {
                    Loading()
                } else {
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
            }
            .onAppear(perform: actionOnAppear)
        }
        
        init(_ text: String) {
            let rr: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
            rr.predicate = NSPredicate(format: "message CONTAINS[c] %@", text)
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
            req.predicate = NSPredicate(format: "(body CONTAINS[c] %@ OR title CONTAINS[c] %@) AND alive = true", text, text)
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
                NSSortDescriptor(keyPath: \Job.jid, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        }
    }
}

extension FindDashboard.Suggestions {
    private func actionOnAppear() -> Void {
        let intsOnly = searchText.filter {"0123456789".contains($0)}
        
        if !intsOnly.isEmpty {
            jobs = CoreDataJob(moc: moc)
                .startsWith(intsOnly)
                .sorted(by: {$0.jid < $1.jid})
        }
    }
    
    private func choose(_ jid: Int) -> Void {
        searchText = String(jid)
    }
}

extension FindDashboard.RecordsMatchingString {
    private func actionOnAppear() -> Void {
        if entities.count > 0 {
            loaded = true
        }
    }
}
