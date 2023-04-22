//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//
import Foundation
import SwiftUI
import Combine

struct Today: View {
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var taskUrl: String = "" // only treated as a string, no need to be URL-type
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("autoFixJobs") public var autoFixJobs: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.timestamp, order: .reverse)
        ],
        predicate: NSPredicate(format: "timestamp > %@ && timestamp <= %@", DateHelper.thisAm(), DateHelper.tomorrow())
    ) public var rawToday: FetchedResults<LogRecord>
    
    private var today: FetchedResults<LogRecord> {
        if showExperimentalFeatures {
            if autoFixJobs {
                AutoFixJobs.run(records: rawToday, context: moc)
            }
        }
        
        return rawToday
    }
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            editor
            table
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .defaultAppStorage(.standard)
        .background(Theme.toolbarColour)
        .onAppear(perform: onAppear)
    }
    
    // MARK: Editor view
    var editor: some View {
        VStack(alignment: .leading) {
            HStack {                
                JobPickerUsing(onChange: pickerChange, supportsDynamicPicker: true, jobId: $jobId)
                
                Text("Or").font(Theme.font)
                
                FancyTextField(placeholder: "Task URL", lineLimit: 1, onSubmit: {}, text: $taskUrl)
                    .onReceive(Just(jobId)) { input in
                        let filtered = input.filter { "0123456789".contains($0) }
                        if filtered != input {
                            jobId = filtered
                        }
                    }
            }
            
            VStack {
                FancyTextField(
                    placeholder: "Type and hit enter to save...",
                    lineLimit: 6,
                    onSubmit: submitAction,
                    text: $text
                )
            }
        }
    }
    
    // MARK: Table view
    var table: some View {
        LogTable(selectedJob: $jobId)
            .id(updater.ids["today.table"])
            .environmentObject(updater)
    }
    
    // MARK: loading view
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                ProgressView("Loading Workspace...")
                Spacer()
            }
            
            Spacer()
        }
        .onDisappear(perform: reloadUi)
    }
    
    private func onAppear() -> Void {
        setDefaultJob()
    }
    
    private func setDefaultJob() -> Void {
        let record = today.first
        
        if record != nil {
            let rounded = record!.job!.jid.rounded(.toNearestOrEven)
            jobId = String(Int(exactly: rounded) ?? 0)
        }
    }
    
    private func pickerChange(selected: Int, sender: String?) -> Void {
//        jobId = String(selected)
    }

    public func reloadUi() -> Void {
        updater.updateOne("today.table")
        updater.updateOne("today.picker")
    }
    
    private func submitAction() -> Void {
        if !text.isEmpty && (!jobId.isEmpty || !taskUrl.isEmpty) {
            let jid = getJobIdFromUrl()
            let record = LogRecord(context: moc)
            record.timestamp = Date()
            record.message = text
            record.id = UUID()
            
            let match = CoreDataJob(moc: moc).byId(jid)
            
            if match == nil {
                let job = Job(context: moc)
                job.jid = jid
                job.id = UUID()
                job.records = NSSet(array: [record])
                job.colour = Color.randomStorable()
                
                if !taskUrl.isEmpty {
                    job.uri = URL(string: taskUrl)
                }
                
                record.job = job
            } else {
                record.job = match
            }
            
            // clear input fields
            text = ""
            taskUrl = ""
            // redraw the views that need to be updated
            reloadUi()
            
            PersistenceController.shared.save()
        } else {
            print("Message, job ID OR task URL are required to submit")
        }
    }
    
    private func getJobIdFromUrl() -> Double {
        if !taskUrl.isEmpty {
            if isAsanaLink() {
                let id = asanaJobId()
                if id != nil {
                    jobId = String(id!.suffix(6))
                }
            } else {
                jobId = String(taskUrl.suffix(6))
            }
        }
        
        let defaultJid = 11.0

        return Double(jobId) ?? defaultJid
    }
    
    private func asanaJobId() -> String? {
        let pattern = /https:\/\/app.asana.com\/0\/\d+\/(\d+)\/f/
        
        if let match = taskUrl.firstMatch(of: pattern) {
            return String(match.1)
        }
        
        return nil
    }
    
    private func isAsanaLink() -> Bool {
        let pattern = /^https:\/\/app.asana.com/
        
        return taskUrl.contains(pattern)
    }
}

struct TodayPreview: PreviewProvider {
    static var previews: some View {
        Today()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
            .frame(width: 800, height: 800)
    }
}
