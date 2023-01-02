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
//    @State private var lines: [Entry] = []
    
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
                    LogRow(entry: entry, index: entries.firstIndex(of: entry), colour: LogTable.rowColour)
                }
                    .onAppear(perform: updateWordCount)
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
