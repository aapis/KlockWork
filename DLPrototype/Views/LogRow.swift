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
    
    var body: some View {
        HStack(spacing: 1) {
            GridRow {
                Group {
                    ZStack {
                        tigerStripe()
                        Text("\(adjustedIndex())")
                            .padding(10)
                            
                    }
                }
                    .frame(maxWidth: 50)
                Group {
                    ZStack(alignment: .leading) {
                        tigerStripe()
                        Text(formatted(entry.timestamp))
                            .padding(10)
                    }
                }
                    .frame(maxWidth: 150)
                Group {
                    ZStack {
                        tigerStripe()
                        Text(entry.job)
                            .padding(10)
                    }
                }
                    .frame(maxWidth: 100)
                Group {
                    ZStack(alignment: .leading) {
                        tigerStripe()
                        Text(entry.message)
                            .padding(10)
                    }
                }
                Group {
                    ZStack {
                        tigerStripe()
                        // TODO: commented out until I can fix the perf issue
//                        LogRowActions()
                    }
                }
                    .frame(maxWidth: 100)
            }
        }
//        .onHover(perform: onHover)
    }
    
    private func tigerStripe() -> Color {
        return colour.opacity(index!.isMultiple(of: 2) ? 1 : 0.5)
    }
    
    private func adjustedIndex() -> Int {
        var adjusted: Int = Int(index!)
        adjusted += 1

        return adjusted
    }
    
    private func formatted(_ date: String) -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone(abbreviation: "MST")
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let inputDate = inputDateFormatter.date(from: date)
        
        if inputDate == nil {
            return "Invalid date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "MST")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        return dateFormatter.string(from: inputDate!)
    }
    
//    private func onHover(hovering: Bool) -> Void {
//        if hovering {
//            colour.opacity(0.7)
//        }
//    }
}

struct LogTableRowPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            LogRow(entry: Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world"), index: 0, colour: LogTable.rowColour)
            LogRow(entry: Entry(timestamp: "2023-01-01 19:49", job: "11", message: "Hello, world"), index: 1, colour: LogTable.rowColour)
        }
    }
}
