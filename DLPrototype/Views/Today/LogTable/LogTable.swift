//
//  Theme.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogTable: View, Identifiable {
    public var id = UUID()
    @Binding public var job: String
    public var defaultSelectedDate: Date?
    
    @State private var records: [LogRecord] = []
    @State private var recordsAsString: String = ""
    @State private var wordCount: Int = 0
    @State private var isReversed: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var searchText: String = ""
    @State private var resetSearchButtonHit: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var viewMode: ViewMode = .full
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    @AppStorage("showSidebar") public var showSidebar: Bool = true
    @AppStorage("showTodaySearch") public var showSearch: Bool = true
    @AppStorage("today.recordGrouping") public var recordGrouping: Int = 0
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    // MARK: body view
    var body: some View {
        VStack(spacing: 1) {
            toolbar.font(Theme.font)
            
            HStack(spacing: 1) {
                if viewMode == .full {
                    viewModeFull
                } else if viewMode == .plain {
                    viewModePlain
                }
                
                if showSidebar {
                    tableDetails.frame(minWidth: 300, maxWidth: 400)
                }
            }
        }
        .onChange(of: selectedDate) { date in
            loadFor(date)
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
                
                ScrollView {
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
                
                ScrollView {
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
                            ToolbarTabs(selectedTab: $recordGrouping)
                            ToolbarButtons(
                                selectedTab: $recordGrouping,
                                isShowingAlert: $isShowingAlert,
                                showSidebar: $showSidebar,
                                showSearch: $showSearch,
                                searchText: $searchText,
                                selectedDate: $selectedDate,
                                records: $records,
                                viewMode: $viewMode
                            )
                                .id(updater.ids["today.dayList"])
                        }
                    }
                }
            }
        }.frame(height: 35)
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
            Group {
                ZStack {
                    Theme.headerColour
                    Button(action: setIsReversed) {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(Color.white)
                    .onChange(of: isReversed) { _ in sort() }
                }
            }
                .frame(width: 50)
            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Timestamp")
                        .padding(10)
                }
            }
                .frame(width: 101)
            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Job ID")
                        .padding(10)
                }
            }
                .frame(width: 120)
            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Message")
                        .padding(10)
                }
            }
            
            if showExperimentalFeatures {
                if showExperimentActions {
                    Group {
                        ZStack(alignment: .leading) {
                            Theme.headerColour
                            Text("Actions")
                                .padding(10)
                        }
                    }
                    .frame(width: 100)
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
                            selectedJob: $job
                        )
                    }
                }.onAppear(perform: changeSort)
            } else {
                LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
            }
        }
        .onChange(of: recordGrouping, perform: { _ in
            changeSort()
        })
    }
    
    var plainRows: some View {
        VStack(spacing: 1) {
            if showSearch {
                SearchBar(text: $searchText, disabled: (records.count == 0))
            }
            
            if records.count > 0 && recordsAsString.count > 0 {
                FancyTextField(placeholder: "Records...", lineLimit: 10, text: $recordsAsString)
            } else {
                LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
            }
        }
        .onChange(of: recordGrouping, perform: { _ in
            changeSort()
        })
    }
    
    var tableDetails: some View {
        LogTableDetails(records: $records, selectedDate: $selectedDate, open: $showSidebar)
            .environmentObject(updater)
    }
    
    // TODO: move this func to CoreDataRecords model
    private func changeSort() -> Void {
        if recordGrouping == 0 {
            records = ungrouped()
        } else if recordGrouping == 1 {
            records = grouped()
        }
        
        createPlaintextRecords()
    }
    
    private func loadRecordsBySelectedDate() -> Void {
        if defaultSelectedDate != nil {
            selectedDate = defaultSelectedDate!
        }
        
        loadFor(selectedDate)
    }
    
    private func loadFor(_ date: Date) -> Void {
        records = LogRecords(moc: moc).forDate(selectedDate)
        
        createPlaintextRecords()
        changeSort()
    }
    
    // TODO: move this func to CoreDataRecords model
    private func createPlaintextRecords() -> Void {
        if records.count > 0 {
            recordsAsString = ""
            
            for item in records {
                if item.job != nil {
                    let ignoredJobs = item.job!.project?.configuration?.ignoredJobs
                    let cleaned = CoreDataProjectConfiguration.applyBannedWordsTo(item)
                    
                    if ignoredJobs != nil {
                        if !ignoredJobs!.contains(item.job!.jid.string) {
                            let url = item.job!.uri
                            
                            if url != nil {
                                recordsAsString += "\(item.timestamp!) - \(item.job!.uri!.absoluteString) - \(cleaned.message!)\n"
                            } else {
                                recordsAsString += "\(item.timestamp!) - \(item.job!.jid.string) - \(cleaned.message!)\n"
                            }
                        }
                    }
                }
            }
        }
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
    
    private func grouped() -> [LogRecord] {
        return records.sorted(by: { $0.job!.jid > $1.job!.jid }).filter({
            findMatches($0.message!)
        })
    }
    
    private func ungrouped() -> [LogRecord] {
        return records.sorted(by: { $0.timestamp! > $1.timestamp! }).filter({
            findMatches($0.message!)
        })
    }
    
    private func setIsReversed() -> Void {
        isReversed.toggle()
    }

    private func sort() -> Void {
//        withAnimation(.easeInOut) {
            // just always reverse the records
            // TODO: fix this
//            records.reversed()
//        }
    }
}

struct LogTablePreview: PreviewProvider {
    @State static public var sj: String = "11.0"
    @State static public var d: Date = Date()
    
    static var previews: some View {
        LogTable(job: $sj, defaultSelectedDate: d)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 700)
    }
}
