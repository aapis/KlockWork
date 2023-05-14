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
import EventKit

struct Today: View {
    public var defaultSelectedDate: Date?
    public var cs: CalendarService = CalendarService()
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var taskUrl: String = "" // only treated as a string, no need to be URL-type
    @State private var isUrl: Bool = true
    @State private var chipsEventsInProgress: [EKEvent] = []
    @State private var chipsEventsUpcoming: [EKEvent] = []
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("autoFixJobs") public var autoFixJobs: Bool = false
    @AppStorage("today.calendar") public var calendar: Int = 0
    
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
            actions
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
                JobPickerUsing(onChange: {_,_ in }, supportsDynamicPicker: true, jobId: $jobId)
                    .onReceive(Just(jobId)) { input in
                        let filtered = input.filter { "0123456789".contains($0) }
                        if filtered != input {
                            jobId = filtered
                        }
                    }
                
                Text("Or").font(Theme.font)
                
                // TODO: background colours stack here, fix that
                FancyTextField(placeholder: "Task URL", lineLimit: 1, onSubmit: {}, text: $taskUrl)
                    .onChange(of: taskUrl) { url in
                        if !url.isEmpty {
                            if url.starts(with: "https:") {
                                isUrl = true
                            } else {
                                isUrl = false
                            }
                        } else {
                            isUrl = true
                        }
                    }
                    .background(isUrl ? Color.clear : Theme.rowStatusRed)
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
        LogTable(job: $jobId, defaultSelectedDate: defaultSelectedDate)
            .id(updater.ids["today.table"])
            .environmentObject(updater)
    }
    
    @ViewBuilder private var actions: some View {
        HStack {
            ForEach(chipsEventsInProgress, id: \.self) { chip in
                if let title = chip.title {
                    FancyChip(text: "Event in progress: \(title)", action: {
                        inProgressChipCallback(title: title)
                    })
                }
            }
            
            ForEach(chipsEventsUpcoming, id: \.self) { chip in
                if let title = chip.title {
                    FancyChip(text: "Upcoming event: \(title)", action: {})
                }
            }
        }
        .onAppear(perform: createEventChips)
    }
    
    private func createEventChips() -> Void {
        if calendar > 0 {
            if let chosenCalendar = cs.getCalendarName(calendar) {
                chipsEventsInProgress = cs.eventsInProgress(chosenCalendar)
                chipsEventsUpcoming = cs.eventsUpcoming(chosenCalendar)
            }
        }   
    }
    
    private func inProgressChipCallback(title: String) -> Void {
        chipsEventsInProgress.removeAll(where: ({$0.title == title}))
        
        if let defaultJob = CoreDataJob(moc: moc).getDefault() {
            CoreDataRecords(moc: moc).createWithJob(
                job: defaultJob,
                date: Date(),
                text: "Meeting finished: \(title)"
            )
        }
        
        reloadUi()
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
                
                if !taskUrl.isEmpty && isUrl {
                    // TODO: add some kind of popup or something here and make them send again
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
            print("[error] Message, job ID OR task URL are required to submit")
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
