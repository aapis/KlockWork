//
//  ManageDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ManageDashboard: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp)]) public var records: FetchedResults<LogRecord>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate)]) public var notes: FetchedResults<Note>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid)]) public var jobs: FetchedResults<Job>
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Title(text: "Manage your data", image: "books.vertical")
                
                // MARK: danger button(s)
                HStack(alignment: .top) {
                    FancyButton(text: "Truncate \(records.count) Records + Jobs", action: showDelete)
                    .confirmationDialog("Did you backup first?", isPresented: $isDeleteConfirmationPresented) {
                        Button("Yes", role: .destructive) {
                            burnRecordsAndJobs()
                        }
                        Button("Cancel", role: .cancel) {
                            hideDelete()
                        }
                    }
                    
                    FancyButton(text: "Truncate \(notes.count) Notes", action: showDelete)
                    .confirmationDialog("Did you backup first?", isPresented: $isDeleteConfirmationPresented) {
                        Button("Yes", role: .destructive) {
                            burnNotes()
                        }
                        Button("Cancel", role: .cancel) {
                            hideDelete()
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    private func burnRecordsAndJobs() -> Void {
        for record in records {
            moc.delete(record)
            
            PersistenceController.shared.save()
        }
        
        for job in jobs {
            moc.delete(job)
            
            PersistenceController.shared.save()
        }
    }
    
    private func burnNotes() -> Void {
        for note in notes {
            moc.delete(note)
            
            PersistenceController.shared.save()
        }
    }
    
    private func showDelete() -> Void {
        isDeleteConfirmationPresented = true
    }
    
    private func hideDelete() -> Void {
        isDeleteConfirmationPresented = false
    }
}

struct ManageDashboardPreview: PreviewProvider {
    static var previews: some View {
        ManageDashboard().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
