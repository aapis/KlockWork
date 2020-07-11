//
//  Search.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Search: View {
    var category: Category
    
    @State private var searchText: String = ""
    @State private var searchResults: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Search \(category.title).log")
                .font(.title)
            
            HStack {
                TextField("Search terms", text: $searchText)
                
                Button("Search", action: {
                    self.doSearch()
                })
                    
            }
            
            ScrollView {
                TextField("No results", text: $searchResults)
                    .disabled(true)
            }
            
            Spacer()
            
            Button("Copy search results", action: {
                let pasteBoard = NSPasteboard.general
                let data = self.filterLogRows()
                
                pasteBoard.clearContents()
                pasteBoard.setString(data, forType: .string)
            })
        }
            .frame(width: 700, height: 700)
            .padding()
    }
    
    private func doSearch() -> Void {
        if self.$searchText.wrappedValue != "" {
            self.filterLogRows()
        } else {
            print("You have to type something")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func filterLogRows() -> String {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        let term = getSearchTerm()
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                if line.contains(term) {
                    lines.append(line)
                }
            }
        }
        
        self.$searchResults.wrappedValue = lines.joined(separator: "\n")
        
        return self.$searchResults.wrappedValue
    }
    
    private func getSearchTerm() -> String {
        var term = ""
        
        switch self.$searchText.wrappedValue {
        case "today":
            term = getRelativeDate(0)
        case "yesterday":
            term = getRelativeDate(-1)
        default:
            term = self.$searchText.wrappedValue
        }
        
        return term
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
