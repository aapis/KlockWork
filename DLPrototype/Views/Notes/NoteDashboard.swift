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
        request.predicate = NSPredicate(format: "alive = true")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.starred, ascending: false),
            NSSortDescriptor(keyPath: \Note.lastUpdate, ascending: false),
            NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)
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
                    }
                }
                .frame(height: 46)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(filter(notes)) { note in
                            GridRow {
                                HStack(spacing: 1) {
                                    nProject(note)
                                    nNote(note)
                                    nStar(note)
                                    nVersions(note)
                                    nAlive(note)
                                }
                            }
                        }
                    }
                }
            }
            .font(Theme.font)
        }
    }
    
    @ViewBuilder private func nProject(_ note: Note) -> some View {
        Group {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if note.job != nil {
                        Color.fromStored(note.job!.project!.colour ?? Theme.rowColourAsDouble)
                    } else {
                        Theme.rowColour
                    }
                }
            }
        }
        .frame(width: 5)
    }
    
    @ViewBuilder private func nNote(_ note: Note) -> some View {
        Group {
            ZStack(alignment: .leading) {
                if note.job != nil {
                    Color.fromStored(note.job!.colour ?? Theme.rowColourAsDouble)
                } else {
                    Theme.rowColour
                }
                
                FancyTextLink(text: note.title!, destination: AnyView(NoteView(note: note)), fgColour: (note.job != nil ? (Color.fromStored(note.job!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)  : Color.white))
            }
        }
    }
    
    @ViewBuilder private func nStar(_ note: Note) -> some View {
        Group {
            ZStack {
                if note.job != nil {
                    Color.fromStored(note.job!.colour ?? Theme.rowColourAsDouble)
                } else {
                    Theme.rowColour
                }

                if note.starred {
                    Image(systemName: "star.fill")
                        .padding()
                        .foregroundColor(note.job != nil ? (Color.fromStored(note.job!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)  : Color.white)
                }
            }
        }
        .frame(width: 100)
    }
    
    @ViewBuilder private func nVersions(_ note: Note) -> some View {
        Group {
            ZStack {
                if note.job != nil {
                    Color.fromStored(note.job!.colour ?? Theme.rowColourAsDouble)
                } else {
                    Theme.rowColour
                }
                
                Text("\(note.versions!.count)")
                    .padding()
                    .foregroundColor(note.job != nil ? (Color.fromStored(note.job!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)  : Color.white)
            }
        }
        .frame(width: 100)
    }
    
    @ViewBuilder private func nAlive(_ note: Note) -> some View {
        Group {
            ZStack {
                (note.alive ? Theme.rowStatusGreen : Color.red.opacity(0.2))
            }
        }
        .frame(width: 5)
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
