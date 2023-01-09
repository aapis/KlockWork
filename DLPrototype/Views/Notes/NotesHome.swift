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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate, order: .reverse)]) public var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        NavigationSplitView {
            List(notes) { note in
                NavigationLink(note.title!, value: note)
            }
            .navigationDestination(for: Note.self) {
                NoteView(note: $0)
                    .navigationTitle("Editing: \($0.title!)")
            }
        } detail: {
            NoteDashboard()
                .navigationTitle("Note Dashboard")
            
        }
        .navigationSplitViewStyle(.prominentDetail)
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
