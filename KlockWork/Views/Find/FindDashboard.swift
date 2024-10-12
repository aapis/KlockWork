//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FindDashboard: View {
    typealias Entity = PageConfiguration.EntityType

    @EnvironmentObject public var nav: Navigation
    @State public var searching: Bool = false
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
    @State private var showTerms: Bool = true
    @State private var showDefinitions: Bool = true
    @State private var allowAlive: Bool = true
    @State private var counts: (Int, Int, Int, Int) = (0, 0, 0, 0)
    @State private var advancedSearchResults: [SearchLanguage.Results.Result] = []
    @State private var buttons: [ToolbarButton] = []
    @State private var loading: Bool = false
    @AppStorage("searchbar.showTypes") private var showingTypes: Bool = false
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: 2)
    }
    private let eType: PageConfiguration.EntityType = .BruceWillis

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
            if self.location == .content {
                GridRow {
                    UniversalHeader.Widget(
                        type: self.eType,
                        title: "Welcome back!",
                        additionalDetails: AnyView(
                            WidgetLibrary.UI.Meetings()
                        )
                    )
                }
            }
            GridRow {
                ZStack(alignment: .topLeading) {
                    SearchBar(
                        text: $activeSearchText,
                        placeholder: location == .content ? "Search \(counts.0) records, \(counts.1) jobs, and \(counts.2) tasks in \(counts.3) projects" : "Search for anything",
                        onSubmit: onSubmit,
                        onReset: onReset
                    )
//                    .border(width: self.activeSearchText.count  == 0 && self.location == .content ? 4 : 0, edges: [.bottom], color: self.nav.parent?.appPage.primaryColour ?? .clear)
//
//                    if activeSearchText.count == 0 {
////                        VStack(alignment: .trailing) {
////                            Spacer()
//                            HStack(spacing: 5) {
//                                Spacer()
//                                FancyButtonv2(
//                                    text: "Entities",
//                                    action: {showingTypes.toggle()},
//                                    icon: showingTypes ? "arrow.up.square.fill" : "arrow.down.square.fill",
//                                    showLabel: false,
////                                    size: .tiny,
//                                    type: .clear
//                                )
//                                .help("Choose the entities you want to search")
//                                .padding(.trailing, 15)
//                            }
////                        }
////                        .frame(height: 28)
//                    }
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
                                showTerms: $showTerms,
                                showDefinitions: $showDefinitions,
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
                            showTerms: $showTerms,
                            showDefinitions: $showDefinitions,
                            location: location
                        )
                    }
                }
            }
            
            if showingTypes {
                if location == .content {
                    GridRow {
                        ZStack(alignment: .leading) {
                            self.nav.parent?.appPage.primaryColour ?? Theme.subHeaderColour

                            HStack {
                                Toggle("Records", isOn: $showRecords)
                                Toggle("Notes", isOn: $showNotes)
                                Toggle("Tasks", isOn: $showTasks)
                                Toggle("Projects", isOn: $showProjects)
                                Toggle("Jobs", isOn: $showJobs)
                                Toggle("Companies", isOn: $showCompanies)
                                Toggle("People", isOn: $showPeople)
                                Toggle("Terms & Definitions", isOn: $showTerms)
                                Spacer()
                                Toggle("Published Only", isOn: $allowAlive)
                            }
                            .padding([.leading, .trailing], 10)
                        }
                    }
                    .frame(height: 40)
                    .foregroundStyle(.gray)
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
                            Toggle("Terms & Definitions", isOn: $showTerms)
                            Toggle("Published Only", isOn: $allowAlive)
                        }
                        .padding(10)
                    }
                    .background(location == .sidebar ? Theme.rowColour : self.nav.parent?.appPage.primaryColour.opacity(0.2))
                    .foregroundStyle(.gray)
                }
            }

            if searching {
                if loading {
                    Loading()
                } else {
                    FancyDivider()
                    FancyGenericToolbar(buttons: buttons, standalone: true, location: location, mode: .compact)
                    Spacer()
                }
            }
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: searchText) {
            if searchText.count >= 2 {
                onSubmit()
            } else {
                onReset()
            }
        }
        .onChange(of: activeSearchText) {
            nav.session.search.inspectingEntity = nil

            if activeSearchText.isEmpty {
                onReset()
            }
        }
        .onChange(of: nav.session.search.text) {
            if let sq = nav.session.search.text {
                activeSearchText = sq
            }
        }
        .onChange(of: nav.session.search.inspectingEntity) {
            if location == .sidebar {
                if nav.session.search.inspectingEntity != nil {
                    nav.setInspector(AnyView(Inspector(entity: nav.session.search.inspectingEntity!)))
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

        if nav.session.search.inspectingEntity != nil {
            if let stext = nav.session.search.text {
                activeSearchText = stext
            }
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
                CoreDataRecords(moc: self.nav.moc).countAll(),
                CoreDataJob(moc: self.nav.moc).countAll(),
                CoreDataTasks(moc: self.nav.moc).countAll(),
                CoreDataProjects(moc: self.nav.moc).countAll()
            )
            showingTypes = true
        }

        if nav.session.search.text != nil {
            activeSearchText = nav.session.search.text!
        }
    }
    
    private func createTabs() -> Void {
        // @TODO: convert to set or otherwise mitigate requirement to clear buttons here
        buttons = []

        if showRecords {
            buttons.append(
                ToolbarButton(
                    id: 0,
                    helpText: Entity.records.label,
                    icon: Entity.records.icon,
                    labelText: Entity.records.label,
                    contents: AnyView(RecordsMatchingString(searchText))
                )
            )
        }
        
        if showNotes {
            buttons.append(
                ToolbarButton(
                    id: 1,
                    helpText: Entity.notes.label,
                    icon: Entity.notes.icon,
                    labelText: Entity.notes.label,
                    contents: AnyView(NotesMatchingString(searchText))
                )
            )
        }
        
        if showTasks {
            buttons.append(
                ToolbarButton(
                    id: 2,
                    helpText: Entity.tasks.label,
                    icon: Entity.tasks.icon,
                    labelText: Entity.tasks.label,
                    contents: AnyView(TasksMatchingString(searchText))
                )
            )
        }
        
        if showProjects {
            buttons.append(
                ToolbarButton(
                    id: 3,
                    helpText: Entity.projects.label,
                    icon: Entity.projects.icon,
                    labelText: Entity.projects.label,
                    contents: AnyView(ProjectsMatchingString(searchText))
                )
            )
        }
        
        if showJobs {
            buttons.append(
                ToolbarButton(
                    id: 4,
                    helpText: Entity.jobs.label,
                    icon: Entity.jobs.icon,
                    labelText: Entity.jobs.label,
                    contents: AnyView(JobsMatchingString(searchText))
                )
            )
        }

        if showCompanies {
            buttons.append(
                ToolbarButton(
                    id: 5,
                    helpText: Entity.companies.label,
                    icon: Entity.companies.icon,
                    labelText: Entity.companies.label,
                    contents: AnyView(CompaniesMatchingString(searchText))
                )
            )
        }

        if showPeople {
            buttons.append(
                ToolbarButton(
                    id: 6,
                    helpText: Entity.people.label,
                    icon: Entity.people.icon,
                    labelText: Entity.people.label,
                    contents: AnyView(PeopleMatchingString(searchText))
                )
            )
        }

        if showTerms {
            buttons.append(
                ToolbarButton(
                    id: 7,
                    helpText: Entity.terms.label,
                    icon: Entity.terms.icon,
                    labelText: "Terms & Definitions",
                    contents: AnyView(TermsMatchingString(searchText))
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
                            ForEach(entities, id: \.objectID) { item in
                                let entry = Entry(
                                    timestamp: item.timestamp!,
                                    job: item.job!,
                                    message: item.message!
                                )
                                
                                LogRow(
                                    entry: entry,
                                    index: entities.firstIndex(of: item),
                                    colour: Color.fromStored(item.job!.colour ?? Theme.rowColourAsDouble)
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
            rr.predicate = NSPredicate(format: "message CONTAINS[cd] %@ && job.project.company.hidden == false", text)
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
                            ForEach(entities, id: \.objectID) { item in
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
            req.predicate = NSPredicate(format: "(body CONTAINS[cd] %@ OR title CONTAINS[cd] %@) AND alive = true && mJob.project.company.hidden == false", text, text)
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
                            ForEach(entities, id: \.objectID) { item in
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
            tr.predicate = NSPredicate(format: "content CONTAINS[c] %@ && owner.project.company.hidden == false", text)
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
                            ForEach(entities, id: \.objectID) { item in
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
            pr.predicate = NSPredicate(format: "name CONTAINS[c] %@ AND alive = true && company.hidden == false", text)
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
                            ForEach(entities, id: \.objectID) { item in
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
            jr.predicate = NSPredicate(format: "(uri CONTAINS[c] %@ OR jid.stringValue BEGINSWITH %@ OR overview CONTAINS[c] %@ OR title CONTAINS[c] %@) AND alive = true && project.company.hidden == false", text, text, text, text)
            jr.sortDescriptors = [
                NSSortDescriptor(keyPath: \Job.created, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        }
    }

    struct CompaniesMatchingString: View {
        @FetchRequest private var entities: FetchedResults<Company>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Companies")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities, id: \.objectID) { item in
//                                JobRow(job: item, colour: item.colour_from_stored())
                                Text(item.name ?? "_COMPANY_NAME")
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 Companies")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }

        init(_ text: String) {
            let jr: NSFetchRequest<Company> = Company.fetchRequest()
            jr.predicate = NSPredicate(format: "(name CONTAINS[c] %@ || abbreviation CONTAINS[c] %@) && alive == true && hidden == false", text, text)
            jr.sortDescriptors = [
                NSSortDescriptor(keyPath: \Company.createdDate, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        }
    }

    struct PeopleMatchingString: View {
        @FetchRequest private var entities: FetchedResults<Person>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) People")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities, id: \.objectID) { item in
//                                JobRow(job: item, colour: item.colour_from_stored())
                                Text(item.name ?? "_COMPANY_NAME")
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 People")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }

        init(_ text: String) {
            let jr: NSFetchRequest<Person> = Person.fetchRequest()
            jr.predicate = NSPredicate(format: "name CONTAINS[c] %@ || title CONTAINS[c] %@", text, text)
            jr.sortDescriptors = [
                NSSortDescriptor(keyPath: \Person.created, ascending: false)
            ]
            _entities = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        }
    }

    struct TermsMatchingString: View {
        @FetchRequest private var entities: FetchedResults<TaxonomyTerm>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if entities.count > 0 {
                    HStack {
                        Text("\(entities.count) Terms")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(entities, id: \.objectID) { item in
//                                JobRow(job: item, colour: item.colour_from_stored())
                                Text(item.name ?? "_NAME")
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("0 Terms")
                            .padding()
                        Spacer()
                    }
                    .background(Theme.subHeaderColour)
                }
            }
        }

        init(_ text: String) {
            let jr: NSFetchRequest<TaxonomyTerm> = TaxonomyTerm.fetchRequest()
            jr.predicate = NSPredicate(format: "(name CONTAINS[c] %@ || ANY definitions.definition CONTAINS[c] %@) && alive == true", text, text)
            jr.sortDescriptors = [
                NSSortDescriptor(keyPath: \TaxonomyTerm.created, ascending: false)
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
