//
//  Theme.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

/// Table which displays all the records
extension Today {
    struct LogTable: View {
        @EnvironmentObject public var nav: Navigation
        private var buttons: [ToolbarButton] = []

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                FancyDivider()
                FancyGenericToolbar(
                    buttons: buttons,
                    standalone: true,
                    location: .content,
                    mode: .compact,
                    page: self.nav.session.appPage
                )
                .padding(.bottom)
            }
        }
        
        init() {
            // @TODO: hide summarized view until we figure out what to do with it
            TodayViewTab.allCases.filter{$0 != .summarized}.forEach { tab in
                buttons.append(tab.button)
            }
        }
    }
}

// MARK: structs
extension Today.LogTable {
    /// Table row headers
    struct Headers: View {
        @EnvironmentObject public var state: Navigation
        public var page: PageConfiguration.AppPage
        @State private var required: Set<RecordTableColumn> = [.message]
        @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
        @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
        @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true

        var body: some View {
            GridRow {
                HStack(spacing: 0) {
                    Group {
                        ZStack(alignment: .top) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.6)
                                .blendMode(.softLight)
                            self.page.primaryColour
                        }
                    }
                    .frame(width: 15)
                    
                    ForEach(RecordTableColumn.allCases, id: \.self) { column in
                        if self.required.contains(column) {
                            Group {
                                ZStack(alignment: column.alignment) {
                                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                        .opacity(0.6)
                                        .blendMode(.softLight)
                                    self.page.primaryColour
                                    Text(column.name)
                                        .padding(8)
                                }
                            }
                            .frame(width: column.width)
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.gray)
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.showColumnIndex) { self.actionOnAppear() }
            .onChange(of: self.showColumnTimestamp) { self.actionOnAppear() }
            .onChange(of: self.showColumnJobId) { self.actionOnAppear() }
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
            VStack(spacing: 1) {
                if records.count > 0 {
                    FancyTextField(placeholder: "Records...", lineLimit: 10, text: $plain)
                } else {
                    LogRowEmpty(message: "No records found for date \(self.nav.session.date.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .onAppear(perform: actionOnAppear)
        }
    }
    
    /// Standard display, colour coded list of records
    struct Full: View {
        @EnvironmentObject public var nav: Navigation
        @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
        @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
        @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
        public var records: [LogRecord]
        @State private var offset: Int = 0

        var body: some View {
            VStack(spacing: 0) {
                if records.count > 0 {
                    ForEach(self.records, id: \.objectID) { record in
                        if record.job != nil {
                            let entry = Entry(
                                timestamp: DateHelper.longDate(record.timestamp!),
                                job: record.job!,
                                message: record.message!
                            )

                            LogRow(
                                entry: entry,
                                index: records.firstIndex(of: record),
                                colour: record.job?.backgroundColor ?? Theme.rowColour,
                                record: record
                            )
                        }
                    }
                } else {
                    LogRowEmpty(message: "No records found for \(self.nav.session.date.formatted(date: .abbreviated, time: .omitted))")
                }
            }
        }
    }
    
    public struct TabContent {
        /// A list of rows in reverse-chronologic order for a given day
        public struct Chronologic: View {
            @EnvironmentObject public var nav: Navigation
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
            @AppStorage("today.viewMode") public var index: Int = 0
            @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
            public var date: Date? = Date()
            private let page: PageConfiguration.AppPage = .today
            @State private var searchText: String = ""
            @State private var records: [LogRecord] = []
            @State private var recordsOnCurrentPage: [LogRecord] = []
            @State private var id: UUID = UUID()

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        ToolbarButtons(records: self.recordsOnCurrentPage)
                        // @TODO: fix search
//                        if nav.session.toolbar.showSearch {
//                            UI.BoundSearchBar(text: $searchText, disabled: (records.count == 0))
//                        }

                        if nav.session.toolbar.mode == .plain {
                            Plain(records: self.recordsOnCurrentPage)
                        } else {
                            Headers(page: self.page)
                            Full(records: self.recordsOnCurrentPage)
                        }
                        UI.Pagination(entityCount: records.count)
                    }
                    .id(self.id)
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.recordsOnCurrentPage) { self.refreshView() }
                .onChange(of: self.nav.session.pagination.currentPageOffset) { self.findRecords() }
                .onChange(of: self.perPage) { self.actionOnAppear() }
                .onChange(of: self.nav.session.date) { self.actionOnAppear() }
                .onChange(of: self.tableSortOrder) { self.findRecords() }
                .onChange(of: nav.saved) {
                    if nav.saved {
                        self.findRecords()
                    }
                }
            }
        }
        
        /// A list of rows that are grouped by Job
        public struct Grouped: View {
            @EnvironmentObject public var nav: Navigation
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
            @AppStorage("today.viewMode") public var index: Int = 0
            private let page: PageConfiguration.AppPage = .today
            @State private var grouped: [FancyStaticTextField] = []
            @State private var records: [LogRecord] = []

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ToolbarButtons(records: self.records, tab: .grouped)
                            .background(self.page.primaryColour)
                        if records.count > 0 {
                            ForEach(grouped) {group in group}
                        } else {
                            LogRowEmpty(message: "No records found for date \(self.nav.session.date.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                    .background([.classic, .opaque].contains(self.nav.theme.style) ? self.nav.session.appPage.primaryColour : .clear)
                }
                .onAppear(perform: self.findRecords)
                .onChange(of: nav.session.date) { self.findRecords() }
            }
        }
        
        /// A list of rows summarized by AI
        // TODO: do some kind of ML/AI summarization here. Initially it will just ignore records that are likely too short to be useful
        // TODO: i.e. ignore records whose ML tokens are LUNCH|MEETING|HEALTH (and similar)
        public struct Summarized: View {
            @EnvironmentObject public var nav: Navigation
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
            @AppStorage("today.viewMode") public var index: Int = 0
            public var date: Date? = nil
            private let page: PageConfiguration.AppPage = .today
            // @TODO: needed?
            @State private var searchText: String = ""
            @State private var records: [LogRecord] = []

            var body: some View {
                VStack(spacing: 0) {
                    ToolbarButtons(records: self.records, tab: .summarized)
                    Divider().foregroundStyle(.white)
                    // TODO: fix search
                    //                if nav.session.toolbar.showSearch {
                    //                    UI.BoundSearchBar(text: $searchText, disabled: (records.count == 0))
                    //                }
                    
                    if nav.session.toolbar.mode == .plain {
                        Plain(records: records)
                    } else {
                        Headers(page: self.page)
                        Full(records: records)
                    }
                }
                .onAppear(perform: self.findRecords)
                .onChange(of: nav.session.date) { self.findRecords() }
            }
        }
        
        /// A list of events pulled from the user's connected calendar
        public struct Calendar: View {
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
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
extension Today.LogTable.Headers {
    private func actionOnAppear() -> Void {
        if self.showColumnIndex { self.required.insert(.index) } else { self.required.remove(.index)}
        if self.showColumnTimestamp { self.required.insert(.timestamp) } else { self.required.remove(.timestamp)}
        if self.showColumnJobId { self.required.insert(.job) } else { self.required.remove(.job)}
    }
}

extension Today.LogTable.TabContent.Chronologic {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.nav.session.pagination.currentPageOffset = 0
        self.findRecords()
    }

    /// Fires when the record window shifts
    /// - Returns: Void
    private func refreshView() -> Void {
        self.id = UUID()
    }

    /// Find today's records
    /// - Returns: Void
    private func findRecords() -> Void {
        self.nav.session.toolbar.mode = .full
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: self.nav.moc).forDate(self.nav.session.date, sort: NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: self.tableSortOrder == 1 ? true : false))
        }, completion: { recordsForToday in
            if let recordsForToday = recordsForToday {
                let lBound = self.nav.session.pagination.currentPageOffset
                let uBound = lBound + self.perPage

                if lBound < recordsForToday.count && uBound <= recordsForToday.count {
                    self.recordsOnCurrentPage = Array(recordsForToday[lBound..<uBound])
                } else {
                    self.recordsOnCurrentPage = recordsForToday
                }

                self.records = recordsForToday
            }
        })
    }
}

extension Today.LogTable.TabContent.Grouped {
    /// Find records and set the current view index to "plain text" as this view is plain text only
    /// - Returns: Void
    private func findRecords() -> Void {
        self.nav.session.toolbar.mode = .plain
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: self.nav.moc).forDate(nav.session.date, sort: NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: self.tableSortOrder == 1 ? true : false))
        }, completion: { recordsForToday in
            if let recordsForToday = recordsForToday {
                self.records = recordsForToday
                grouped = CoreDataRecords(moc: self.nav.moc).createExportableGroupedRecordsAsViews(self.records)
            }
        })
    }
}

extension Today.LogTable.TabContent.Summarized {
    private func findRecords() -> Void {
        self.nav.session.toolbar.mode = .full
        DispatchQueue.with(background: {
            return CoreDataRecords(moc: self.nav.moc).forDate(nav.session.date, sort: NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: self.tableSortOrder == 1 ? true : false))
        }, completion: { recordsForToday in
            if let recordsForToday = recordsForToday {
                self.records = recordsForToday
            }
        })
    }
}

extension Today.LogTable.Plain {
    private func actionOnAppear() -> Void {
        let model = CoreDataRecords(moc: self.nav.moc)

        plain = model.createExportableRecordsFrom(records, grouped: true)
        grouped = model.createExportableGroupedRecordsAsViews(records)
    }
}
