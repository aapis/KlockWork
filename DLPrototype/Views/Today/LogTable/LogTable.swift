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
    
    @State private var records: [LogRecord] = []
    @State private var wordCount: Int = 0
    @State private var showSidebar: Bool = true
    @State private var isReversed: Bool = false
    @State public var colourMap: [String: Color] = [
        "11": Theme.rowColour
    ]
    @State private var colours: [Color] = []
    @State private var isShowingAlert: Bool = false
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var fetched: [Entry] = []
    @State private var refreshing: Bool = false
    @State private var resetSearchButtonHit: Bool = false
    
    @State private var selectedDate: Date = Date()
    
    private let font: Font = .system(.body, design: .monospaced)
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    
    @Environment(\.managedObjectContext) var moc
    
    // MARK: body view
    var body: some View {
        VStack(spacing: 1) {
            toolbar.font(font)
            
            HStack(spacing: 1) {
                table
                
                if showSidebar {
                    tableDetails.frame(maxWidth: 300)
                }
            }
        }
        .onChange(of: selectedDate) { _ in
            loadRecordsBySelectedDate()
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
    var table: some View {
        VStack(spacing: 1) {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                headers.font(font)
                
                ScrollView {
                    rows.font(font)
                }
            }
        }
    }
    
    // MARK: toolbar view
    var toolbar: some View {
        GridRow {
            Group {
                ZStack(alignment: .leading) {
                    Theme.toolbarColour
                    
                    HStack {
                        ToolbarTabs(selectedTab: $selectedTab)
                        ToolbarButtons(
                            selectedTab: $selectedTab,
                            isShowingAlert: $isShowingAlert,
                            showSidebar: $showSidebar,
                            searchText: $searchText,
                            selectedDate: $selectedDate,
                            records: $records
                        )
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
                .frame(width: 100)
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
            SearchBar(text: $searchText, disabled: (records.count == 0))
            
            if records.count > 0 {
                ForEach(records) { record in
                    let entry = Entry(
                        timestamp: LogRecords.timestampToString(record.timestamp!),
                        job: String(record.job?.jid ?? 0),
                        message: record.message!
                    )
                    
                    LogRow(
                        entry: entry,
                        index: records.firstIndex(of: record),
                        colour: Color.fromStored((record.job?.colour) ?? Theme.rowColourAsDouble)
                    )
                }.onAppear(perform: changeSort)
            } else {
                LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
            }
        }
        .onChange(of: selectedTab, perform: { _ in
            changeSort()
        })
    }
    
    var tableDetails: some View {
        LogTableDetails(colours: colourMap, records: $records)
    }
    
    private func changeSort() -> Void {
        if selectedTab == 0 {
            records = ungrouped()
        } else if selectedTab == 1 {
            records = grouped()
        }
    }
    
    private func loadRecordsBySelectedDate() -> Void {
        records = LogRecords(moc: moc).forDate(selectedDate)
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

//struct LogTablePreview: PreviewProvider {
//    static var previews: some View {
//        LogTable(records: Records(), today: )
//            .frame(height: 700)
//    }
//}
