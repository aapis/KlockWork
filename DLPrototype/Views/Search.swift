//
//  Search.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct CustomPickerItem: Identifiable {
    var id = UUID()
    var title: String
    var tag: Int
}

struct Search: View {
    var category: Category
    
    @State private var searchByDate: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: String = ""
    @State private var dateList: [CustomPickerItem] = [CustomPickerItem(title: "Default", tag: 0)]
    @State private var selection = 1
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "magnifyingglass.circle.fill"))
                    .font(.title)
                Text("Find entries")
                    .font(.title)
            }
            
            Divider()
            
            HStack {
                // formerly in ComboBox
                Picker("Date", selection: $selection) {
                    ForEach(dateList) { item in
                        Text(item.title)
                            .tag(item.tag)
                            .font(Font.system(size: 16, design: .default))
                    }
                }
                    .frame(width: 200)
                    .font(Font.system(size: 16, design: .default))
                    .onAppear(perform: {
                        self.dateList = self.generateDateList()
                    })

                TextField("Search terms", text: $searchText)
                    .font(Font.system(size: 16, design: .default))
                
                Button("Search", action: {
                    self.$searchByDate.wrappedValue = self.dateList[self.$selection.wrappedValue].title
                    
                    self.getFilteredLogRows()
                })
                .background(Color.accentColor)
                .font(Font.system(size: 16, design: .default))
            }
            
            Divider()
            
            ScrollView {
                TextField("No results", text: $searchResults)
                    .disabled(true)
                    .font(Font.system(size: 16, design: .default))
            }
            
            Spacer()
            
            Button("Copy search results", action: {
                let pasteBoard = NSPasteboard.general
                let data = self.getFilteredLogRows()
                
                pasteBoard.clearContents()
                pasteBoard.setString(data, forType: .string)
            })
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
    }
        
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func getFilteredLogRows() -> String {
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
        case "":
            term = self.$searchByDate.wrappedValue
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
    
    private func generateDateList() -> [CustomPickerItem] {
        var dates: [CustomPickerItem] = []
        
        for i in 0...30 {
            dates.append(CustomPickerItem(title: getRelativeDate(i * -1), tag: i))
        }
        
        return dates
    }
}
