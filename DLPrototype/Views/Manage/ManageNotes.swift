//
//  ManageNotes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ManageNotes: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate, order: .reverse)]) public var data: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Title(text: "Notes", image: "note.text")
                    
                    List(data, id: \.id) { note in
                        HStack {
//                            Text("\(DateHelper.shortDateWithTime(note.postedDate!))")
                            Text(note.title ?? "Invalid title")
                            Spacer()
                            
//                            FancyButton(text: "Delete", action: showDelete, icon: "xmark", transparent: true, showLabel: false)
//                            .confirmationDialog("Are you sure you want to delete?", isPresented: $isDeleteConfirmationPresented) {
//                                Button("Yes", role: .destructive) {
//                                    print("NOTE: \(note.title!)")
//                                    print("NOTE: \(note.postedDate!)")
////                                        delete(note)
//                                }
//                                Button("Cancel", role: .cancel) {
//                                    hideDelete()
//                                }
//                            }
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    private func delete(_ note: Note) -> Void {
        moc.delete(note)
        
        PersistenceController.shared.save()
    }
    
    private func showDelete() -> Void {
        isDeleteConfirmationPresented = true
    }
    
    private func hideDelete() -> Void {
        isDeleteConfirmationPresented = false
    }
}
