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
    
//    @ObservedObject public var records: Records
    public var today: FetchedResults<LogRecord>
    
    @State private var wordCount: Int = 0
    @State private var showSidebar: Bool = true // TODO: TMP
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
    
    @Binding public var ltd: UUID
    
    private let font: Font = .system(.body, design: .monospaced)
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    
    @Environment(\.managedObjectContext) var moc
    
    public var didSave = NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
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
//            .onAppear(perform: {
//                records.applyColourMap()
//                let _ = records.updateWordCount()
//            })
        }
//        .onAppear(perform: update)
//        .onChange(of: today, perform: update)
//        .onReceive(didSave) { _ in
//            refreshing.toggle()
//        }
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
                            searchText: $searchText
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
            
            // TODO: temp commented out until perf issues fixed
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
            if selectedTab == 0 { // all tab
                if today.count > 0 {
                    ForEach(today, id: \LogRecord.id) { record in
                        let entry = Entry(
                            timestamp: LogRecords.timestampToString(record.timestamp!),
                            job: String(record.job?.jid ?? 0),
                            message: record.message!
                        )
                        
                        LogRow(
                            entry: entry,
                            index: today.firstIndex(of: record),
                            colour: Color.fromStored((record.job?.colour) ?? Theme.rowColourAsDouble)
                        )
                    }
                } else {
                    LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
                }
            } else if selectedTab == 1 { // grouped tab
                if today.count > 0 {
                    let groupedResults = grouped()
                    
                    ForEach(groupedResults) { entry in
                        LogRow(
                            entry: entry,
                            index: groupedResults.firstIndex(of: entry),
                            colour: entry.colour
                        )
                    }
                } else {
                    LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
                }
            } else if selectedTab == 2 { // search tab
                if today.count > 0 {
                    SearchBar(text: $searchText)
                    let searchResults = search()
                    
                    ForEach(searchResults) { entry in
                        LogRow(entry: entry, index: searchResults.firstIndex(of: entry), colour: entry.colour)
                    }
                } else {
                    LogRowEmpty(message: "No records found for today", index: 0, colour: Theme.rowColour)
                }
            }
        }
    }
    
    var tableDetails: some View {
        LogTableDetails(colours: colourMap, today: today)
            .id(ltd)
    }
    
    private func update() -> Void {
//        for record in today {
//            print("COLOUR: \(record.jobRel?.colour)")
//        }
//        fetched = LogRecords.todayFromFetched(results: today)
//        print("FILTER: [logTable] \(fetched)")
    }
    
    private func search() -> [Entry] {
        var filtered: [Entry] = []
        let term = searchText
        
        for record in today {
            let entry = Entry(
                timestamp: LogRecords.timestampToString(record.timestamp!),
                job: String(record.job?.jid ?? 0),
                message: record.message!,
                colour: Color.fromStored(record.job?.colour ?? Theme.rowColourAsDouble)
            )
            
            do {
                let caseInsensitiveTerm = try Regex("\(term)").ignoresCase()

                if entry.message.contains(caseInsensitiveTerm) {
                    filtered.append(entry)
                }
            } catch {
                print("LogTable::search(term: String) - Unable to process string \(term)")
            }
        }

        return filtered
    }
    
    private func grouped() -> [Entry] {
        var grouped: [Entry] = []
        
        for record in today {
            let entry = Entry(
                timestamp: LogRecords.timestampToString(record.timestamp!),
                job: String(record.job?.jid ?? 0),
                message: record.message!,
                colour: Color.fromStored(record.job?.colour ?? Theme.rowColourAsDouble)
            )
            
            grouped.append(entry)
        }

        return grouped.sorted(by: { $0.job > $1.job })
    }
    
    private func setIsReversed() -> Void {
        isReversed.toggle()
    }

    private func sort() -> Void {
        withAnimation(.easeInOut) {
            // just always reverse the records
//            today.reversed()
        }
    }
}

//struct LogTablePreview: PreviewProvider {
//    static var previews: some View {
//        LogTable(records: Records(), today: )
//            .frame(height: 700)
//    }
//}
