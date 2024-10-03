//
//  NoteDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteDashboard: View {
    public var defaultSelectedJob: Job? = nil
    public var project: Project? = nil
    
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)

    @State private var searchText: String = ""
    @State private var selected: Int = 0
    @State private var showAllNotes: Bool = false

    @AppStorage("notes.columns") private var numColumns: Int = 3
    @AppStorage("notedashboard.listVisible") private var listVisible: Bool = true

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    
    @FetchRequest public var notes: FetchedResults<Note>

    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .notes

    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    public init(defaultSelectedJob: Job? = nil, project: Project? = nil) {
        self.defaultSelectedJob = defaultSelectedJob
        self.project = project

        let sharedDescriptors = [
            NSSortDescriptor(keyPath: \Note.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.project?.pid, ascending: true),
            NSSortDescriptor(keyPath: \Note.mJob?.jid, ascending: true),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = sharedDescriptors
        
        if self.defaultSelectedJob != nil {
            let byJobPredicate = NSPredicate(format: "ANY mJob.jid = %f && mJob.project.company.hidden == false", self.defaultSelectedJob!.jid)
            let predicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [byJobPredicate])
            request.predicate = predicates
        } else if self.project != nil {
            let byJobPredicate = NSPredicate(format: "ANY mJob.project = %@ && mJob.project.company.hidden == false", self.project!)
            let predicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [byJobPredicate])
            request.predicate = predicates
        } else {
            request.predicate = NSPredicate(format: "alive = true && mJob.project.company.hidden == false")
        }
        
        _notes = FetchRequest(fetchRequest: request, animation: .easeInOut)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 10) {
                    Title(text: eType.label, imageAsImage: eType.icon)
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: {},
                        icon: "plus",
                        showLabel: false,
                        redirect: AnyView(NoteCreate()),
                        pageType: .notes,
                        sidebar: AnyView(NoteCreateSidebar())
                    )
                }
                .font(.title2)
                FancyDivider()

                CompanyNotebooks()

                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text("Recently updated").font(.title2)
                        Spacer()
                        FancySimpleButton(
                            text: listVisible ? "Close" : "Open",
                            action: {listVisible.toggle()},
                            icon: listVisible ? "minus.square.fill" : "plus.square.fill",
                            showLabel: false,
                            showIcon: true,
                            size: .tiny,
                            type: .clear
                        )
                    }

                    HStack {
                        Text("Notes are sorted from most to least recently updated.")
                            .font(.caption)
                        Spacer()
                    }
                }
                .padding(5)
                .background(.white.opacity(0.2))
                .foregroundStyle(.white)
                
                if listVisible {
                    // TODO: remove!
                    SearchBar(
                        text: $searchText,
                        disabled: false,
                        placeholder: notes.count > 1 ? "Search \(notes.count) notes" : "Search 1 note"
                    )

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(filter(notes), id: \.objectID) { note in
                                NoteBlock(note: note)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}

extension NoteDashboard {
    private func filter(_ notes: FetchedResults<Note>) -> [Note] {
        return SearchHelper(bucket: notes).findInNotes($searchText)
    }
}

extension NoteDashboard {
    struct CompanyNotebooks: View {
        @AppStorage("notedashboard.explorerVisible") private var explorerVisible: Bool = true

        @FetchRequest public var companies: FetchedResults<Company>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text("Project Notebooks").font(.title2)
                        Spacer()
                        FancySimpleButton(
                            text: explorerVisible ? "Close" : "Open",
                            action: {explorerVisible.toggle()},
                            icon: explorerVisible ? "minus.square.fill" : "plus.square.fill",
                            showLabel: false,
                            showIcon: true,
                            size: .tiny,
                            type: .clear
                        )
                    }

                    HStack {
                        Text("Find notes by project.")
                            .font(.caption)
                        Spacer()
                    }
                }
                .padding(5)
                .background(.white.opacity(0.2))
                .foregroundStyle(.white)

                if explorerVisible {
                    ThreePanelGroup(orientation: .horizontal, data: companies, lastColumnType: .notes)
                }
            }
        }

        init() {
            _companies = CoreDataCompanies.fetch()
        }
    }
}
