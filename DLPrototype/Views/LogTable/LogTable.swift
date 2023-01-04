//
//  LogTable.swift
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
        "11": LogTable.rowColour
    ]
    @State private var colours: [Color] = []
    @State private var isShowingAlert: Bool = false
    
    static public var rowColour: Color = Color.gray.opacity(0.2)
    static public var headerColour: Color = Color.blue
    static public var footerColour: Color = Color.gray.opacity(0.5)
    static public var toolbarColour: Color = headerColour.opacity(0.2)
    
    private let font: Font = .system(.body, design: .monospaced)
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    
    var body: some View {
        VStack(spacing: 1) {
            toolbar.font(font)
            
            HStack(spacing: 1) {
                table
                
                if showSidebar {
                    tableDetails.frame(width: 300)
                }
            }
            .onAppear(perform: {
                records.applyColourMap()
                records.updateWordCount()
            })
        }
    }
    
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
    
    var toolbar: some View {
        GridRow {
            Group {
                ZStack(alignment: .leading) {
                    LogTable.toolbarColour
                    
                    HStack {
                        Button(action: reload, label: {
                            Image(systemName: "arrow.counterclockwise")
                        })
                        .help("Reload data")
                        .keyboardShortcut("r")
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(action: {isShowingAlert = true; newDayAction() }, label: {
                            Image(systemName: "sunrise")
                        })
                        .help("New day")
                        .keyboardShortcut("n")
                        .buttonStyle(BorderlessButtonStyle())
    //                        .alert("It's a brand new day!", isPresented: $isPresented) {}
                        
                        Button(action: copyAll, label: {
                            Image(systemName: "doc.on.doc")
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        .keyboardShortcut("c")
                        .help("Copy all rows")
                        
                        Spacer()
                        Button(action: toggleSidebar, label: {
                            Image(systemName: "sidebar.right")
                        })
                        .help("Toggle sidebar")
                        .buttonStyle(BorderlessButtonStyle())
                    }.padding(8)
                }
            }
        }.frame(height: 35)
    }
    
    var headers: some View {
        GridRow {
            Group {
                ZStack {
                    LogTable.headerColour
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
                    LogTable.headerColour
                    Text("Timestamp")
                        .padding(10)
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.headerColour
                    Text("Job ID")
                        .padding(10)
                }
            }
                .frame(width: 100)
            Group {
//                HStack {
                    ZStack(alignment: .leading) {
                        LogTable.headerColour
                        Text("Message")
                            .padding(10)
                    }
                // TODO: commented out this button because there's a weird space and I don't want to fix it rn
//                    ZStack(alignment: .trailing) {
//                        LogTable.headerColour
//                        Button(action: {}, label: {
//                            Image(systemName: "sidebar.right")
//                        })
//                        .help("Open sidebar")
//                        .buttonStyle(BorderlessButtonStyle())
//                        .padding(10)
//                    }
//                }
            }
            
            // TODO: temp commented out until perf issues fixed
            if showExperimentalFeatures {
                if showExperimentActions {
                    Group {
                        ZStack(alignment: .leading) {
                            LogTable.headerColour
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
    
    var rows: some View {
        VStack(spacing: 1) {
            if records.entries.count > 0 {
                ForEach(records.entries) { entry in
                    LogRow(entry: entry, index: records.entries.firstIndex(of: entry), colour: entry.colour)
                }
            } else {
                LogRowEmpty(message: "No entries found for today", index: 0, colour: LogTable.rowColour)
            }
        }
    }
    
    var footer: some View {
        GridRow {
            Group {
                ZStack {
                    LogTable.footerColour
                    Text("\(records.entries.count)")
                        .padding(10)
                }
            }
                .frame(width: 50)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                    Text("Word count: \(wordCount)")
                        .padding(10)
                }
                .onAppear(perform: {wordCount = records.updateWordCount()})
            }

            if showExperimentalFeatures {
                if showExperimentActions {
                    Group {
                        ZStack(alignment: .leading) {
                            LogTable.footerColour
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
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "MST")
        df.locale = NSLocale.current
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())
        let data = records.rowsStartsWith(term: today).joined(separator: "\n")
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
}

struct LogTablePreview: PreviewProvider {
    static var previews: some View {
        LogTable(records: Records())
            .frame(height: 700)
    }
}
