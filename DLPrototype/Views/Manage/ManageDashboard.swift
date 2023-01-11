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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created)]) public var tasks: FetchedResults<LogTask>
    
    @State private var isDeleteRecordsConfirmationPresented: Bool = false
    @State private var isDeleteNotesConfirmationPresented: Bool = false
    @State private var isDeleteTasksConfirmationPresented: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Title(text: "Manage your data", image: "books.vertical")
                
                // MARK: danger button(s)
                HStack(alignment: .top) {
                    FancyButton(text: "Truncate \(records.count) Records + Jobs", action: {showDelete(&isDeleteRecordsConfirmationPresented)})
                    .confirmationDialog("Did you backup records first?", isPresented: $isDeleteRecordsConfirmationPresented) {
                        Button("Yes", role: .destructive) {
                            burnRecordsAndJobs()
                        }
                        Button("Cancel", role: .cancel) {
                            hideDelete(&isDeleteRecordsConfirmationPresented)
                        }
                    }
                    
                    FancyButton(text: "Truncate \(notes.count) Notes", action: {showDelete(&isDeleteNotesConfirmationPresented)})
                    .confirmationDialog("Did you backup notes first?", isPresented: $isDeleteNotesConfirmationPresented) {
                        Button("Yes", role: .destructive) {
                            burnNotes()
                        }
                        Button("Cancel", role: .cancel) {
                            hideDelete(&isDeleteNotesConfirmationPresented)
                        }
                    }
                    
                    FancyButton(text: "Truncate \(tasks.count) Tasks", action: {showDelete(&isDeleteTasksConfirmationPresented)})
                    .confirmationDialog("Did you backup tasks first?", isPresented: $isDeleteTasksConfirmationPresented) {
                        Button("Yes", role: .destructive) {
                            burnTasks()
                        }
                        Button("Cancel", role: .cancel) {
                            hideDelete(&isDeleteTasksConfirmationPresented)
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
    
    private func burnTasks() -> Void {
        for task in tasks {
            moc.delete(task)
            
            PersistenceController.shared.save()
        }
    }
    
    // https://medium.com/@sajalgupta4me/cannot-assign-to-value-is-a-let-constant-swift-1a55d829f5b2
    private func showDelete(_ dialog: inout Bool) -> Void {
        dialog = true
    }
    
    private func hideDelete(_ dialog: inout Bool) -> Void {
        dialog = false
    }
}

struct ManageDashboardPreview: PreviewProvider {
    static var previews: some View {
        ManageDashboard().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
