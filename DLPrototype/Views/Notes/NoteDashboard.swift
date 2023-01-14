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
    @State private var searchText: String = ""
    @State private var selected: Int = 0
    @State private var note: Note?
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    @FetchRequest public var notes: FetchedResults<Note>
    
    public init() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "postedDate > %@ && alive = true", DateHelper.daysPast(7))
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.starred, ascending: false),
            NSSortDescriptor(keyPath: \Note.lastUpdate, ascending: false)            
        ]
        
        _notes = FetchRequest(fetchRequest: request, animation: .easeInOut)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                create
                search

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
        
        FancyLink(icon: "note.text.badge.plus", destination: AnyView(NoteCreate()))
        FancyDivider()
    }
    
    @ViewBuilder
    var search: some View {
        HStack {
            Title(text: "Search", image: "note.text")
            Spacer()
        }
        
        SearchBar(
            text: $searchText,
            disabled: false,
            placeholder: "Search \(notes.count) notes"
        )
        
        if notes.count < 100 {
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
                        
                        Group {
                            ZStack {
                                Theme.headerColour
                                Text("Alive")
                                    .padding()
                            }
                        }
                        .frame(width: 100)
                    }
                }
                .frame(height: 40)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(filter(notes)) { note in
                            GridRow {
                                HStack(spacing: 1) {
                                    Group {
                                        ZStack(alignment: .leading) {
                                            Theme.rowColour
                                            FancyTextLink(text: note.title!, destination: AnyView(NoteView(note: note)))
                                        }
                                    }
                                    
                                    Group {
                                        ZStack {
                                            Theme.rowColour
                                            
                                            if note.starred {
                                                Image(systemName: "star.fill")
                                                    .padding()
                                            }
                                        }
                                    }
                                    .frame(width: 100)
                                    
                                    Group {
                                        ZStack {
                                            Theme.rowColour
                                            Text("\(note.versions!.count)")
                                                .padding()
                                        }
                                    }
                                    .frame(width: 100)
                                    
                                    Group {
                                        ZStack {
                                            (note.alive ? Theme.rowStatusGreen : Color.red.opacity(0.2))
                                        }
                                    }
                                    .frame(width: 100)
                                }
                            }
                        }
                    }
                }
            }
            .font(Theme.font)
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