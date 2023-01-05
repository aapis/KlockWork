//
//  LogRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogRow: View, Identifiable {
    public var entry: Entry
    public var index: Array<Entry>.Index?
    public var colour: Color
    public var id = UUID()
    
    @State public var isEditing: Bool = false
    @State public var isDeleting: Bool = false
    @State public var message: String = ""
    @State public var job: String = ""
    @State public var timestamp: String = ""
    @State public var aIndex: String = "0"
    @State public var activeColour: Color = Theme.rowColour
    
    @AppStorage("tigerStriped") private var tigerStriped = false
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    
    var body: some View {
        HStack(spacing: 1) {
            GridRow {
                Column(
                    colour: applyColour(),
                    textColour: rowTextColour(),
                    text: $aIndex
                ).frame(maxWidth: 50)
                
                EditableColumn(
                    type: "timestamp",
                    entry: entry,
                    colour: applyColour(),
                    textColour: rowTextColour(),
                    index: index,
                    isEditing: $isEditing,
                    isDeleting: $isDeleting,
                    text: $timestamp
                )
                .frame(maxWidth: 101)
                .contextMenu {
                    Button(action: {copy(entry.timestamp)}, label: {
                        Text("Copy \"\(entry.timestamp)\"")
                    })
                }
                
                
                EditableColumn(
                    type: "job",
                    entry: entry,
                    colour: applyColour(),
                    textColour: rowTextColour(),
                    index: index,
                    isEditing: $isEditing,
                    isDeleting: $isDeleting,
                    text: $job
                )
                .frame(maxWidth: 100)
                .contextMenu {
                    Button(action: {copy(entry.job)}, label: {
                        Text("Copy \"\(entry.job)\"")
                    })
                }
                
                EditableColumn(
                    type: "message",
                    entry: entry,
                    colour: applyColour(),
                    textColour: rowTextColour(),
                    index: index,
                    isEditing: $isEditing,
                    isDeleting: $isDeleting,
                    text: $message
                )
                .contextMenu {
                    Button(action: {copy(entry.message)}, label: {
                        Text("Copy \"\(entry.message)\"")
                    })
                }
                
                if showExperimentalFeatures {
                    if showExperimentActions {
                        Group {
                            ZStack {
                                applyColour()
                                
                                LogRowActions(
                                    entry: entry,
                                    colour: rowTextColour(),
                                    index: index,
                                    isEditing: $isEditing,
                                    isDeleting: $isDeleting
                                )
                            }
                        }
                        .frame(maxWidth: 100)
                    }
                }
            }
        }
        .defaultAppStorage(.standard)
        .onAppear(perform: setEditableValues)
//        .onHover(perform: onHover)
    }

    private func setEditableValues() -> Void {
        message = entry.message
        job = entry.job
        timestamp = entry.timestamp
        aIndex = adjustedIndexAsString()
    }
    
    // this can be forced to work but it causes perf and state modification problems
    // TODO: maybe show actions on hover?
//    private func onHover(hovering: Bool) -> Void {
//        let oldColour = colour
//
//        if hovering {
//            activeColour = Color.white.opacity(0.1)
//        } else {
//            activeColour = oldColour
//        }
//    }
    
    private func applyColour() -> Color {
        if isEditing {
            return Color.orange
        }

        if isDeleting {
            return Color.red
        }

        if tigerStriped {
            return colour.opacity(index!.isMultiple(of: 2) ? 1 : 0.5)
        }

        return colour
    }
    
    private func rowTextColour() -> Color {
        return colour.isBright() ? Color.black : Color.white
    }
    
    private func adjustedIndex() -> Int {
        var adjusted: Int = Int(index!)
        adjusted += 1

        return adjusted
    }
    
    private func adjustedIndexAsString() -> String {
        let adjusted = adjustedIndex()
        
        return String(adjusted)
    }
    
    private func copy(_ textToCopy: String) -> Void {
        let pasteBoard = NSPasteboard.general
        let data = textToCopy
        
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
}

struct LogTableRowPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            LogRow(entry: Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world"), index: 0, colour: Theme.rowColour)
            LogRow(entry: Entry(timestamp: "2023-01-01 19:49", job: "11", message: "Hello, world"), index: 1, colour: Theme.rowColour)
        }
    }
}
