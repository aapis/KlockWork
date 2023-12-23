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
                    if searchQuery.isEmpty {
                        onReset()
                    }
                }
            }
            
            if !searching && activeSearchText.count >= 2 {
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
                Spacer()
                HStack {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                }
                .padding([.top, .bottom], 20)
                Spacer()
//                .onDisappear(perform: actionOnDisappear)
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
                                            FancyButtonv2(text: item.jid.string, action: {choose(item.id_int())}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                    NSSortDescriptor(keyPath: \Job.jid, ascending: true),
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
                                            FancyButtonv2(text: item.name ?? "", action: {choose(Int(item.pid))}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                                            FancyButtonv2(text: item.title ?? "", action: {}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                                            FancyButtonv2(text: item.content ?? "", action: {}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                    format: "content CONTAINS %@",
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
                                            FancyButtonv2(text: item.message ?? "", action: {}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                    NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: true),
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
                                            FancyButtonv2(text: item.name ?? "", action: {}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                                            FancyButtonv2(text: item.name ?? "", action: {}, icon: "arrow.right.square.fill", fgColour: .white, showIcon: true, size: .link, type: .clear)
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
                    NSSortDescriptor(keyPath: \Person.name, ascending: true),
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

extension FindDashboard.Suggestions.SuggestedJobs {
    private func choose(_ jid: Int) -> Void {
        searchText = String(jid)
    }
}

extension FindDashboard.Suggestions.SuggestedProjects {
    private func choose(_ jid: Int) -> Void {
        searchText = String(jid)
    }
}

extension FindDashboard.Suggestions.SuggestedNotes {
    private func choose(_ jid: Int) -> Void {
        searchText = String(jid)
    }
}

extension FindDashboard.RecordsMatchingString {
    private func actionOnAppear() -> Void {
        print("DERPO entities.count=\(entities.count)")
        if entities.count > 0 {
            loaded = true
        }
    }
}
