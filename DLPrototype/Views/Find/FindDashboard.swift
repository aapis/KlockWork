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
    @State private var advancedSearchResults: [SearchLanguage.Results.SpeciesType: [NSManagedObject]] = [:]

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var nav: Navigation
    
    var body: some View {
        // TODO: commented out to experiment including this view on the dashboard
//        VStack(alignment: .leading) {
//            VStack(alignment: .leading) {
//                search
//
//                Spacer()
//            }
//            .font(Theme.font)
//            .padding()
//        }
//        .background(Theme.toolbarColour)
        search
    }
    
    @ViewBuilder
    var search: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 1) {
            GridRow {
                SearchBar(
                    text: $activeSearchText,
                    disabled: false,
                    placeholder: "Search \(counts.0) records, \(counts.1) jobs, \(counts.2) tasks and \(counts.3) projects",
                    onSubmit: onSubmit,
                    onReset: onReset
                )
                .onChange(of: searchText) { _ in
                    onSubmit()
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
                
                if advancedSearchResults.isEmpty {
                    Results(
                        text: $searchText,
                        showRecords: $showRecords,
                        showNotes: $showNotes,
                        showTasks: $showTasks,
                        showProjects: $showProjects,
                        showJobs: $showJobs,
                        allowAlive: $allowAlive
                    )
                } else {
                    AdvancedSearchResults(results: advancedSearchResults)
                }
            }
        }
        .onAppear(perform: actionOnAppear)
    }
    
    @ViewBuilder
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                ProgressView("Searching...")
                Spacer()
            }
            .padding([.top, .bottom], 20)
        }
    }
    
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
//            for (group, results) in nav.session.search.results() {
//                switch group {
//                case .job:
//                    advancedSearchResults = results as! [Job]
//                default:
//                    print("DERPO unknown")
//                }
//            }
        }

        searchText = activeSearchText
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
}

extension FindDashboard {
    struct AdvancedSearchResults: View {
        public var results: [SearchLanguage.Results.SpeciesType: [NSManagedObject]] = [:]
        
        @State private var jobs: [Job] = []
        @State private var tasks: [LogTask] = []
        @State private var projects: [Project] = []
        @State private var companies: [Company] = []
        
        var body: some View {
            VStack(alignment: .leading) {
                Jobs(items: jobs)
                Tasks(items: tasks)
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension FindDashboard.AdvancedSearchResults {
    struct Jobs: View {
        public var items: [Job]
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("Jobs")
                    Spacer()
                }

                VStack {
                    ForEach(items) { item in
                        Text(String(item.jid.string))
                        Text(String(item.records!.count))
                    }
                }

                Spacer()
            }
        }
    }
    
    struct Tasks: View {
        public var items: [LogTask]
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("Tasks")
                    Text(String(items.count))
                    Spacer()
                }

                VStack {
                    ForEach(items) { item in
                        if let content = item.content {
                            Text(String(content))
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

extension FindDashboard.AdvancedSearchResults {
    private func actionOnAppear() -> Void {
        for (type, typeResults) in results {
            switch type {
            case .job:
                jobs = typeResults as! [Job]
            case .task:
                tasks = typeResults as! [LogTask]
            default:
                print("DERPO unknown")
            }
        }
    }
}
