//
//  Results.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Results: View {
    @Binding public var text: String
    @State private var isLoading: Bool = false
    
    @FetchRequest private var records: FetchedResults<LogRecord>
    @FetchRequest private var notes: FetchedResults<Note>
    @FetchRequest private var tasks: FetchedResults<LogTask>
    @FetchRequest private var projects: FetchedResults<Project>
    
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        VStack(spacing: 0) {
            if records.count > 0 {
                RecordResult(bucket: records, text: $text, isLoading: $isLoading)
            }
            
            if notes.count > 0 {
                NoteResult(bucket: notes, text: $text, isLoading: $isLoading)
            }
            
            if tasks.count > 0 {
                TaskResult(bucket: tasks, text: $text, isLoading: $isLoading)
            }
            
            if projects.count > 0 {
                ProjectResult(bucket: projects, text: $text, isLoading: $isLoading)
                    .environmentObject(jm)
            }
        }
    }
    
    public init(text: Binding<String>) {
        self._text = text
        
        // all attempts to refactor this failed
        // fetch all records matching $text
        let rr: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        rr.predicate = NSPredicate(format: "message CONTAINS[c] %@", text.wrappedValue)
        rr.sortDescriptors = [
            NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)
        ]
        self._records = FetchRequest(fetchRequest: rr, animation: .easeInOut)
        
        // fetch all notes matching $text
        let nr: NSFetchRequest<Note> = Note.fetchRequest()
        nr.predicate = NSPredicate(format: "body CONTAINS[c] %@ or title CONTAINS[c] %@", text.wrappedValue, text.wrappedValue)
        nr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)
        ]
        self._notes = FetchRequest(fetchRequest: nr, animation: .easeInOut)
        
        // fetch all tasks matching $text
        let tr: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        tr.predicate = NSPredicate(format: "content CONTAINS[c] %@", text.wrappedValue)
        tr.sortDescriptors = [
            NSSortDescriptor(keyPath: \LogTask.created, ascending: false)
        ]
        self._tasks = FetchRequest(fetchRequest: tr, animation: .easeInOut)
        
        // fetch all projects matching $text
        let pr: NSFetchRequest<Project> = Project.fetchRequest()
        pr.predicate = NSPredicate(format: "name CONTAINS[c] %@", text.wrappedValue)
        pr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.created, ascending: false)
        ]
        self._projects = FetchRequest(fetchRequest: pr, animation: .easeInOut)
    }
}
