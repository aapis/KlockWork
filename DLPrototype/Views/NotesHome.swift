//
//  Notes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NotesHome: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate)]) public var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        NavigationSplitView {
            List(notes) { note in
                NavigationLink(note.title!, value: note)
            }
            .navigationDestination(for: Note.self) {
                NoteView(note: $0)
                    .navigationTitle($0.title!)
            }
            Divider()
            VStack {
                HStack {
                    Spacer()
                    NavigationLink {
                        NoteCreate()
                            .navigationTitle("Create a note")
                    } label: {
                        Image(systemName: "plus")
                    }.buttonStyle(.borderless)
                }
            }
        } detail: {
            Text("Please select a note, or create a new one")
        }
        .navigationSplitViewStyle(.prominentDetail)
                
                // main body
//                VStack {
//                    Text("derping main body")
//                    Button("clicky") {
//                        var note = Note(context: managedObjectContext)
//                        note.title = "The first"
//                        note.body = "Something"
//
//                        PersistenceController.shared.save()
//                    }
//                }
    }
    
    private func deleteNote(_ note: Note) -> Void {
        
    }
}

struct NotesPreview: PreviewProvider {
    static var previews: some View {
        NotesHome().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .frame(width: 800, height: 800)
    }
}
