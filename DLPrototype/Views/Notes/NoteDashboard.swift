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
    @State private var note: Note?
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jm: CoreDataJob
    
    @FetchRequest public var notes: FetchedResults<Note>
    @FetchRequest public var notesStarred: FetchedResults<Note>
    
    public init(defaultSelectedJob: Job? = nil) {
        self.defaultSelectedJob = defaultSelectedJob
        
        let sharedDescriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let aliveNotStarredPredicate = NSPredicate(format: "alive = true && (starred = false || starred = nil)")
        
        request.sortDescriptors = sharedDescriptors
        
        if self.defaultSelectedJob != nil {
            let byJobPredicate = NSPredicate(format: "ANY mJob.jid = %f", self.defaultSelectedJob!.jid)
            let predicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [aliveNotStarredPredicate, byJobPredicate])
            request.predicate = predicates
        } else {
            request.predicate = aliveNotStarredPredicate
        }
        
        _notes = FetchRequest(fetchRequest: request, animation: .easeInOut)
        
        let starredReq: NSFetchRequest<Note> = Note.fetchRequest()
        let aliveStarredPredicate = NSPredicate(format: "alive = true && starred = true")
        starredReq.sortDescriptors = sharedDescriptors
        
        if self.defaultSelectedJob != nil {
            let byJobPredicate = NSPredicate(format: "ANY mJob.jid = %f", self.defaultSelectedJob!.jid)
            let predicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [aliveStarredPredicate, byJobPredicate])
            starredReq.predicate = predicates
        } else {
            starredReq.predicate = aliveStarredPredicate
        }
        
        _notesStarred = FetchRequest(fetchRequest: starredReq, animation: .easeInOut)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                create
                
                HStack {
                    Title(text: "Search", image: "note.text")
                    Spacer()
                }
                
                SearchBar(
                    text: $searchText,
                    disabled: false,
                    placeholder: "Search \(notes.count) notes"
                )

                starredTable
                allTable

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var create: some View {
        HStack {
            Title(text: "Create", image: "pencil")
        }
        
        FancyLink(icon: "note.text.badge.plus", destination: AnyView(NoteCreate().environmentObject(jm)))
        FancyDivider()
    }
    
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
    var starredTable: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            HStack(spacing: 0) {
                GridRow {
                    Group {
                        ZStack(alignment: .leading) {
                            Theme.headerColour
                            Text("Favourites")
                                .padding()
                        }
                    }
                    Group {
                        ZStack {
                            Theme.headerColour
                            Text("Star")
                                .padding()
                        }
                    }
                    .frame(width: 100)
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
            
            starredRows
        }
        .font(Theme.font)
        .frame(maxHeight: 300)
    }
    
    @ViewBuilder
    var allRows: some View {
        ScrollView {
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
    
    @ViewBuilder
    var starredRows: some View {
        ScrollView {
            if notesStarred.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(filter(notesStarred)) { note in
                        NoteRow(note: note)
                    }
                }
            } else {
                Text("No favourite notes for this query")
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
