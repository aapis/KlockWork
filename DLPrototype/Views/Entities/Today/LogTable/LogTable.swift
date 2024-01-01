//
//  Theme.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

/// Table which displays all the records
extension Today {
    struct LogTable: View {
        private var buttons: [ToolbarButton] = []
        
        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                FancyDivider()
                FancyGenericToolbar(
                    buttons: buttons,
                    standalone: true,
                    location: .content,
                    mode: .compact
                )
            }
        }
        
        init() {
            TodayViewTab.allCases.forEach { tab in
                buttons.append(tab.button)
            }
        }
    }
}

// MARK: structs
extension Today.LogTable {
    /// Table row headers
    struct Headers: View {
        static public var required: Set<RecordTableColumn> = [.job, .message]

        var body: some View {
            GridRow {
                // project colour block
                HStack(spacing: 0) {
                    Group {
                        ZStack {
                            Theme.subHeaderColour
                        }
                    }
                    .frame(width: 5)
                    
                    ForEach(RecordTableColumn.allCases, id: \.self) { column in
                        if Headers.required.contains(column) {
                            Group {
                                ZStack(alignment: column.alignment) {
                                    Theme.subHeaderColour
                                    Text(column.name).padding(10)
                                }
                            }
                            .frame(width: column.width)
                        }
                    }
                }
            }
            .frame(height: 40)
        }
    }
    
    /// Plaintext conversion of the standard display
    struct Plain: View {
        public var records: [LogRecord]

        @State private var plain: String = ""
        @State private var grouped: [FancyStaticTextField] = []
        
        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 1) {
                    if records.count > 0 {
                        FancyTextField(placeholder: "Records...", lineLimit: 10, text: $plain)
                    } else {
                        LogRowEmpty(message: "No records found for date \(nav.session.date.formatted(date: .abbreviated, time: .omitted))", index: 0, colour: Theme.rowColour)
                    }
                }
            }
            .onAppear(perform: actionOnAppear)
        }
    }
    
    /// Standard display, colour coded list of records
    struct Full: View {
        public var records: [LogRecord]

        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 1) {
                    if records.count > 0 {
                        ForEach(records) { record in
                            if record.job != nil {
                                let entry = Entry(
                                    timestamp: DateHelper.longDate(record.timestamp!),
                                    job: record.job!,
                                    message: record.message!
                                )
                                
                                LogRow(
                                    entry: entry,
                                    index: records.firstIndex(of: record),
                                    colour: Color.fromStored((record.job?.colour) ?? Theme.rowColourAsDouble),
                                    record: record,
                                    viewRequiresColumns: Headers.required
                                )
                            }
                        }
                    } else {
                        LogRowEmpty(message: "No records found for \(nav.session.date.formatted(date: .abbreviated, time: .omitted))", index: 0, colour: Theme.rowColour)
                    }
                }
            }
        }
    }
    
    public struct TabContent {
        /// A list of rows in reverse-chronologic order for a given day
        public struct Chronologic: View {
            public var date: Date? = Date()
            
            @State private var searchText: String = ""
//            @State private var loading: Bool = false
            @State private var records: [LogRecord] = []
            
            @Environment(\.managedObjectContext) var moc
            @EnvironmentObject public var nav: Navigation
            
            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    // @TODO: implement loading view
//                    if loading {
//                        FancyLoader()
//                    } else {
                        Content
//                    }
                }
                .onAppear(perform: findRecords)
                .onChange(of: nav.session.date) { newDate in self.findRecords(for: newDate)}
                .onChange(of: nav.saved) { status in
                    if status {
                        self.findRecords(for: nav.session.date)
                    }
                }
            }
            
            var Content: some View {
                VStack(spacing: 1) {
                    Group {
                        ToolbarButtons()
                    }
                    .background(Theme.headerColour)
                    
                    // TODO: fix search
                    //                if nav.session.toolbar.showSearch {
                    //                    SearchBar(text: $searchText, disabled: (records.count == 0))
                    //                }
                    
                    if nav.session.toolbar.mode == .plain {
                        Plain(records: records)
                    } else {
                        Headers()
                        Full(records: records)
                    }
                }
            }
        }
        
        /// A list of rows that are grouped by Job
        public struct Grouped: View {
//            public var date: Date = Date()
            // @TODO: needed?
            //        @State private var searchText: String = ""
            @State private var grouped: [FancyStaticTextField] = []
            @State private var records: [LogRecord] = []
            
            @Environment(\.managedObjectContext) var moc
            @EnvironmentObject public var nav: Navigation
            
            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 1) {
                        Group {
                            ToolbarButtons()
                        }
                        .background(Theme.headerColour)

                        if records.count > 0 {
                            ForEach(grouped) {group in group}
                        } else {
                            LogRowEmpty(message: "No records found for date \(nav.session.date.formatted(date: .abbreviated, time: .omitted))", index: 0, colour: Theme.rowColour)
                        }
                        Spacer()
                    }
                }
                .onAppear(perform: findRecords)
                .onChange(of: nav.session.date) { newDate in self.findRecords(for: newDate)}
            }
        }
        
        /// A list of rows summarized by AI
        // TODO: do some kind of ML/AI summarization here. Initially it will just ignore records that are likely too short to be useful
        // TODO: i.e. ignore records whose ML tokens are LUNCH|MEETING|HEALTH (and similar)
        public struct Summarized: View {
            public var date: Date? = nil
            
            // @TODO: needed?
            @State private var searchText: String = ""
            @State private var records: [LogRecord] = []

            @Environment(\.managedObjectContext) var moc
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                VStack(spacing: 1) {
                    Group {
                        ToolbarButtons()
                    }
                    .background(Theme.headerColour)
                    
                    // TODO: fix search
                    //                if nav.session.toolbar.showSearch {
                    //                    SearchBar(text: $searchText, disabled: (records.count == 0))
                    //                }
                    
                    if nav.session.toolbar.mode == .plain {
                        Plain(records: records)
                    } else {
                        Headers()
                        Full(records: records)
                    }
                }
                .onAppear(perform: findRecords)
                .onChange(of: nav.session.date) { newDate in self.findRecords(for: newDate)}
            }
        }
        
        /// A list of events pulled from the user's connected calendar
        public struct Calendar: View {
            @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
            // @TODO: needed?
            //        @State private var searchText: String = ""
            
            var body: some View {
                CalendarToday().environmentObject(ce)
            }
        }
    }
}

// MARK: method definitions
extension Today.LogTable.TabContent.Chronologic {
    private func findRecords(for date: Date) -> Void {
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: moc).forDate(date)
        }, completion: { recordsForToday in
            self.records = recordsForToday!
        })
    }
    
    private func findRecords() -> Void {
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: moc).forDate(nav.session.date)
        }, completion: { recordsForToday in
            self.records = recordsForToday!
        })
    }
}

extension Today.LogTable.TabContent.Grouped {
    private func findRecords(for date: Date) -> Void {
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: moc).forDate(date)
        }, completion: { recordsForToday in
            self.records = recordsForToday!
            grouped = CoreDataRecords(moc: moc).createExportableGroupedRecordsAsViews(self.records)
        })
    }
    
    private func findRecords() -> Void {
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: moc).forDate(nav.session.date)
        }, completion: { recordsForToday in
            self.records = recordsForToday!
            grouped = CoreDataRecords(moc: moc).createExportableGroupedRecordsAsViews(self.records)
        })
    }
}

extension Today.LogTable.TabContent.Summarized {
    private func findRecords(for date: Date) -> Void {
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: moc).forDate(date)
        }, completion: { recordsForToday in
            self.records = recordsForToday!
        })
    }
    
    private func findRecords() -> Void {
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: moc).forDate(nav.session.date)
        }, completion: { recordsForToday in
            self.records = recordsForToday!
        })
    }
}

extension Today.LogTable.Plain {
    private func actionOnAppear() -> Void {
        let model = CoreDataRecords(moc: moc)

        plain = model.createExportableRecordsFrom(records, grouped: true)
        grouped = model.createExportableGroupedRecordsAsViews(records)
    }
}
