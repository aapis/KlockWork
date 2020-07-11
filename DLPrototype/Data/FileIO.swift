//
//  FileIO.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

class FileIO {
    @Binding var category: Category
    @Binding var searchTerm: String
    @Binding var searchResults: String
    
    public func read() -> String {
        var lines: String = "nothing to see here"

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
            
        if let logLines = try? String(contentsOf: log) {
            if !logLines.isEmpty {
                lines = logLines
            }
        }
        
        return lines
    }
    
    public func filter(text: inout Binding<String>, results: inout Binding<String>) -> String {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        let term = getSearchTerm(term: text.wrappedValue)
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                if line.contains(term) {
                    lines.append(line)
                }
            }
        }
        print(lines)
        results.wrappedValue = lines.joined(separator: "\n")
        return results.wrappedValue
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func getSearchTerm(term: String) -> String {
        var output = ""
        
        switch term {
        case "today":
            output = getRelativeDate(0)
        case "yesterday":
            output = getRelativeDate(-1)
        default:
            output = term
        }
        
        return output
    }
    
    private func getRelativeDate(_ relativeDate: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        
        let midnight = calendar.startOfDay(for: Date())
        let requestedDate = calendar.date(byAdding: .day, value: relativeDate, to: midnight)!
        let formatted = formatter.string(from: requestedDate)
        
        return formatted
    }
}
