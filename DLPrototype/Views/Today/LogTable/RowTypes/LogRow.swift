//
//  LogRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogRow: View, Identifiable {
    public var id = UUID()
    public var entry: Entry
    public var index: Array<Entry>.Index?
    public var colour: Color
    public var record: LogRecord?
    public var viewRequiresColumns: Set<RecordTableColumn> = []

    @State public var isEditing: Bool = false
    @State public var message: String = ""
    @State public var job: String = ""
    @State public var timestamp: String = ""
    @State public var aIndex: String = "0"
    @State public var activeColour: Color = Theme.rowColour
    @State public var projectColHelpText: String = ""
    @State public var showingTimestampColumn: Bool = true
    @State public var columns: Set<RecordTableColumn> = [.message]
    @State private var isDeleteAlertShowing: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jm: CoreDataJob
    
    @AppStorage("tigerStriped") private var tigerStriped = false
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnExtendedTimestamp") public var showColumnExtendedTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true

    var body: some View {
        if isEditing {
            VStack {
                ZStack {
                    Color.black
                    ViewModeNormal
                        .opacity(0.5)
                }
            }
            ViewModeEdit
        } else {
            ViewModeNormal
        }
    }

    var ViewModeNormal: some View {
        HStack(spacing: 1) {
            GridRow {
                Column(
                    type: .index,
                    colour: (entry.jobObject != nil  && entry.jobObject!.project != nil ? Color.fromStored(entry.jobObject!.project!.colour ?? Theme.rowColourAsDouble) : applyColour()),
                    textColour: rowTextColour(),
                    text: $projectColHelpText
                )
                .frame(width: 5)

                if columns.contains(.index) {
                    Column(
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        text: $aIndex
                    )
                    .frame(maxWidth: 50)
                }

                if columns.contains(.extendedTimestamp) {
                    Column(
                        type: .extendedTimestamp,
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        index: index,
                        alignment: .center,
                        text: $timestamp
                    )
                    .frame(maxWidth: 101)
                    .help(entry.timestamp)
                }

                if columns.contains(.timestamp) {
                    Column(
                        type: .timestamp,
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        index: index,
                        alignment: .center,
                        text: $timestamp
                    )
                    .frame(maxWidth: 101)
                    .help(entry.timestamp)
                }

                if columns.contains(.job) {
                    Column(
                        type: .job,
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        index: index,
                        alignment: .center,
                        url: (entry.jobObject != nil && entry.jobObject!.uri != nil ? entry.jobObject!.uri : nil),
                        job: entry.jobObject,
                        text: $job
                    )
                    .frame(maxWidth: 80)
                }

                if columns.contains(.message) {
                    Column(
                        type: .message,
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        index: index,
                        alignment: .leading,
                        text: $message
                    )
                }
            }
            .contextMenu { contextMenu }
        }
        .defaultAppStorage(.standard)
        .onAppear(perform: setEditableValues)
        .onChange(of: timestamp) { _ in
            if !isEditing {
                setEditableValues()
            }
        }
    }

    private var ViewModeEdit: some View {
        VStack(alignment: .leading) {
            // onChange cb intentionally void
            JobPickerUsing(onChange: {_,_ in }, jobId: $job)
            FancyDivider()

            VStack(alignment: .leading) {
                Text("Time")
                FancyTextField(placeholder: "Post date", lineLimit: 1, text: $timestamp)
            }

            VStack(alignment: .leading) {
                Text("Message")
                FancyTextField(placeholder: "Message", lineLimit: 6, text: $message)
            }

            Spacer()
            HStack(spacing: 10) {
                FancyButtonv2(text: "Delete", action: {isDeleteAlertShowing = true}, icon: "trash", showLabel: false, type: .destructive)
                    .alert("Are you sure you want to delete this record?", isPresented: $isDeleteAlertShowing) {
                        Button("Yes", role: .destructive) {
                            softDelete()
                        }
                        Button("No", role: .cancel) {}
                    }
                Spacer()
                FancyButtonv2(text: "Cancel", action: {isEditing.toggle()}, icon: "xmark", showLabel: false)
                FancyButtonv2(text: "Save", action: save, size: .medium, type: .primary)
            }
        }
        .padding()
        .background(Theme.darkBtnColour)
    }
    
    @ViewBuilder private var contextMenu: some View {
        if entry.jobObject != nil {
            Button("Edit record") {
                isEditing = true
            }

            if entry.jobObject!.uri != nil {
                Link(destination: entry.jobObject!.uri!, label: {
                    Text("Open job link in browser")
                })
            }

            Divider()

            Menu("Copy") {
                if entry.jobObject!.uri != nil {
                    Button(action: {ClipboardHelper.copy(entry.jobObject!.uri!.absoluteString)}, label: {
                        Text("Job URL")
                    })
                }
                
                Button(action: {ClipboardHelper.copy(entry.jobObject!.jid.string)}, label: {
                    Text("Job ID")
                })
                
                Button(action: {ClipboardHelper.copy(colour.description.debugDescription)}, label: {
                    Text("Job colour code")
                })
                
                Button(action: {ClipboardHelper.copy(entry.message)}, label: {
                    Text("Message")
                })
            }
            
            Menu("Go to"){
                Button {
                    nav.view = AnyView(NoteDashboard(defaultSelectedJob: entry.jobObject).environmentObject(jm))
                    nav.parent = .notes
                } label: {
                    Text("Notes")
                }
                
                Button {
                    nav.view = AnyView(TaskDashboard(defaultSelectedJob: entry.jobObject!).environmentObject(jm))
                    nav.parent = .tasks
                } label: {
                    Text("Tasks")
                }
                
                if entry.jobObject!.project != nil {
                    Button {
                        nav.view = AnyView(ProjectView(project: entry.jobObject!.project!).environmentObject(jm))
                        nav.parent = .projects
                        nav.sidebar = AnyView(ProjectsDashboardSidebar())
                    } label: {
                        Text("Project")
                    }
                }
                
                Button {
                    nav.view = AnyView(JobDashboard(defaultSelectedJob: entry.jobObject!))
                    nav.parent = .jobs
                    nav.sidebar = AnyView(JobDashboardSidebar())
                    nav.pageId = UUID()
                } label: {
                    Text("Job")
                }
            }

            Menu("Inspect") {
                Text("SR&ED Eligible: " + (entry.jobObject!.shredable ? "Yes" : "No"))
            }
            
            Divider()

            if let jo = entry.jobObject {
                Button(action: {setJob(jo.jid.string)}, label: {
                    Text("Set job")
                })
            }
        }
    }
    
    private func setJob(_ job: String) -> Void {
//        let dotIndex = (job.range(of: ".")?.lowerBound)
        
//        if dotIndex != nil {
//            selectedJob = String(job.prefix(upTo: dotIndex!))
//            nav.session.setJob()
            
            if let jobIdDbl = Double(job) {
                nav.session.setJob(CoreDataJob(moc: moc).byId(jobIdDbl))
            }
//        }
    }

    // TODO: remove?
    private func setEditableValues() -> Void {
        message = entry.message
        job = entry.job
        timestamp = entry.timestamp
        aIndex = adjustedIndexAsString()

        // shows timestamp column on row hover
        showingTimestampColumn = showColumnTimestamp

        if !viewRequiresColumns.isEmpty {
            columns = columns.union(viewRequiresColumns)
        }
    }

    private func applyColour() -> Color {
        if tigerStriped {
            return colour.opacity(index!.isMultiple(of: 2) ? 1 : 0.5)
        }

        return colour
    }
    
    private func rowTextColour() -> Color {
        return colour.isBright() ? Color.black : Color.white
    }
    
    private func adjustedIndex() -> Int {
        var adjusted: Int = Int(index!)
        adjusted += 1

        return adjusted
    }
    
    private func adjustedIndexAsString() -> String {
        let adjusted = adjustedIndex()
        
        return String(adjusted)
    }

    private func save() -> Void {
        if let rec = record {
            if !message.isEmpty && !job.isEmpty {
                rec.timestamp = newDate()
                rec.message = message
                rec.id = entry.id
                
                if let jid = Double(job) {
                    if let match = CoreDataJob(moc: moc).byId(jid) {
                        rec.job = match
                        match.lastUpdate = Date()
                    }
                }

                PersistenceController.shared.save()
                isEditing.toggle()
            } else {
                print("[error] Message, job ID OR task URL are required to submit")
            }
        }
    }

    private func newDate() -> Date? {
        if let newDate = DateHelper.date(timestamp, fmt: "yyyy-MM-dd HH:mm:ss") {
            return newDate
        }

        // default to now if date cannot be parsed for some reason
        return Date()
    }

    private func softDelete() -> Void {
        isDeleteAlertShowing = false
        CoreDataRecords.softDelete(record!)
        isEditing.toggle()
        updater.updateOne("today.table")
    }
}

struct LogTableRowPreview: PreviewProvider {
    @State static public var sj: String = "11.0"
    
    static var previews: some View {
        VStack {
            LogRow(entry: Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world"), index: 0, colour: Theme.rowColour)
            LogRow(entry: Entry(timestamp: "2023-01-01 19:49", job: "11", message: "Hello, world"), index: 1, colour: Theme.rowColour)
        }
    }
}
