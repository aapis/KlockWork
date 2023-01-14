//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//
import Foundation
import SwiftUI

struct Today : View, Identifiable {
    @State public var text: String = ""
    @State public var id = UUID()
    @State private var jobId: String = ""
    // only treated as a string, no need to be URL-type
    @State private var taskUrl: String = ""
    @State private var recentJobs: [CustomPickerItem] = [CustomPickerItem(title: "Recent jobs", tag: 0)]
    @State private var jobPickerSelection = 0
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("autoFixJobs") public var autoFixJobs: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var recordsModel: LogRecords
    
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
            header
            editor
            table
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .defaultAppStorage(.standard)
        .background(Theme.toolbarColour)
            
    }
    
    // MARK: title/header
    var header: some View {
        HStack {
            Title(text: "Record an entry", image: "doc.append.fill")
        }
    }
    
    // MARK: Editor view
    var editor: some View {
        VStack(alignment: .leading) {
            HStack {
                FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, text: $jobId)
                    .frame(width: 200, height: 40)
                
                Text("Or").font(Theme.font)
                
                FancyTextField(placeholder: "Task URL", lineLimit: 1, onSubmit: {}, text: $taskUrl)
                
                JobPicker(onChange: pickerChange)
                    .id(updater.ids["today.picker"])
                    .onAppear(perform: reloadUi)
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
        LogTable()
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
    
    private func pickerChange(selected: Int, sender: String?) -> Void {
        jobId = String(selected)
    }

    public func reloadUi() -> Void {
        updateRecentJobs()
        updater.update()
    }
    
    private func updateRecentJobs() -> Void {
        var jobs: [String] = []

        // reset the recent jobs picker items
        recentJobs = []
        recentJobs.append(CustomPickerItem(title: "Recent jobs", tag: 0))
        
        if today.count > 0 {
            for record in today {
                if record.job?.jid.string != nil {
                    jobs.append((record.job?.jid.string)!)
                }
            }
            
            let unique = Array(Set(jobs))
            
            for jid in unique {
                let correctedJid = String(jid.dropLast(2))
                
                recentJobs.append(CustomPickerItem(title: correctedJid, tag: Int(correctedJid) ?? 1))
            }
        }
    }
    
    private func submitAction() -> Void {
        if !text.isEmpty && (!jobId.isEmpty || !taskUrl.isEmpty) {
            let jid = Double(getJobId())!
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
            
            // clear text box
            text = ""
            // redraw the views that need to be updated
            reloadUi()
            
            PersistenceController.shared.save()
        } else {
            print("Message, job ID OR task URL are required to submit")
        }
    }
    
    private func getJobId() -> String {
        if !taskUrl.isEmpty {
            jobId = String(taskUrl.suffix(5))
        }

        return jobId
    }
}

struct AddPreview: PreviewProvider {
    static var previews: some View {
        Today()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
            .frame(width: 800, height: 800)
    }
}
