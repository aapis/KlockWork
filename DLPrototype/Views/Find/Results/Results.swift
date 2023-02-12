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
    @Binding private var showRecords: Bool
    @Binding private var showNotes: Bool
    @Binding private var showTasks: Bool
    @Binding private var showProjects: Bool
    @Binding private var showJobs: Bool
    @Binding private var allowAlive: Bool
    
    @State private var isLoading: Bool = false
    
    @FetchRequest private var records: FetchedResults<LogRecord>
    @FetchRequest private var notes: FetchedResults<Note>
    @FetchRequest private var tasks: FetchedResults<LogTask>
    @FetchRequest private var projects: FetchedResults<Project>
    @FetchRequest private var jobs: FetchedResults<Job>
    
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if records.count > 0 && showRecords {
                    RecordResult(bucket: records, text: $text, isLoading: $isLoading)
                        .environmentObject(updater)
                }
                
                if notes.count > 0 && showNotes {
                    NoteResult(bucket: notes, text: $text, isLoading: $isLoading)
                }
                
                if tasks.count > 0 && showTasks {
                    TaskResult(bucket: tasks, text: $text, isLoading: $isLoading)
                }
                
                if projects.count > 0 && showProjects {
                    ProjectResult(bucket: projects, text: $text, isLoading: $isLoading)
                        .environmentObject(jm)
                }
                
                if jobs.count > 0 && showJobs {
                    JobResult(bucket: jobs, text: $text, isLoading: $isLoading)
                }
            }
        }
    }
    
    public init(text: Binding<String>, showRecords: Binding<Bool>, showNotes: Binding<Bool>, showTasks: Binding<Bool>, showProjects: Binding<Bool>, showJobs: Binding<Bool>, allowAlive: Binding<Bool>) {
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
        nr.predicate = NSPredicate(format: "(body CONTAINS[c] %@ OR title CONTAINS[c] %@) AND alive = true", text.wrappedValue, text.wrappedValue)
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
        pr.predicate = NSPredicate(format: "name CONTAINS[c] %@ AND alive = true", text.wrappedValue)
        pr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.created, ascending: false)
        ]
        self._projects = FetchRequest(fetchRequest: pr, animation: .easeInOut)
        
        // fetch all jobs where the URI matches $text
        let jr: NSFetchRequest<Job> = Job.fetchRequest()
        jr.predicate = NSPredicate(format: "(uri CONTAINS[c] %@ OR jid.string CONTAINS[c] %@) AND alive = true", text.wrappedValue, text.wrappedValue)
        jr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.jid, ascending: false)
        ]
        self._jobs = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        
        // show/hide values
        self._showRecords = showRecords
        self._showNotes = showNotes
        self._showTasks = showTasks
        self._showProjects = showProjects
        self._showJobs = showJobs
        // configuration options
        self._allowAlive = allowAlive
    }
}
