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
    @State private var workspaceReady: Bool = false
    // LogTableDetail object id.  We change this on submit and it triggers this view to re-render, showing the new content
    @State private var ltd: UUID = UUID()
    // Table object UUID
    @State private var tableUuid: UUID = UUID()
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.jid)
        ]
    ) public var jobs: FetchedResults<Job>
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.timestamp, order: .reverse)
        ],
//        predicate: NSPredicate(format: "timestamp > %@ && timestamp <= %@", DateHelper.daysPast(5), DateHelper.tomorrow())
        predicate: NSPredicate(format: "timestamp > %@", DateHelper.yesterday()) // TODO: predicate is ONLY FOR TESTING
    ) public var today: FetchedResults<LogRecord>
    
    @Environment(\.managedObjectContext) var moc
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            Title(text: "Record an entry", image: "doc.append.fill")
            
            if today.count == 0 {
                loading
            } else {
                if workspaceReady {
                    editor
                    table
                } else {
                    loading
                }
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
            .defaultAppStorage(.standard)
            .background(Theme.toolbarColour)
            
    }
    
    // MARK: Editor view
    var editor: some View {
        VStack(alignment: .leading) {
            HStack {
                // TODO: not ready for primetime
                LogTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, text: $jobId)
                    .frame(width: 200, height: 40)
                
                Text("Or").font(Theme.font)
                
                LogTextField(placeholder: "Task URL", lineLimit: 1, onSubmit: {}, text: $taskUrl)
                
                Picker("Job", selection: $jobPickerSelection) {
                    ForEach(recentJobs) { item in
                        Text(item.title)
                            .tag(item.tag)
                            .disabled(item.disabled)
                            .font(Theme.font)
                    }
                }
                .onChange(of: ltd, perform: { _ in
                    updateRecentJobs()
                })
                .onAppear(perform: reloadUi)
                .labelsHidden()
                .frame(width: 200)
                .font(Theme.font)
                .onChange(of: jobPickerSelection) { _ in
                    // modifies jobId to associate the job to the message
                    jobId = String(jobPickerSelection)
                    jobPickerSelection = 0 // TODO: should reset picker to first item but doesn't for $reasons
                }
            }
            
            VStack {
                LogTextField(
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
        LogTable(today: today, ltd: $ltd)
            .id(tableUuid)
    }
    
    // MARK: loading view
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                ProgressView("Loading Workspace")
                Spacer()
            }
            
            Spacer()
        }
        .onDisappear(perform: reloadUi)
    }

    private func reloadUi() -> Void {
        func reload() {
            ltd = UUID()
            tableUuid = UUID()
            updateRecentJobs()
            workspaceReady = true
        }

        // if we have records reload the after 1s
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            reload()
        }
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
//                print("Today::recentJobs \(jid)")
                recentJobs.append(CustomPickerItem(title: jid, tag: Int(jid) ?? 1))
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
            
            let matchingJob = jobs.first(where: { $0.jid == jid })
            
            if matchingJob == nil {
                let job = Job(context: moc)
                job.jid = jid
                job.id = UUID()
                job.records = NSSet(array: [record])
                job.colour = Color.randomStorable()
                
                if !taskUrl.isEmpty {
                    job.uri = URL(string: taskUrl)
                }
                
                record.job = job
                PersistenceController.shared.save()
            } else {
                record.job = matchingJob
            }
            
            // clear text box
            text = ""
            // TODO: find a better solution to this updating the view problem
            // redraw the views that need to be updated
            ltd = UUID()
            
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
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 800, height: 800)
    }
}
