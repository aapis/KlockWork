//
//  Suggestions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension FindDashboard {
    struct Suggestions: View {
        @Binding public var searchText: String
        @Binding public var publishedOnly: Bool
        @Binding public var showRecords: Bool
        @Binding public var showNotes: Bool
        @Binding public var showTasks: Bool
        @Binding public var showProjects: Bool
        @Binding public var showJobs: Bool
        @Binding public var showCompanies: Bool
        @Binding public var showPeople: Bool
        public var location: WidgetLocation

        @AppStorage("CreateEntitiesWidget.isSearching") private var isSearching: Bool = false

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack {
                if searchText.count >= 2 || isSearching {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                if location == .content {
                                    Text("Hit \"return\" to perform a search and see all results")
                                } else {
                                    Text("Suggestions for your query")
                                }
                                Spacer()
                            }

                            // @TODO: reduce this with a loop, each view is basically identical...
                            if showJobs {SuggestedJobs(searchText: $searchText, publishedOnly: $publishedOnly)}
                            if showProjects {SuggestedProjects(searchText: $searchText, publishedOnly: $publishedOnly)}
                            if showNotes {SuggestedNotes(searchText: $searchText, publishedOnly: $publishedOnly)}
                            if showTasks {SuggestedTasks(searchText: $searchText)}
                            if showRecords {SuggestedRecords(searchText: $searchText, publishedOnly: $publishedOnly)}
                            if showCompanies {SuggestedCompanies(searchText: $searchText, publishedOnly: $publishedOnly)}
                            if showPeople {SuggestedPeople(searchText: $searchText)}
                        }
                    }
                    .padding()
                }
            }
            .background(location == .content ? Theme.rowColour : Color.clear)
            .onChange(of: isSearching) { status in
                nav.session.search.cancel()
                nav.setInspector()
            }
        }
        
        struct SuggestedJobs: View {
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
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
                            ZStack {
                                Theme.base
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
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        
                        if showChildren {
                            VStack(alignment: .leading) {
                                ForEach(items.prefix(5)) { item in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.jid.string,
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                            FancyButtonv2(
                                                text: item.jid.string,
                                                action: {setContext(item)},
                                                icon: "arrow.right.square.fill",
                                                showLabel: false,
                                                showIcon: true,
                                                size: .tinyLink,
                                                type: .clear
                                            )
                                            .help("Set as Active Job")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly

                let req: NSFetchRequest<Job> = Job.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Job.created, ascending: false),
                ]

                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive == true && (jid.stringValue BEGINSWITH %@ || jid.stringValue == %@ || title CONTAINS[c] %@ || overview CONTAINS[c] %@) && project.company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue,
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "(jid.stringValue BEGINSWITH %@ || jid.stringValue == %@ || title CONTAINS[c] %@ || overview CONTAINS[c] %@) && project.company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue,
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                }

                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedProjects: View {
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
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
                            ZStack {
                                Theme.base
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
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.name ?? "",
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                fgColour: .white,
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly
                
                let req: NSFetchRequest<Project> = Project.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Project.name, ascending: true),
                ]
                
                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive = true && (name BEGINSWITH %@ || pid BEGINSWITH %@) && company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "(name BEGINSWITH %@ || pid BEGINSWITH %@) && company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                }
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedNotes: View {
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
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
                            ZStack {
                                Theme.base
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
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        
                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.title ?? "",
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                fgColour: .white,
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                            FancyButtonv2(
                                                text: item.title ?? "",
                                                action: {setContext(item)},
                                                icon: "arrow.right.square.fill",
                                                showLabel: false,
                                                showIcon: true,
                                                size: .tinyLink,
                                                type: .clear
                                            )
                                            .help("Set associated job as Active Job")
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly
                
                let req: NSFetchRequest<Note> = Note.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Note.postedDate, ascending: false),
                ]
                
                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive = true && (body CONTAINS[cd] %@ || title CONTAINS[cd] %@) && mJob.project.company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "body CONTAINS[cd] %@ || title CONTAINS[cd] %@ && mJob.project.company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                }
                
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
                            ZStack {
                                Theme.base
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
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.content ?? "",
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                fgColour: .white,
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
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
                    format: "content CONTAINS[cd] %@ && owner.project.company.hidden == false",
                    _searchText.wrappedValue
                )
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedRecords: View {
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @State private var showAll: Bool = false
            @FetchRequest private var items: FetchedResults<LogRecord>
            
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                            self.showAll.toggle()
                        } label: {
                            ZStack {
                                Theme.base
                                HStack(spacing: 1) {
                                    Text(self.showAll ? "Showing \(items.count) Records" : "Showing \(items.prefix(5).count)/\(items.count) Records")
                                        .font(Theme.fontSubTitle)
                                    Spacer()
                                    Image(systemName: showChildren ? "minus.square.fill" : "plus.square.fill").symbolRenderingMode(.hierarchical)
                                        .font(.title2)
                                }
                                .padding()
                                .background(hover ? Theme.rowColour : Theme.subHeaderColour)
                            }
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(self.showAll ? items.count : 5), id: \.objectID) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.message ?? "",
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                fgColour: .white,
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly
                
                let req: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false),
                ]
                
                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive = true && message CONTAINS[cd] %@ && job.project.company.hidden == false",
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "message CONTAINS[cd] %@ && job.project.company.hidden == false",
                        _searchText.wrappedValue
                    )
                }
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedCompanies: View {
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
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
                            ZStack {
                                Theme.base
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
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.name ?? "",
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                fgColour: .white,
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    EmptyView()
                }
            }
            
            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly
                
                let req: NSFetchRequest<Company> = Company.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Company.name, ascending: true),
                ]
                
                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive = true && name CONTAINS[cd] %@ && hidden == false",
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "name CONTAINS[cd] %@ && hidden == false",
                        _searchText.wrappedValue
                    )
                }
                
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
                            ZStack {
                                Theme.base
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
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(items.prefix(5)) { item in
                                    VStack {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.name ?? "",
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                fgColour: .white,
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
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
}

// @TODO: make this generic function work
//extension FindDashboard.Suggestions {
//    private func choose<T>(_ item: T) -> Void {
//        nav.session.search.inspect(item)
//    }
//}

extension FindDashboard.Suggestions.SuggestedJobs {
    /// Inspects an individual item
    /// - Parameter item: A single Job
    /// - Returns: Void
    private func choose(_ item: Job) -> Void {
        nav.session.search.inspect(item)
    }
    
    /// Set a different Navigation value based on the current page
    /// - Parameter item: A single Job
    /// - Returns: Void
    private func setContext(_ item: Job) -> Void {
        switch nav.parent {
        case .dashboard, .companies, .jobs, .notes, .projects, .tasks, .today, .terms:
            nav.session.job = item
        case .planning:
            nav.planning.jobs.insert(item)
            // @TODO: this throws "Can't do a substring operation with something that isn't a string (lhs = 870732407166554 rhs = 55)"
//            nav.planning.projects.insert(item.project!)
        case .none:
            print("no op")
        }
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}

extension FindDashboard.Suggestions.SuggestedProjects {
    private func choose(_ item: Project) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}

extension FindDashboard.Suggestions.SuggestedNotes {
    /// Inspects an individual item
    /// - Parameter item: A single Note
    /// - Returns: Void
    private func choose(_ item: Note) -> Void {
        nav.session.search.inspect(item)
    }
    
    /// Set a different Navigation value based on the current page
    /// - Parameter item: A single Note
    /// - Returns: Void
    private func setContext(_ item: Note) -> Void {
        switch nav.parent {
        case .dashboard, .companies, .jobs, .notes, .projects, .tasks, .today, .terms:
            nav.session.job = item.mJob
        case .planning:
            if let job = item.mJob {
                nav.planning.jobs.insert(job)
            }
            
            nav.planning.notes.insert(item)
            // @TODO: this throws "Can't do a substring operation with something that isn't a string (lhs = 870732407166554 rhs = 55)"
//            nav.planning.projects.insert(item.project!)
        case .none:
            print("no op")
        }
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}

extension FindDashboard.Suggestions.SuggestedTasks {
    private func choose(_ item: LogTask) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}

extension FindDashboard.Suggestions.SuggestedCompanies {
    private func choose(_ item: Company) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}

extension FindDashboard.Suggestions.SuggestedPeople {
    private func choose(_ item: Person) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}

extension FindDashboard.Suggestions.SuggestedRecords {
    private func choose(_ item: LogRecord) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if items.count <= 5 {
            showChildren = true
        }
    }
}
