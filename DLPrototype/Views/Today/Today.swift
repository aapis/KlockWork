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
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var taskUrl: String = "" // only treated as a string, no need to be URL-type
    @State private var isUrl: Bool = true

    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("autoFixJobs") public var autoFixJobs: Bool = false
    @AppStorage("today.showLegacyForm") public var showLegacyJobForm: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var ce: CoreDataCalendarEvent

    @FocusState private var primaryTextFieldInFocus: Bool
    
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
        .onChange(of: nav.session.job, perform: actionOnChangeJob)
        .onChange(of: nav.session.date, perform: actionOnChangeDate)
    }
    
    // MARK: Editor view
    var editor: some View {
        VStack(alignment: .leading) {
            // TODO: remove (currently testing usability w/o these fields)
            if showLegacyJobForm {
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
                                if let newUrl = URL(string: taskUrl) {
                                    jobId = UrlHelper.parts(of: newUrl).jid_string
                                }
                                
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
            }
            
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    FancyTextField(
                        placeholder: nav.session.job != nil ? "Type and hit enter to create a record" : "Choose a job from the recent jobs list in the sidebar",
                        lineLimit: 6,
                        onSubmit: submitAction,
                        fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? .black : .white : .white,
                        text: $text
                    )
                    .background(nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!) : .clear)
                    .focused($primaryTextFieldInFocus)
                    .onAppear {
                        // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            self.primaryTextFieldInFocus = true
                        }
                    }

                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            FancyButtonv2(
                                text: nav.session.job != nil ? "Log to job \(nav.session.job!.jid)" : "Log",
                                action: submitAction,
                                icon: "plus",
                                fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? .black : .white : .white,
                                showLabel: false,
                                size: .tiny,
                                type: .clear
                            )
                            .frame(width: 30, height: 30)
                            .background(nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!) : Theme.toolbarColour)
                            .disabled(nav.session.job == nil)
                        }
                    }
                }
                .frame(height: 130)
            }
        }
    }
    
    // MARK: Table view
    var table: some View {
        LogTable(job: $jobId, defaultSelectedDate: defaultSelectedDate)
            .id(updater.get("today.table"))
            .environmentObject(updater)
            .environmentObject(ce)
            .environmentObject(nav)
    }
}

extension Today {
    private func onAppear() -> Void {
        let todaysRecords = LogRecords(moc: moc).forDate(Date())
        if let record = todaysRecords.first {
            let rounded = record.job!.jid.rounded(.toNearestOrEven)
            jobId = String(Int(exactly: rounded) ?? 0)
        }

        if let date = defaultSelectedDate {
            nav.session.date = date
        }

        if showExperimentalFeatures {
            if autoFixJobs {
                AutoFixJobs.run(records: todaysRecords, context: moc)
            }
        }
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        if let jerb = job {
            let rounded = jerb.jid.rounded(.toNearestOrEven)
            jobId = String(Int(exactly: rounded) ?? 0)
        }
    }

    private func actionOnChangeDate(date: Date) -> Void {}

    private func reloadUi() -> Void {
        updater.updateOne("today.table")
        updater.updateOne("today.picker")
    }

    private func submitAction() -> Void {
        if !text.isEmpty && (!jobId.isEmpty || !taskUrl.isEmpty) {
            var jid: Double = 0.0
            if let newUrl = URL(string: taskUrl) {
                jid = UrlHelper.parts(of: newUrl).jid_double!
            } else {
                jid = Double(jobId)!
            }

            let record = LogRecord(context: moc)
            record.timestamp = Date()
            record.message = text
            record.alive = true
            record.id = UUID()

            nav.session.idate = DateHelper.identifiedDate(for: record.timestamp!, moc: moc)

            let match = CoreDataJob(moc: moc).byId(jid)

            if match == nil {
                let job = Job(context: moc)
                job.jid = jid
                job.id = UUID()
                job.records = NSSet(array: [record])
                job.colour = Color.randomStorable()
                job.created = Date()
                job.lastUpdate = Date()

                if !taskUrl.isEmpty && isUrl {
                    job.uri = URL(string: taskUrl)
                }

                record.job = job
            } else {
                record.job = match!
                // TODO: figure out why this causes Project.compare exception
//                match!.lastUpdate = record.timestamp!
            }

            text = ""
            taskUrl = ""
            reloadUi()

            PersistenceController.shared.save()
        } else {
            print("[error] Message, job ID OR task URL are required to submit")
        }
    }

    // TODO: convert to current in progress event status update UX/UI
//    @ViewBuilder private var actions: some View {
//        HStack {
//            ForEach(chipsEventsInProgress, id: \.self) { chip in
//                if let title = chip.title {
//                    FancyChip(text: title, type: .green, icon: "clock.fill") {
//                        chipCallback(title: title, type: .inProgress)
//                    }
//                }
//            }
//        }
////        .onAppear(perform: CalendarToday.createEventChips)
//    }

//    private func chipCallback(title: String, type: CalendarEventType) -> Void {
//        // TODO: allow users to choose the job to assign this record to (requires a bunch of changes)
//        if let defaultJob = CoreDataJob(moc: moc).getDefault() {
//            CoreDataRecords(moc: moc).createWithJob(
//                job: defaultJob,
//                date: Date(),
//                text: "Meeting finished: \(title)"
//            )
//
//            if type == .inProgress {
//                chipsEventsInProgress.removeAll(where: ({$0.title == title}))
//                let _ = ce.store(events: chipsEventsInProgress, type: .inProgress)
//
//            }
//
//            reloadUi()
//        }
//    }
}
