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
    
    @ObservedObject public var records: Records
    
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
    
    private let font: Font = .system(.body, design: .monospaced)
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    
    var body: some View {
        VStack(spacing: 1) {
            toolbar.font(font)
            
            HStack(spacing: 1) {
                table
                
                if showSidebar {
                    tableDetails.frame(maxWidth: 300)
                }
            }
            .onAppear(perform: {
                records.applyColourMap()
                let _ = records.updateWordCount()
            })
        }
    }
    
    // MARK: table view
    var table: some View {
        VStack(spacing: 1) {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                headers.font(font)
                
                ScrollView {
                    rows.font(font)
                }
                
//                footer.font(font)
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
                        HStack(spacing: 1) {
                            // TODO: convert these button/styles to custom button views and styles
                            Button(action: {setActive(0)}, label: {
                                ZStack {
                                    (selectedTab == 0 ? Theme.tabActiveColour : Theme.tabColour)
                                    Image(systemName: "tray.2.fill")
                                }
                            })
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                            .help("View all of today's records")
                            .frame(width: 50)
                            
                            Button(action: {setActive(1)}, label: {
                                ZStack {
                                    (selectedTab == 1 ? Theme.tabActiveColour : Theme.tabColour)
                                    Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")
                                }
                            })
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                            .help("Today's records grouped by JOB ID")
                            .frame(width: 50)
                            
                            Button(action: {setActive(2)}, label: {
                                ZStack {
                                    (selectedTab == 2 ? Theme.tabActiveColour : Theme.tabColour)
                                    Image(systemName: "magnifyingglass")
                                }
                            })
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                            .help("Search today's records")
                            .frame(width: 50)
                        }
                        
                        HStack {
                            Button(action: reload, label: {
                                Image(systemName: "arrow.counterclockwise")
                            })
                            .help("Reload data")
                            .keyboardShortcut("r")
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                            
                            Button(action: {isShowingAlert = true; newDayAction() }, label: {
                                Image(systemName: "sunrise")
                            })
                            .help("New day")
                            .keyboardShortcut("n")
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                            //                        .alert("It's a brand new day!", isPresented: $isPresented) {}
                            
                            Button(action: copyAll, label: {
                                Image(systemName: "doc.on.doc")
                            })
                            .buttonStyle(.borderless)
                            .keyboardShortcut("c")
                            .help("Copy all rows")
                            .foregroundColor(Color.white)
                            
                            Spacer()
                            Button(action: toggleSidebar, label: {
                                Image(systemName: "sidebar.right")
                            })
                            .help("Toggle sidebar")
                            .buttonStyle(.borderless)
                            .foregroundColor(Color.white)
                        }.padding(8)
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
                if records.entries.count > 0 {
                    ForEach(records.entries) { entry in
                        LogRow(entry: entry, index: records.entries.firstIndex(of: entry), colour: entry.colour)
                    }
                } else {
                    LogRowEmpty(message: "No entries found for today", index: 0, colour: Theme.rowColour)
                }
            } else if selectedTab == 1 { // grouped tab
                if records.entries.count > 0 {
                    ForEach(records.sortByJob()) { entry in
                        LogRow(entry: entry, index: records.entries.firstIndex(of: entry), colour: entry.colour)
                    }
                } else {
                    LogRowEmpty(message: "No entries found for today", index: 0, colour: Theme.rowColour)
                }
            } else if selectedTab == 2 { // search tab
                if records.entries.count > 0 {
                    SearchBar(text: $searchText)
                    
                    ForEach(records.search(term: searchText)) { entry in
                        LogRow(entry: entry, index: records.entries.firstIndex(of: entry), colour: entry.colour)
                    }                    
                } else {
                    LogRowEmpty(message: "No entries found for today", index: 0, colour: Theme.rowColour)
                }
            }
        }
    }
    
    // MARK: footer view
    var footer: some View {
        GridRow {
            Group {
                ZStack {
                    Theme.footerColour
                    Text("\(records.entries.count)")
                        .padding(10)
                }
            }
                .frame(width: 50)
            Group {
                ZStack(alignment: .leading) {
                    Theme.footerColour
                }
            }
                .frame(width: 101)
            Group {
                ZStack(alignment: .leading) {
                    Theme.footerColour
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    Theme.footerColour
                    Text("Word count: \(wordCount)")
                        .padding(10)
                }
                .onAppear(perform: {wordCount = records.updateWordCount()})
            }

            if showExperimentalFeatures {
                if showExperimentActions {
                    Group {
                        ZStack(alignment: .leading) {
                            Theme.footerColour
                        }
                    }
                    .frame(width: 100)
                }
            }
        }
        .frame(height: 40)
    }
    
    var tableDetails: some View {
        LogTableDetails(records: records, colours: colourMap)
    }
    
    private func setActive(_ index: Int) -> Void {
        selectedTab = index
    }
    
    private func setIsReversed() -> Void {
        isReversed.toggle()
    }
    
    private func sort() -> Void {
        withAnimation(.easeInOut) {
            // just always reverse the records
            records.entries.reverse()
        }
    }
    
    private func toggleSidebar() -> Void {
        withAnimation(.easeInOut) {
            showSidebar.toggle()
        }
    }
    
    private func reload() -> Void {
        records.reload()
    }
    
    private func newDayAction() -> Void {
        records.clear()
        records.logNewDay()
    }
    
    private func copyAll() -> Void {
        let pasteBoard = NSPasteboard.general
        var source: [Entry] = []
        
        if selectedTab == 0 {
            source = records.entries
        } else if selectedTab == 1 {
            source = records.sortByJob()
        } else if selectedTab == 2 {
            source = records.search(term: searchText)
        }
        
        let data = toStringList(source)
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
    
    private func toStringList(_ items: [Entry]) -> String {
        var out = ""
        
        for item in items {
            out += item.toString() + "\n"
        }
        
        return out
    }
}

struct LogTablePreview: PreviewProvider {
    static var previews: some View {
        LogTable(records: Records())
            .frame(height: 700)
    }
}
