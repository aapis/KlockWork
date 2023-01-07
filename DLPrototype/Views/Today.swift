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
//    @ObservedObject public var recordsModel: LogRecords
    
    @State public var text: String = ""
    @State public var id = UUID()
    @State private var jobId: String = ""
    // only treated as a string, no need to be URL-type
    @State private var taskUrl: String = ""
    @State private var recentJobs: [CustomPickerItem] = [CustomPickerItem(title: "Recent jobs", tag: 0)]
    @State private var jobPickerSelection = 0
    // Workspace is ready to use
    @State private var workspaceReady: Bool = false
    // Current date
    @State private var currentDate: Date = Date()
    // Date value the last time we checked
    @State private var dateAtLastCheck: Date = Date()
    // Flag to determine whether the date has changed and thus the UI needs a reload
    @State private var dateHasChanged: Bool = false
    // Flag for whether we are currently loading
    @State private var isLoading: Bool = true
    // Number of records synced from CD, for the loading view
    @State private var numSyncedRecords: Float = 0.0
    // LogTableDetail object id.  We change this on submit and it triggers this view to re-render, showing the new content
    @State private var ltd: UUID = UUID()
    // Table object UUID
    @State private var tableUuid: UUID = UUID()
    
    private let sm: SyncMonitor = SyncMonitor()
    
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
        predicate: NSPredicate(format: "timestamp > %@", DateHelper.thisAm()) // TODO: predicate is ONLY FOR TESTING
    ) public var today: FetchedResults<LogRecord>
//    public var today: FetchedResults<LogRecord>
//    public var today: [LogRecord] = []
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var recordsModel: LogRecords
    
//    public init() {
////        self.recordsModel = recordsModel
//
//        self.today = recordsModel.recordsForToday
//    }
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Title(text: "Record an entry", image: "doc.append.fill")
                
                Spacer()
                Button(action: startLoading, label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                })
                .buttonStyle(.borderless)
                .font(.title)
            }

            if isLoading {
                loading
            } else {
                editor.onAppear(perform: checkDate)
                table
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
            .defaultAppStorage(.standard)
            .background(Theme.toolbarColour)
            .onReceive(sm.publisher) { _ in
                // this currently does the data/status updating
                received()
            }
//            .onChange(of: recordsModel.recordsForToday, perform: { something in
//                print("oh noes")
//                print(something)
//                reloadUi()
//            })
            
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
//                    jobPickerSelection = 0 // TODO: should reset picker to first item but doesn't for $reasons
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
                ProgressView("Loading Workspace...")
                Spacer()
            }
            
            Spacer()
        }
//        .onDisappear(perform: reloadUi)
    }
    
    private func received() -> Void {
        print("SM: [Today] Received \(sm.ready)")
        
        if sm.ready {
            isLoading = false
        }
    }
    
    private func checkDate() -> Void {
        print("Today::checkDate [init] \(DateHelper.todayShort(currentDate))")
        dateAtLastCheck = currentDate
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
            let shortCurrentDate = DateHelper.shortDate(
                DateHelper.todayShort(currentDate)
            )
            let shortLastCheckDate = DateHelper.shortDate(
                DateHelper.todayShort(dateAtLastCheck)
            )
            
            print("Today::checkDate [timer] \(shortCurrentDate) > \(shortLastCheckDate) \(currentDate)")
            
            if shortCurrentDate != nil && shortLastCheckDate != nil {
                if shortCurrentDate! > shortLastCheckDate! {
                    print("Today::checkDate [timer.dateChanged]")
                    dateHasChanged = true
                }
            }
            
            currentDate = Date() + 86400 // TODO: this is just for testing
        }
    }

    private func reloadUi() -> Void {
//        isLoading = true
        
        func reload() {
            ltd = UUID()
            tableUuid = UUID()
            updateRecentJobs()
            workspaceReady = true
            dateHasChanged = false
            isLoading = false
        }

        // if we have records reload the after 1s
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            reload()
        }
    }
    
    private func startLoading() -> Void {
        isLoading = true
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
