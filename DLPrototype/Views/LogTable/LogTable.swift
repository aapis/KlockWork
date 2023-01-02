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
    public var entries: [Entry]
    public var id = UUID()
    
    @State private var wordCount: Int = 0
    @State private var isReversed: Bool = false
    @State private var colourMap: [String: Color] = [
        "11": LogTable.rowColour
    ]
    @State private var colours: [Color] = []
    
    static public var rowColour: Color = Color.gray.opacity(0.2)
    static public var headerColour: Color = Color.blue
    static public var footerColour: Color = Color.gray.opacity(0.5)
    
    private let font: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
            headers
                .font(font)
            
            ScrollView {
                rows
                    .font(font)
            }
            
            footer
                .font(font)
        }
    }
    
    var headers: some View {
        GridRow {
            Group {
                ZStack {
                    LogTable.headerColour
                    Button(action: sort) {
                        Image(systemName: "arrow.up.arrow.down")
                    }
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
                ZStack(alignment: .leading) {
                    LogTable.headerColour
                    Text("Message")
                        .padding(10)
                }
            }
            Group {
                ZStack(alignment: .leading) {
                    LogTable.headerColour
                    Text("Actions")
                        .padding(10)
                }
            }
                .frame(width: 100)
        }
        .frame(height: 40)
    }
    
    var rows: some View {
        VStack(spacing: 1) {
            if entries.count > 0 {
                ForEach(entries) { entry in
                    LogRow(entry: entry, index: entries.firstIndex(of: entry), colour: colourizeRow(entry))
                }
                .onAppear(perform: {
                    Task {
                        updateWordCount()
                        createRowColourMap()
                    }
                })
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
                    Text("\(entries.count)")
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
            }
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                }
            }
                .frame(width: 100)
        }
        .frame(height: 40)
    }
    
    private func updateWordCount() -> Void {
        var words: [String] = []
        
        for entry in entries {
            words.append(entry.message)
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))

        wordCount = wordSet.count
    }
    
    private func sort() -> Void {
        isReversed.toggle()
    }
    
    private func createRowColourMap() -> Void {
        let ids = getAllJobIds()
        
        // generate twice as many colours as required as there is some weirdness sometimes
        for _ in 0...(ids.count*2) {
            colours.append(Color.random())
        }
        
        for jid in ids {
            let colour = colours.randomElement()
            
            if colourMap.contains(where: {$0.value == colour}) {
                colourMap.updateValue(colours.randomElement() ?? LogTable.rowColour, forKey: jid)
            } else {
                colourMap.updateValue(colour ?? LogTable.rowColour, forKey: jid)
            }
        }
    }
    
    private func colourizeRow(_ current: Entry) -> Color {
        return colourMap[current.job] ?? LogTable.rowColour
    }
    
    private func getAllJobIds() -> Set<String> {
        var jobIds: [String] = []
        
        for entry in entries {
            if entry.job != "11" {
                jobIds.append(entry.job)
            }
        }
        
        return Set(jobIds)
    }
}

struct LogTablePreview: PreviewProvider {
    static var previews: some View {
        let entries: [Entry] = [
            Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "23164", message: "Hello, world"),
            Entry(timestamp: "2023-01-01 19:48", job: "11", message: "Hello, world")
        ]
        
        LogTable(entries: entries)
            .frame(height: 700)
    }
}
