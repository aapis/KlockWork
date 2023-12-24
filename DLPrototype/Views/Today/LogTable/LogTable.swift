//
//  Theme.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogTable: View {
    public var date: Date? = nil

    @State private var job: String = ""
    @State private var records: [LogRecord] = []
    @State private var recordsAsString: String = ""
    @State private var wordCount: Int = 0
    @State private var isReversed: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var searchText: String = ""
    @State private var resetSearchButtonHit: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var viewMode: ViewMode = .full
    @State private var selectedTab: Tab = .chronologic
    @State private var viewRequiresColumns: Set<RecordTableColumn> = [.message]
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showTodaySearch") public var showSearch: Bool = true
    @AppStorage("today.recordGrouping") public var recordGrouping: Int = 0
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnExtendedTimestamp") public var showColumnExtendedTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            toolbar.font(Theme.font)

            HStack(spacing: 1) {
                if selectedTab != .calendar {
                    if viewMode == .full {
                        viewModeFull
                    } else if viewMode == .plain {
                        viewModePlain
                    }
                } else {
                    CalendarToday()
                        .id(updater.ids["today.calendarStrip"])
                        .environmentObject(ce)
                }
            }
        }
        .onChange(of: recordGrouping) { group in
            for tab in Tab.allCases {
                if group == tab.id {
                    selectedTab = tab
                }
            }
            
            if group != 2 {
                records = defaultGrouping()
            }

            updater.updateOne("ltd.rows")
            changeSort()
        }
        .onChange(of: selectedDate) { date in
            loadFor(date)
            nav.session.date = date
        }
        .onChange(of: searchText) { _ in
            if resetSearchButtonHit || searchText.count == 0 {
                loadRecordsBySelectedDate()
            } else {
                records = records.filter({
                    findMatches($0.message!)
                })
            }
        }
        .onAppear(perform: loadRecordsBySelectedDate)
    }
    
    // MARK: table view
    var viewModeFull: some View {
        VStack(spacing: 1) {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                headers.font(Theme.font)
                
                ScrollView(showsIndicators: false) {
                    rows.font(Theme.font)
                }
            }
        }
    }
    
    // MARK: plain view
    var viewModePlain: some View {
        VStack(spacing: 1) {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                headers.font(Theme.font)
                
                ScrollView(showsIndicators: false) {
                    plainRows.font(Theme.font)
                }
            }
        }
    }
    
    // MARK: toolbar view
    var toolbar: some View {
        GridRow {
            Group {
                HStack(spacing: 0) {
                    ZStack {
                        Color.clear
                    }
                    .frame(width: 6)
                    
                    ZStack(alignment: .leading) {
                        Theme.toolbarColour
                        
                        HStack {
//                            ToolbarTabs(selectedTab: $recordGrouping)
//                            ToolbarButtons(
//                                selectedTab: $recordGrouping,
//                                isShowingAlert: $isShowingAlert,
//                                showSearch: $showSearch,
//                                searchText: $searchText,
//                                selectedDate: $selectedDate,
//                                records: $records,
//                                viewMode: $viewMode
//                            )
//                                .id(updater.ids["today.dayList"])
                        }
                    }
                }
            }
        }.frame(height: 36)
    }
    
    // MARK: header view
    var headers: some View {
        GridRow {
            Group {
                ZStack {
                    Theme.headerColour
                }
            }
            .frame(width: 5)

            if viewRequiresColumns.contains(.index) {
                Group {
                    ZStack {
                        Theme.headerColour
                        Button(action: setIsReversed) {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(Color.white)
                        .onChange(of: isReversed) { _ in sort() }
                        .onHover { inside in
                            if inside {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .frame(width: 50)
            }

            if viewRequiresColumns.contains(.timestamp) || viewRequiresColumns.contains(.extendedTimestamp) {
                Group {
                    ZStack(alignment: .leading) {
                        Theme.headerColour
                        Text("Timestamp")
                            .padding(10)
                    }
                }
                .frame(width: 101)
            }

            if viewRequiresColumns.contains(.job) {
                Group {
                    ZStack(alignment: .center) {
                        Theme.headerColour
                        Text("Job ID")
                            .padding(10)
                    }
                }
                .frame(width: 80)
            }

            if viewRequiresColumns.contains(.message) {
                Group {
                    ZStack(alignment: .leading) {
                        Theme.headerColour
                        Text("Message")
                            .padding(10)
                    }
                }
            }
        }
        .frame(height: 40)
    }
    
    // MARK: rows view
    var rows: some View {
        VStack(spacing: 1) {
            if showSearch {
                SearchBar(text: $searchText, disabled: (records.count == 0))
            }
            
            if records.count > 0 {
                if selectedTab == .grouped {
                    // custom UI for grouped results
                    // TODO: shouldn't instantiate CDR here
//                    let groupedByJob = CoreDataRecords(moc: moc).createExportableGroupedRecordsAsViews(records)
//                    ForEach(groupedByJob) { group in group }
                } else {
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
                                viewRequiresColumns: viewRequiresColumns
                            )
                            .environmentObject(updater)
                        }
                    }.onAppear(perform: changeSort)
                }
            } else {
                LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
            }
        }
        .onChange(of: recordGrouping, perform: { _ in
            changeSort()
        })
        .onChange(of: showColumnIndex, perform: redrawTable)
        .onChange(of: showColumnJobId, perform: redrawTable)
        .onChange(of: showColumnTimestamp, perform: redrawTable)
        .onChange(of: showColumnExtendedTimestamp, perform: redrawTable)
    }
    
    var plainRows: some View {
        VStack(spacing: 1) {
            if showSearch {
                SearchBar(text: $searchText, disabled: (records.count == 0))
            }
            
            if records.count > 0 && recordsAsString.count > 0 {
                if selectedTab == .grouped {
                    // custom UI for grouped results
                    // TODO: shouldn't instantiate CDR here
//                    let groupedByJob = CoreDataRecords(moc: moc).createExportableGroupedRecordsAsViews(records)
//                    ForEach(groupedByJob) { group in group }
                } else {
                    // standard UI
                    FancyTextField(placeholder: "Records...", lineLimit: 10, text: $recordsAsString)
                }
            } else {
                LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
            }
        }
        .onChange(of: recordGrouping, perform: { _ in
            changeSort()
        })
    }
}

// MARK: function definitions

extension LogTable {
    // TODO: move this func to CoreDataRecords model
    private func changeSort() -> Void {
        if records.count > 0 {
            if selectedTab == .chronologic || selectedTab == .calendar{
                records = ungrouped()
            } else if selectedTab == .summarized {
                records = summarized()
            }
            
//            recordsAsString = CoreDataRecords(moc: moc).createExportableRecordsFrom(
//                records,
//                grouped: selectedTab == .grouped
//            )
        }
    }
    
    private func loadRecordsBySelectedDate() -> Void {
        selectedDate = nav.session.date
        
        recordGrouping = selectedTab.id
        
        loadFor(selectedDate)

        if showColumnIndex {viewRequiresColumns.insert(.index)}
        if showColumnJobId {viewRequiresColumns.insert(.job)}
        if showColumnTimestamp {viewRequiresColumns.insert(.timestamp)}
        if showColumnExtendedTimestamp {viewRequiresColumns.insert(.extendedTimestamp)}
    }
    
    private func loadFor(_ date: Date) -> Void {
        records = recordsNoFilter()
        
        changeSort()
    }
    
    private func findMatches(_ message: String) -> Bool {
        do {
            let caseInsensitiveTerm = try Regex("\(searchText)").ignoresCase()

            return message.contains(caseInsensitiveTerm)
        } catch {
            print("LogTable::search(term: String) - Unable to process string \(searchText)")
        }
        
        return false
    }
    
    private func recordsNoFilter() -> [LogRecord] {
        return LogRecords(moc: moc).forDate(selectedDate)
    }
    
    private func defaultGrouping() -> [LogRecord] {
        return recordsNoFilter().sorted(by: { $0.timestamp! > $1.timestamp! }).filter({
            findMatches($0.message!)
        })
    }

    private func ungrouped() -> [LogRecord] {
        return records.sorted(by: { $0.timestamp! > $1.timestamp! }).filter({
            findMatches($0.message!)
        })
    }

    // TODO: do some kind of ML/AI summarization here. Initially it will just ignore records that are likely too short to be useful
    // TODO: i.e. ignore records whose ML tokens are LUNCH|MEETING|HEALTH (and similar)
    private func summarized() -> [LogRecord] {
        return records.filter({
            $0.message!.count > 50 && findMatches($0.message!)
        })
    }
    
    private func setIsReversed() -> Void {
        isReversed.toggle()
    }

    private func sort() -> Void {
        withAnimation(.easeInOut) {
            records = records.reversed()
        }
    }

    private func redrawTable(_ changedValue: Bool) -> Void {
        updater.updateOne("today.table")
    }
}

struct LogTableRedux: View {
    public var date: Date? = nil
    private var buttons: [ToolbarButton] = []
    
    @EnvironmentObject public var nav: Navigation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FancyDivider()
            FancyGenericToolbar(buttons: buttons, standalone: true, location: .content)
        }
    }
    
    init(date: Date? = nil) {
        self.date = date

        Tab.allCases.forEach { tab in
            buttons.append(tab.button)
        }
    }
}

// MARK: structs
extension LogTableRedux {
    /// Table row headers
    struct Headers: View {
        static public let required: Set<RecordTableColumn> = [.job, .message]
        
        var body: some View {
            GridRow {
                // project colour block
                HStack(spacing: 0) {
                    Group {
                        ZStack {
                            Theme.headerColour
                        }
                    }
                    .frame(width: 5)
                    
                    ForEach(RecordTableColumn.allCases, id: \.self) { column in
                        if Headers.required.contains(column) {
                            Group {
                                ZStack(alignment: column.alignment) {
                                    Theme.headerColour
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

    /// A list of rows in reverse-chronologic order for a given day
    public struct Chronologic: View {
        public var date: Date? = nil
        
        @State private var searchText: String = ""

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        @FetchRequest private var records: FetchedResults<LogRecord>
        
        var body: some View {
            VStack(spacing: 1) {
                Grid(alignment: .top, horizontalSpacing: 0, verticalSpacing: 1) {
                    if nav.session.toolbar.showSearch {
                        SearchBar(text: $searchText, disabled: (records.count == 0))
                    }
                    
                    Headers()
                    if nav.session.toolbar.mode == .plain {
                        Plain(date: date, records: records)
                    } else if nav.session.toolbar.mode == .full {
                        Full(date: date, records: records)
                    }
                }
            }
        }
        
        init(date: Date? = nil) {
            var chosenDate = Date()
            if let date = date {
                chosenDate = date
            }

            _records = CoreDataRecords.fetchForDate(chosenDate)
        }
        
        /// Plaintext conversion of the standard display
        struct Plain: View {
            public var date: Date? = nil
            public var records: FetchedResults<LogRecord>
            
            @State private var recordsAsString: String = ""
            
            @Environment(\.managedObjectContext) var moc
            @EnvironmentObject public var nav: Navigation

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 1) {
                        if records.count > 0 {
                            if nav.session.toolbar.selected == .grouped {
                                FancyTextField(placeholder: "Records...", lineLimit: 10, text: $recordsAsString)
                            } else {
                                // TODO: shouldn't instantiate CDR here
                                let groupedByJob = CoreDataRecords(moc: moc).createExportableGroupedRecordsAsViews(records)
                                ForEach(groupedByJob) { group in group }
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
        
        /// Standard display, colour coded list of records
        struct Full: View {
            public var date: Date? = nil
            public var records: FetchedResults<LogRecord>
            
            @Environment(\.managedObjectContext) var moc
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
    }
    
    /// A list of rows that are grouped by Job
    public struct Grouped: View {
        public var date: Date? = nil
        
        // @TODO: needed?
        @State private var searchText: String = ""
        @State private var plain: String = ""
        @State private var grouped: [FancyStaticTextField] = []

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        @FetchRequest private var records: FetchedResults<LogRecord>

        var body: some View {
            VStack {
                if nav.session.toolbar.mode == .plain {
                    FancyTextField(placeholder: "Records...", lineLimit: 10, text: $plain)
                } else {
                    ForEach(grouped) { group in group }
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
    public struct Summarized: View {
        public var date: Date? = nil
        
        // @TODO: needed?
        @State private var searchText: String = ""

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        @FetchRequest private var records: FetchedResults<LogRecord>

        var body: some View {
            VStack {
                Headers()
                Text("Summarized")
                Spacer()
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
    
    /// A list of events pulled from the user's connected calendar
    public struct Calendar: View {
        public var date: Date? = nil
        
        // @TODO: needed?
        @State private var searchText: String = ""

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack {
                Headers()
                Text("Calendar")
                Spacer()
            }
        }
        
        init(date: Date? = nil) {
            self.date = date
        }
    }
}

// MARK: method definitions
extension LogTableRedux {}

extension LogTableRedux.Grouped {
    private func actionOnAppear() -> Void {
        let model = CoreDataRecords(moc: moc)
        
        grouped = model.createExportableGroupedRecordsAsViews(records)
        plain = model.createExportableRecordsFrom(records, grouped: true)
    }
}
