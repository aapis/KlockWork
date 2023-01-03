//
//  Records.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2022-04-08.
//  Copyright © 2022 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

class Records: ObservableObject, Identifiable {
    public var records: [String] = []
    public var id = UUID()
    
    @Published public var entries: [Entry] = []
    @Published public var sortOrder: Bool = false // DESC==false, ASC==true
    
    init() {
        print("Records::init")
        
        sortOrder = (UserDefaults.standard.string(forKey: "defaultTableSortOrder") != nil)
    }
    
    public func rowsContain(term: String) -> [String] {
        var results: [String] = []
        
        for record in records {
            if record.contains(term) {
                results.append(record)
            }
        }
        
        return results
    }
    
    public func rowsStartsWith(term: String) -> [String] {
        var results: [String] = []
        
        for record in records {
            if record.starts(with: term) {
                results.append(record)
            }
        }
        
        return results
    }
    
    public func today() -> [String] {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone(abbreviation: "MST")
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd"
        let date = inputDateFormatter.string(from: Date())
        
        return rowsStartsWith(term: date)
    }
    
    public func makeConsumable() -> Void {
        print("Records::makeConsumable")
        let to = today()
        
        // don't attempt to convert if we already have entries
        if entries.count > 0 {
            return
        }
        
        for record in to {
            let parts = record.components(separatedBy: " - ")
            
            if parts.count > 1 {
                let entry = Entry(timestamp: parts[0], job: parts[1], message: parts[2])

                if sortOrder {
                    entries.insert(entry, at: 0)
                } else {
                    entries.append(entry)
                }
            }
        }
    }
    
    public func wordCount() -> Int {
        var words: [String] = []
        
        for entry in entries {
            words.append(entry.message)
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))
        
        return wordSet.count
    }
    
    public func reload() -> Void {
        print("Records::reload - re/loading records")
        
        records = read("Daily.log")
        entries = []
        makeConsumable() // TODO: only creates TODAY's ENTRIES
    }
    
    public func dataSince(date: Date, fileName: String) -> [String] {
        var lines: [String] = []
        
        let log = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                let lineComponents = line.components(separatedBy: " - ")
                
                let inputDateFormatter = DateFormatter()
                inputDateFormatter.timeZone = TimeZone(abbreviation: "MST")
                inputDateFormatter.locale = NSLocale.current
                inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                if lineComponents.count > 1 { // each actual data row contains 3 distinct sections: timestamp, jobID, message
                    let rowDate = inputDateFormatter.date(from: lineComponents.first!)!
                    
                    if rowDate >= date {
                        lines.append(line)
                    }
                }
            }
        }
        
        return lines
    }
    
    // Returns logs added in the last 3 months
    private func read(_ filename: String) -> [String] {
        var components = DateComponents()
        components.month = -3
        
        let calendar = Calendar.current
        let date = calendar.date(byAdding: components, to: Date())
        
        if date == nil {
            return []
        }
        
        return dataSince(date: date!, fileName: filename)
    }

    // Returns ALL rows in the current log file
    private func readFile(_ fileName: String) -> [String] {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                lines.append(line)
            }
        }
        
        return lines
    }
    
//    private func startsWithOld(term: String) -> [String] {
//        var lines: [String] = []
//
//        let log = getDocumentsDirectory().appendingPathComponent("Daily.log")
//
//        if let logLines = try? String(contentsOf: log) {
//            for line in logLines.components(separatedBy: .newlines) {
//                if line.starts(with: term) {
//                    lines.append(line)
//                }
//            }
//        }
//
//        return lines
//    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}
