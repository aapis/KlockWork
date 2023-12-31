//
//  Results.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Results: View {
    @Binding public var text: String
    private var showRecords: Bool = false
    private var showNotes: Bool = false
    private var showTasks: Bool = false
    private var showProjects: Bool = false
    private var showJobs: Bool = false
    private var allowAlive: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var tabs: [ToolbarButton] = []
    
    @FetchRequest private var records: FetchedResults<LogRecord>
    @FetchRequest private var notes: FetchedResults<Note>
    @FetchRequest private var tasks: FetchedResults<LogTask>
    @FetchRequest private var projects: FetchedResults<Project>
    @FetchRequest private var jobs: FetchedResults<Job>
    
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
    
    public init(text: Binding<String>, showRecords: Bool = false, showNotes: Bool = false, showTasks: Bool = false, showProjects: Bool = false, showJobs: Bool = false, allowAlive: Bool = false) {
        self._text = text
        // show/hide values
        self.showRecords = showRecords
        self.showNotes = showNotes
        self.showTasks = showTasks
        self.showProjects = showProjects
        self.showJobs = showJobs
        // configuration options
        self.allowAlive = allowAlive
        
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
        jr.predicate = NSPredicate(format: "(uri CONTAINS[c] %@ OR jid.stringValue BEGINSWITH %@) AND alive = true", text.wrappedValue, text.wrappedValue)
        jr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.jid, ascending: false)
        ]
        self._jobs = FetchRequest(fetchRequest: jr, animation: .easeInOut)
        
        
    }
}
