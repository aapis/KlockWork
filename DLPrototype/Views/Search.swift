//
//  Search.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

// TODO: remove this entire class
struct Search: View {
    var category: Category
    @ObservedObject public var records: Records
    
    private let numDatesInPast: Int = 20
    
    @State private var searchByDate: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: String = ""
    @State private var dateList: [CustomPickerItem] = [CustomPickerItem(title: "Default", tag: 0)]
    @State private var selection = 0
    // TODO: refactor LogTable so this isn't always required
    @State private var ltd: UUID = UUID()
    // Flag for whether we are currently loading
    @State private var isLoading: Bool = false
    // Store which date we are currently showing data for
    @State private var currentDate: Date = Date()
    // Maybe also for storing the date? we'll see who wins
    @State private var selectedDate: Date = Date()
    // Store them so we can determine the selected date and filter LogTable accordingly
    @State private var items: [CustomPickerItem] = []
    
//    private let sm: SyncMonitor = SyncMonitor()
//    @EnvironmentObject public var sm: SyncMonitor
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.timestamp, order: .reverse)
        ],
        predicate: NSPredicate(format: "timestamp > %@ && timestamp <= %@", DateHelper.thisAm(), DateHelper.tomorrow())
    ) public var today: FetchedResults<LogRecord>
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                loading
            } else {
                header
                filters
                calendar
                table
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .defaultAppStorage(.standard)
        .background(Theme.toolbarColour)
        .onAppear(perform: setDate)
//        .onReceive(sm.publisher) { _ in
//            // this currently does the data/status updating
//            received()
//        }
    }
    
    var header: some View {
        HStack {
            Title(text: "Find records", image: "magnifyingglass.circle.fill")
            Spacer()
            FancyButton(text: "Find and copy", action: findAndCopy, icon: "doc.on.doc", showLabel: false)
        }
    }
    var filters: some View {
        HStack {
            FancyTextField(placeholder: "Search terms", lineLimit: 1, onSubmit: {}, text: $searchText)
            FancyPicker(onChange: change, items: items)
                .onAppear(perform: {
                    items = CustomPickerItem.listFrom(DateHelper.datesBeforeToday(numDays: numDatesInPast))
                })
        }
    }
    
    // MARK: calendar view
    var calendar: some View {
        CalendarThisWeek(records: records)
    }
    
    // MARK: Table view
    var table: some View {
        LogTable(ltd: $ltd)
//            .id(tableUuid)
    }
    
    // MARK: loading view
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                ProgressView("Loading Workspace...")
                Spacer()
            }
            
            Spacer()
        }
    }
    
    private func setDate() -> Void {
        currentDate = Date()
    }
    
    private func received() -> Void {
//        print("SM: [Search] Received \(sm.ready)")
        
//        if sm.ready {
//            isLoading = sm.ready
//        }
    }
    
    private func change(selected: Int) -> Void {
        let item = items[selected].title
        
        selectedDate = DateHelper.date(item) ?? Date()
    }
    
//    private func reloadUi() -> Void {
////        isLoading = true
//
//        func reload() {
////            ltd = UUID()
////            tableUuid = UUID()
////            workspaceReady = true
////            dateHasChanged = false
//            isLoading = false
//        }
//
//        // if we have records reload the after 1s
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
//            reload()
//        }
//    }
    
    // MARK: the following methods MAY be forsaken
    
    private func setDateList() -> Void {
        self.dateList = self.generateDateList()
        findAction()
    }
    
    private func findAction() -> Void {
        self.$searchByDate.wrappedValue = self.dateList[self.$selection.wrappedValue].title
        
        self.setSearchResults()
    }
    
    private func copyAction() -> Void {
        let pasteBoard = NSPasteboard.general
        let data = self.getAllRows()
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
    
    private func findAndCopy() -> Void {
        self.findAction()
        self.copyAction()
    }
        
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func setSearchResults() -> Void {
        self.$searchResults.wrappedValue = getAllRows()
    }
    
    private func getAllRows() -> String {
        let lines: [String] = getFilteredRows()
        
        return lines.joined(separator: "\n")
    }
    
    private func getFilteredRows() -> [String] {
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
        
        return lines
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
    
    private func getDatesForTable() -> [Entry] {
        var data = getFilteredRows()
        var entries: [Entry] = []
        
        guard !data.isEmpty || data.count == 1 else {
            let entry = Entry(timestamp: "0", job: "0", message: "No results for that search term or date")
            entries.append(entry)
            
            return entries;
        }
        
        // removes the "new day" entry
        data.removeFirst()
        
        for line in data {
            let parts = line.components(separatedBy: " - ")
            
            if parts.count > 1 {
                let entry = Entry(timestamp: parts[0], job: parts[1], message: parts[2])
            
                entries.append(entry)
            }
        }
        
        return entries
    }
}
