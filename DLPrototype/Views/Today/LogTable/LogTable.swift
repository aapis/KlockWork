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
    struct LogTableRedux: View {
        public var date: Date? = nil
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
        
        init(date: Date? = nil) {
            self.date = date
            
            TodayViewTab.allCases.forEach { tab in
                buttons.append(tab.button)
            }
        }
    }
}

// MARK: structs
extension Today.LogTableRedux {
    /// Table row headers
    struct Headers: View {
        static public let required: Set<RecordTableColumn> = [.job, .message]
        
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
                                    Text(column.name)
                                        .padding(10)
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
        public var date: Date? = nil
        public var records: FetchedResults<LogRecord>

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
                        if let date = date {
                            LogRowEmpty(message: "No records found for date \(date.formatted())", index: 0, colour: Theme.rowColour)
                        } else {
                            LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
                        }
                    }
                }
            }
            .onAppear(perform: actionOnAppear)
        }
    }
    
    /// Standard display, colour coded list of records
    struct Full: View {
        public var date: Date? = nil
        public var records: FetchedResults<LogRecord>

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
                        if let date = date {
                            LogRowEmpty(message: "No records found for date \(date.formatted())", index: 0, colour: Theme.rowColour)
                        } else {
                            LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
                        }
                    }
                }
            }
        }
    }
    
    public struct TabContent {
        /// A list of rows in reverse-chronologic order for a given day
        public struct Chronologic: View {
            public var date: Date? = nil
            
            @State private var searchText: String = ""
//            @State private var loading: Bool = false
            
            @Environment(\.managedObjectContext) var moc
            @EnvironmentObject public var nav: Navigation
            
            @FetchRequest private var records: FetchedResults<LogRecord>
            
            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    // @TODO: implement loading view
//                    if loading {
//                        FancyLoader()
//                    } else {
                        Content
//                    }
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
                        Plain(date: date, records: records)
                    } else {
                        Headers()
                        Full(date: date, records: records)
                    }
                }
            }
            
            init(date: Date? = nil) {
                self.date = date
                var chosenDate = Date()
                if let date = date {
                    chosenDate = date
                }

                _records = CoreDataRecords.fetchForDate(chosenDate)
            }
        }
        
        /// A list of rows that are grouped by Job
        public struct Grouped: View {
            public var date: Date? = nil
            
            // @TODO: needed?
            //        @State private var searchText: String = ""
            @State private var grouped: [FancyStaticTextField] = []
            
            @Environment(\.managedObjectContext) var moc
            @EnvironmentObject public var nav: Navigation
            
            @FetchRequest private var records: FetchedResults<LogRecord>
            
            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 1) {
                        Group {
                            ToolbarButtons()
                        }
                        .background(Theme.headerColour)
                        
                        Headers()
                        if records.count > 0 {
                            ForEach(grouped) {group in group}
                        } else {
                            if let date = date {
                                LogRowEmpty(message: "No records found for date \(date.formatted())", index: 0, colour: Theme.rowColour)
                            } else {
                                LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
                            }
                        }
                        Spacer()
                    }
                }
                .onAppear(perform: actionOnAppear)
            }
            
            init(date: Date? = nil) {
                self.date = date
                
                var chosenDate = Date()
                if let date = date {
                    chosenDate = date
                }
                
                _records = CoreDataRecords.fetchForDate(chosenDate)
            }
        }
        
        /// A list of rows summarized by AI
        // TODO: do some kind of ML/AI summarization here. Initially it will just ignore records that are likely too short to be useful
        // TODO: i.e. ignore records whose ML tokens are LUNCH|MEETING|HEALTH (and similar)
        public struct Summarized: View {
            public var date: Date? = nil
            
            // @TODO: needed?
            @State private var searchText: String = ""
            
            @EnvironmentObject public var nav: Navigation
            
            @FetchRequest private var records: FetchedResults<LogRecord>
            
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
                        Plain(date: date, records: records)
                    } else {
                        Headers()
                        Full(date: date, records: records)
                    }
                }
            }
            
            init(date: Date? = nil) {
                self.date = date
                
                var chosenDate = Date()
                if let date = date {
                    chosenDate = date
                }
                
                // @TODO: this seems to either crash or otherwise break the app
                //            _records = CoreDataRecords.fetchSummarizedForDate(chosenDate)
                _records = CoreDataRecords.fetchForDate(chosenDate)
            }
        }
        
        /// A list of events pulled from the user's connected calendar
        public struct Calendar: View {
            // @TODO: needed?
            //        @State private var searchText: String = ""
            
            @EnvironmentObject public var ce: CoreDataCalendarEvent
            
            var body: some View {
                CalendarToday().environmentObject(ce)
            }
        }
    }
}

// MARK: method definitions
extension Today.LogTableRedux.TabContent.Chronologic {
    private func actionOnAppear() -> Void {
        if let date = date {
            nav.session.date = date
        }
        
        if let first = records.first {
            if let firstRecordJob = first.job {
                nav.session.setJob(firstRecordJob)
            }
        }
    }
}

extension Today.LogTableRedux.TabContent.Grouped {
    private func actionOnAppear() -> Void {
        grouped = CoreDataRecords(moc: moc).createExportableGroupedRecordsAsViews(records)
    }
}


extension Today.LogTableRedux.Plain {
    private func actionOnAppear() -> Void {
        let model = CoreDataRecords(moc: moc)

        plain = model.createExportableRecordsFrom(records, grouped: true)
        grouped = model.createExportableGroupedRecordsAsViews(records)
    }
}
