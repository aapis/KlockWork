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
    
    @State private var searchText: String = ""
    @State private var selected: Int = 0

    @AppStorage("notes.columns") private var numColumns: Int = 3
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jm: CoreDataJob
    
    @FetchRequest public var notes: FetchedResults<Note>

    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    public init(defaultSelectedJob: Job? = nil) {
        self.defaultSelectedJob = defaultSelectedJob
        
        let sharedDescriptors = [
            NSSortDescriptor(keyPath: \Note.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = sharedDescriptors
        
        if self.defaultSelectedJob != nil {
            let byJobPredicate = NSPredicate(format: "ANY mJob.jid = %f", self.defaultSelectedJob!.jid)
            let predicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [byJobPredicate])
            request.predicate = predicates
        } else {
            request.predicate = NSPredicate(format: "alive = true")
        }
        
        _notes = FetchRequest(fetchRequest: request, animation: .easeInOut)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Notes")
                    Spacer()
                    FancyButtonv2(
                        text: "New note",
                        action: {},
                        icon: "plus",
                        showLabel: false,
                        redirect: AnyView(NoteCreate()),
                        pageType: .notes
                    )
                }
                SearchBar(
                    text: $searchText,
                    disabled: false,
                    placeholder: notes.count > 1 ? "Search \(notes.count) notes" : "Search 1 note"
                )

                recentNotes

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }

    @ViewBuilder private var recentNotes: some View {
        if notes.count > 0 {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(filter(notes)) { note in
                        NoteBlock(note: note)
                            .environmentObject(nav)
                            .environmentObject(jm)
                            .environmentObject(updater)
                    }
                }
            }
        } else {
            Text("No notes for this query")
        }
    }

    // TODO: keep this, but make it optional
    @ViewBuilder
    var allTable: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            HStack(spacing: 0) {
                GridRow {
                    Group {
                        ZStack(alignment: .leading) {
                            Theme.headerColour
                            Text("Name")
                                .padding()
                        }
                    }
                    Group {
                        ZStack {
                            Theme.headerColour
                            Text("Versions")
                                .padding()
                        }
                    }
                    .frame(width: 100)
                }
            }
            .frame(height: 46)
            
            allRows
        }
        .font(Theme.font)
    }
    
    @ViewBuilder
    var allRows: some View {
        ScrollView(showsIndicators: false) {
            if notes.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(filter(notes)) { note in
                        NoteRow(note: note)
                    }
                }
            } else {
                Text("No notes for this query")
            }
        }
    }
    
    private func filter(_ notes: FetchedResults<Note>) -> [Note] {
        return SearchHelper(bucket: notes).findInNotes($searchText)
    }
}

struct NoteDashboardPreview: PreviewProvider {
    static var previews: some View {
        NoteDashboard()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
