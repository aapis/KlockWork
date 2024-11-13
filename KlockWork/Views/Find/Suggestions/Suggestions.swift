//
//  Suggestions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension FindDashboard {
    struct Suggestions: View {
        @EnvironmentObject public var nav: Navigation
        @AppStorage("GlobalSidebarWidgets.isSearching") private var isSearching: Bool = false
        @Binding public var searchText: String
        @Binding public var publishedOnly: Bool
        @Binding public var showRecords: Bool
        @Binding public var showNotes: Bool
        @Binding public var showTasks: Bool
        @Binding public var showProjects: Bool
        @Binding public var showJobs: Bool
        @Binding public var showCompanies: Bool
        @Binding public var showPeople: Bool
        @Binding public var showTerms: Bool
        @Binding public var showDefinitions: Bool
        public var location: WidgetLocation
        @State private var timer: Timer? = nil
        @State private var isMinimized: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if searchText.count >= 2 || isSearching {
                            HStack {
                                UI.ListLinkTitle(text: location == .content ? "Hit enter/return to see all results" : "Suggestions for your query")
                                Spacer()
                                FancyButtonv2(
                                    text: "",
                                    action: {self.isMinimized.toggle()},
                                    icon: self.isMinimized ? "plus.square.fill" : "minus.square.fill",
                                    iconWhenHighlighted: self.isMinimized ? "plus.square" : "minus.square",
                                    showLabel: false,
                                    showIcon: true,
                                    size: .tinyLink,
                                    type: .clear
                                )
                                .help("Minimize suggestions")
                            }
                            .padding([.leading, .trailing], 8)
                        }

                        if searchText.count >= 2 || isSearching {
                            if !self.isMinimized {
                                VStack {
                                    // @TODO: reduce this with a loop, each view is basically identical...
                                    if showRecords {SuggestedRecords(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showNotes {SuggestedNotes(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showTasks {SuggestedTasks(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showProjects {SuggestedProjects(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showJobs {SuggestedJobs(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showCompanies {SuggestedCompanies(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showPeople {SuggestedPeople(searchText: $searchText)}
                                    if showTerms {SuggestedTerms(searchText: $searchText, publishedOnly: $publishedOnly)}
                                    if showDefinitions {SuggestedDefinitions(searchText: $searchText, publishedOnly: $publishedOnly)}
                                }
                                .padding(self.location == .content ? 16 : 8)
                                .background(Theme.textBackground)
                                .clipShape(.rect(cornerRadius: 5))
                            }
                        }
                    }
                    .padding(.leading, self.location == .content ? 16 : 8)
                    .padding(.trailing, self.location == .content ? 16 : 8)
                    .padding(.bottom, self.location == .content ? 16 : 8)
                    .padding(.top, self.location == .content ? 16 : 8)
                }
            }
            .background(location == .content ? Theme.rowColour : Color.clear)
            .onChange(of: isSearching) {
                nav.session.search.cancel()
                nav.setInspector()
            }
            .onChange(of: self.searchText) {
                self.timer?.invalidate()

                if self.searchText.count > 2 {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                        let termIsSaved = CDSavedSearch(moc: self.nav.moc).find(by: self.searchText) == nil
                        let termIsRecent = self.nav.session.search.history.contains(where: {$0 == self.searchText})

                        guard termIsSaved && termIsRecent else {
                            return self.nav.session.search.addToHistory(self.searchText)
                        }
                    }
                }
            }
        }
        
        struct SuggestedJobs: View {
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Job>
            
            var body: some View {
                if items.count > 0 {
                    VStack(alignment: .leading) {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.jobs.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.jobs.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading) {
                                ForEach(self.items, id: \.objectID) { item in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Divider()
                                        HStack {
                                            FancyButtonv2(
                                                text: item.title ?? item.jid.string,
                                                action: {choose(item)},
                                                icon: "questionmark.square.fill",
                                                showIcon: true,
                                                size: .link,
                                                type: .clear
                                            )
                                            .help("Inspect")
                                            Spacer()
                                            FancyButtonv2(
                                                text: item.title ?? item.jid.string,
                                                action: {setContext(item)},
                                                icon: "command.square.fill",
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
                            .padding([.leading, .bottom], 10)
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.jobs.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
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
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Project>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.projects.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.projects.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.projects.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
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
                        format: "alive = true && (name CONTAINS[cd] %@ || pid BEGINSWITH %@) && company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "(name CONTAINS[cd] %@ || pid BEGINSWITH %@) && company.hidden == false",
                        _searchText.wrappedValue,
                        _searchText.wrappedValue
                    )
                }
                
                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedNotes: View {
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Note>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.notes.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.notes.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                                icon: "command.square.fill",
                                                showLabel: false,
                                                showIcon: true,
                                                size: .tinyLink,
                                                type: .clear
                                            )
                                            .help("Set associated job as Active Job")
                                        }
                                    }
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.notes.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
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
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<LogTask>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.tasks.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.tasks.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                            FancyButtonv2(
                                                text: "",
                                                action: {setContext(item)},
                                                icon: "command.square.fill",
                                                showLabel: false,
                                                showIcon: true,
                                                size: .tinyLink,
                                                type: .clear
                                            )
                                            .help("Set associated job as Active Job")
                                        }
                                    }
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.tasks.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
                }
            }
            
            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly

                let req: NSFetchRequest<LogTask> = LogTask.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \LogTask.created, ascending: true),
                ]

                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "completedDate == nil && cancelledDate == nil && (content CONTAINS[cd] %@ && owner.project.company.hidden == false)",
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "content CONTAINS[cd] %@ && owner.project.company.hidden == false",
                        _searchText.wrappedValue
                    )
                }

                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }
        
        struct SuggestedRecords: View {
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<LogRecord>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.records.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.records.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                            FancyButtonv2(
                                                text: "",
                                                action: {setContext(item)},
                                                icon: "command.square.fill",
                                                showLabel: false,
                                                showIcon: true,
                                                size: .tinyLink,
                                                type: .clear
                                            )
                                            .help("Set associated job as Active Job")
                                        }
                                    }
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.records.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
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
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<Company>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.companies.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.companies.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                            FancyButtonv2(
                                                text: "",
                                                action: {setContext(item)},
                                                icon: "command.square.fill",
                                                showLabel: false,
                                                showIcon: true,
                                                size: .tinyLink,
                                                type: .clear
                                            )
                                            .help("Set as Active Company")
                                        }
                                    }
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.companies.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
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
            @EnvironmentObject public var nav: Navigation
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
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.people.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.people.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.people.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
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

        struct SuggestedTerms: View {
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<TaxonomyTerm>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.terms.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.terms.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
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
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.terms.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
                }
            }

            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly

                let req: NSFetchRequest<TaxonomyTerm> = TaxonomyTerm.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \TaxonomyTerm.name, ascending: true),
                ]

                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive == true && name CONTAINS[cd] %@",
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "name CONTAINS[cd] %@",
                        _searchText.wrappedValue
                    )
                }

                _items = FetchRequest(fetchRequest: req, animation: .easeInOut)
            }
        }

        struct SuggestedDefinitions: View {
            @EnvironmentObject public var nav: Navigation
            @Binding public var searchText: String
            @Binding public var publishedOnly: Bool
            @State private var showChildren: Bool = false
            @State private var hover: Bool = false
            @FetchRequest private var items: FetchedResults<TaxonomyTermDefinitions>

            var body: some View {
                if items.count > 0 {
                    VStack {
                        Button {
                            showChildren.toggle()
                        } label: {
                            UI.UnifiedSidebar.EntityRowButton(
                                text: self.items.count == 1 ? "\(items.count) \(PageConfiguration.EntityType.definitions.enSingular)" : "\(items.count) \(PageConfiguration.EntityType.definitions.label)",
                                isPresented: $showChildren
                            )
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in hover = inside})
                        .clipShape(.rect(cornerRadius: 5))

                        if showChildren {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.items, id: \.objectID) { item in
                                    VStack {
                                        HStack {
                                            FancyButtonv2(
                                                text: item.definition ?? "",
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
                                        Divider()
                                    }
                                    .padding([.leading, .bottom], 10)
                                }
                            }
                        }
                    }
                    .onAppear(perform: appear)
                } else {
                    UI.UnifiedSidebar.EntityRowButton(
                        text: "No \(PageConfiguration.EntityType.definitions.label) matched",
                        isPresented: $showChildren
                    )
                    .disabled(true)
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: 5))
                }
            }

            init(searchText: Binding<String>, publishedOnly: Binding<Bool>) {
                _searchText = searchText
                _publishedOnly = publishedOnly

                let req: NSFetchRequest<TaxonomyTermDefinitions> = TaxonomyTermDefinitions.fetchRequest()
                req.sortDescriptors = [
                    NSSortDescriptor(keyPath: \TaxonomyTermDefinitions.created, ascending: true),
                ]

                if publishedOnly.wrappedValue {
                    req.predicate = NSPredicate(
                        format: "alive = true && definition CONTAINS[cd] %@",
                        _searchText.wrappedValue
                    )
                } else {
                    req.predicate = NSPredicate(
                        format: "definition CONTAINS[cd] %@",
                        _searchText.wrappedValue
                    )
                }

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
        default:
            print("no op")
        }
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }
}

extension FindDashboard.Suggestions.SuggestedProjects {
    private func choose(_ item: Project) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
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
        default:
            print("no op")
        }
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }
}

extension FindDashboard.Suggestions.SuggestedTasks {
    private func choose(_ item: LogTask) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }

    /// Set a different Navigation value based on the current page
    /// - Parameter item: NSManagedObject>
    /// - Returns: Void
    private func setContext(_ item: LogTask) -> Void {
        switch nav.parent {
        case .dashboard, .companies, .jobs, .notes, .projects, .tasks, .today, .terms:
            self.nav.session.job = item.owner
            self.nav.session.project = self.nav.session.job?.project
            self.nav.session.company = self.nav.session.project?.company
        case .planning:
            if let job = item.owner {
                self.nav.planning.jobs.insert(job)
                if let project = job.project {
                    self.nav.planning.projects.insert(project)
                    if let company = project.company {
                        self.nav.planning.companies.insert(company)
                    }
                }
            }
        default:
            print("no op")
        }
    }
}

extension FindDashboard.Suggestions.SuggestedCompanies {
    private func choose(_ item: Company) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }

    /// Set a different Navigation value based on the current page
    /// - Parameter item: NSManagedObject
    /// - Returns: Void
    private func setContext(_ item: Company) -> Void {
        switch nav.parent {
        case .dashboard, .companies, .jobs, .notes, .projects, .tasks, .today, .terms:
            nav.session.company = item
        case .planning:
            nav.planning.companies.insert(item)
        default:
            print("no op")
        }
    }
}

extension FindDashboard.Suggestions.SuggestedPeople {
    private func choose(_ item: Person) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }
}

extension FindDashboard.Suggestions.SuggestedRecords {
    private func choose(_ item: LogRecord) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }

    /// Set a different Navigation value based on the current page
    /// - Parameter item: NSManagedObject>
    /// - Returns: Void
    private func setContext(_ item: LogRecord) -> Void {
        switch nav.parent {
        case .dashboard, .companies, .jobs, .notes, .projects, .tasks, .today, .terms:
            nav.session.job = item.job
        case .planning:
            if let job = item.job {
                nav.planning.jobs.insert(job)
            }
        default:
            print("no op")
        }
    }
}

extension FindDashboard.Suggestions.SuggestedTerms {
    private func choose(_ item: TaxonomyTerm) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }
}

extension FindDashboard.Suggestions.SuggestedDefinitions {
    private func choose(_ item: TaxonomyTermDefinitions) -> Void {
        nav.session.search.inspect(item)
    }

    private func appear() -> Void {
        if self.items.count <= 5 {
            if self.items.count > 1  {
                self.showChildren = true
            } else {
                self.showChildren = false
            }
        }
    }
}
