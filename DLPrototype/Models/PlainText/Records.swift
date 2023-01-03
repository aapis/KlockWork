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
        return rowsStartsWith(term: dateFormat(Date()))
    }
    
    public func forDate(_ date: Date) -> [String] {
        return rowsStartsWith(term: dateFormat(date))
    }
    
    public func entriesFor(_ date: Date) -> [Entry] {
        return entries
    }
    
    public func jobIdsFor(_ date: Date) -> Set<String> {
        var ids: [String] = []
        let lines = rowsStartsWith(term: dateFormat(date))
        
        for line in lines {
            let lineComponents = line.components(separatedBy: " - ")
            
            if lineComponents[1] != "11" {
                // ["2023-01-02 19:08", "11", "please work"]
                ids.append(lineComponents[1])
            }
        }
        
        let idSet = Set(ids)
        
        return idSet
    }
    
    public func jobs(date: Date, sectionTitle: String) -> [CustomPickerItem] {
        var jobIds: [Int] = []
        var jobs: [CustomPickerItem] = [
            CustomPickerItem(title: sectionTitle, tag: -1, disabled: true),
        ]
        
        forDate(date).forEach { line in
            let lineParts = line.components(separatedBy: " - ")
            
            if lineParts.count > 1 {
                let jid = Int(lineParts[1]) ?? 0

                jobIds.append(jid)
            }
        }
        
        // remove duplicates
        var uniqueJobs = Array(Set(jobIds))
        
        // sort unique job ID list numerically
        uniqueJobs.sort()
        
        // create set of picker items
        for job in uniqueJobs {
            let pickerJob = CustomPickerItem(title: String(" - \(job)"), tag: job)
            jobs.append(pickerJob)
        }
        
        return jobs
    }
    
    // Compiles today and yesterday's job IDs into a list for a Picker
    public func recentJobs() -> [CustomPickerItem] {
        var recent: [CustomPickerItem] = [
            CustomPickerItem(title: "Recent jobs", tag: 0)
        ]
        var components = DateComponents()
        components.day = -2 // -1 is not yesterday for some reason
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: components, to: Date())
        
        recent.append(contentsOf: jobs(date: Date(), sectionTitle: "Today"))
        
        if yesterday != nil {
            recent.append(contentsOf: jobs(date: yesterday!, sectionTitle: "Yesterday"))
        }
        
        return recent
    }
    
    // Converts string data to Entry objects, which are usable in the UI
    public func makeConsumable() -> Void {
        print("Records::makeConsumable")
        
        // don't attempt to convert if we already have entries
        if entries.count > 0 {
            return
        }
        
        for record in today() {
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
        makeConsumable() // TODO: makeComsumable only creates TODAY's ENTRIES
    }
    
    // Returns list of strings representing all log lines since a given date, from a given file
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
    
    // Returns string like 2020-06-11 representing a date, for use in filtering
    private func dateFormat(_ date: Date) -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "MST")
        df.locale = NSLocale.current
        df.dateFormat = "yyyy-MM-dd"
        
        return df.string(from: Date())
    }
    
//    private func rowToEntry(row: String) -> Entry {
//        let lineComponents = row.components(separatedBy: " - ")
//
//        if lineComponents.count > 1 { // each actual data row contains 3 distinct sections: timestamp, jobID, message
//
//        }
//    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}
