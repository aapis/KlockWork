//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

let defaultPickerChoice: CustomPickerItem  = CustomPickerItem(title: "Recent jobs", tag: 0)
let defaultCopiedRow: Entry = Entry(timestamp: "00", job: "11", message: "Row not found")

struct Add : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var taskUrl: String = "" // only treated as a string, no need to be URL-type
    @State private var noLogMessageAlert = false
    @State private var noJobIdAlert = false
    @State private var todayLogLines: String = ""
    @State private var statusMessage: String = ""
    @State private var recentJobs: [CustomPickerItem] = [defaultPickerChoice]
    @State private var jobPickerSelection = 0
    @State private var copiedRow: Entry = defaultCopiedRow
    @State private var tableData: [Entry] = []
    @State private var isPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "doc.append.fill"))
                    .font(.title)
                Text("Record an entry")
                    .font(.title)
                
                Spacer()
                
                // TODO: this causes a crash that I have not had time to investigate yet
//                Button(action: { copyAction() }, label: {
//                    Image(systemName: "doc.on.doc")
//                })
//                    .help("Copy all rows")
                
                Button(action: populateTodayView, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                    .help("Reload data")
                    .keyboardShortcut("r")
                
                Button(action: { isPresented = true; newDayAction() }, label: {
                    Image(systemName: "sunrise")
                })
                    .help("New day")
                    .keyboardShortcut("n")
                    .alert("It's a brand new day!", isPresented: $isPresented) {}
            }

            Divider()

            HStack {
                TextField("Job ID", text: $jobId)
                    .frame(width: 100)
                    .font(Font.system(size: 16, design: .default))
                
                Text("Or")
                
                TextField("Task URL", text: $taskUrl)
                    .font(Font.system(size: 16, design: .default))
                
                Picker("Job", selection: $jobPickerSelection) {
                    ForEach(recentJobs) { item in
                        Text(item.title)
                            .tag(item.tag)
                            .disabled(item.disabled)
                            .font(Font.system(size: 16, design: .default))
                    }
                }
                    .labelsHidden()
                    .frame(width: 200)
                    .font(Font.system(size: 16, design: .default))
                    .onChange(of: jobPickerSelection) { _ in
                        // modifies jobId to associate the job to the message
                        jobId = String(jobPickerSelection)
//                        jobPickerSelection = 0 // TODO: should reset picker to first item but doesn't for $reasons
                    }
            }
            
            VStack {
                TextField("Type and hit enter to save...", text: $text, axis: .vertical)
                    .font(Font.system(size: 16, design: .default))
                    .lineLimit(3...)
                    .disableAutocorrection(true)
                    .onSubmit {
                        submitAction()
                    }
            }

            Divider()
            
            // TODO: testing new/custom table row display
//            ForEach(tableData) { _ in LogTable(entries: tableData) }
            LogTable(entries: tableData)
            
            
//            Table(tableData) {
//                TableColumn("Timestamp", value: \.timestamp)
//                    .width(120)
//                TableColumn("Job ID", value: \.job)
//                    .width(60)
//                TableColumn("Message", value: \.message)
//            }
//                .contextMenu {
//                    Button("Copy row", action: {
//                        copyAction(tableData[0])
//
//                    })
//                    Divider()
//                    Button(action: {}) { Text("Copy job ID") }
//                    Button(action: {}) { Text("Copy timestamp") }
//                    Button(action: {}) { Text("Copy message") }
//                    Button(action: {}) { Text("Copy row ID") }
//                }
            
            HStack {
                Text(statusMessage)
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
            .onAppear(perform: populateTodayView)
    }
    
//    private func copyRow() -> Void {
//        print($0)
//        print($selection.wrappedValue)
//        print("tapped")
//    }
    
    private func jobIdList(from: [String], sectionTitle: String) -> [CustomPickerItem]? {
        if (from.isEmpty) {
            return []
        }
        
        // get all job IDs from the set
        var jobIds: [Int] = []
        
        from.forEach { line in
            let lineParts = line.components(separatedBy: " - ")
            
            if lineParts.count > 1 {
                let timestamp = Int(lineParts[1]) ?? 0

                jobIds.append(timestamp)
            }
        }
        
        var jobs: [CustomPickerItem] = [
            CustomPickerItem(title: sectionTitle, tag: -1, disabled: true),
        ]
        
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
    
    /// Pull the recent job IDs from today's log entries
    private func buildRecentJobIdList() -> Void {
        resetPickerToDefault()
        
        var jobs: [CustomPickerItem] = []
        let todayLines: [String] = readNeighbourLines() // get today's jobs
        
        if todayLines.count > 0 {
            jobs.append(contentsOf: jobIdList(from: todayLines, sectionTitle: "Today")!)
        }
        
        if todayIsMonday() {
            let fridayLines: [String] = readNeighbourLines(-3) // get friday's jobs
            
            if fridayLines.count > 0 {
                jobs.append(contentsOf: jobIdList(from: fridayLines, sectionTitle: "Friday")!)
            }
        }
        
        let yesterdayLines: [String] = readNeighbourLines(-1) // get yesterday's jobs
        
        if yesterdayLines.count > 0 {
            jobs.append(contentsOf: jobIdList(from: yesterdayLines, sectionTitle: "Yesterday")!)
        }
        
        for job in jobs {
            recentJobs.append(job)
        }
    }
    
    private func todayIsMonday() -> Bool {
        let calendar = Calendar.current
        let currentDay = calendar.dateComponents([.day], from: Date())
        
        return currentDay.day == 1
    }
    
    /// Resets the recentJobs picker to it's default state by removing all elements and appending the default option
    private func resetPickerToDefault() -> Void {
        recentJobs.removeAll()
        recentJobs.append(defaultPickerChoice)
    }
    
    private func newDayAction() -> Void {
        logNewDay()
        clearTodayView()
        
        statusMessage = "New day!"
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            statusMessage = ""
            
            timer.invalidate()
        }
    }
    
    private func copyAction(data: String? = nil) -> Void {
        let pasteBoard = NSPasteboard.general
        
        if var data = data {
            data = readToday()
        }
        
        pasteBoard.clearContents()
        pasteBoard.setString(data!, forType: .string)
        
        statusMessage = "Copied!"
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            statusMessage = ""
            
            timer.invalidate()
        }
    }
    
    private func submitAction() -> Void {
        if !text.isEmpty && (!jobId.isEmpty || !taskUrl.isEmpty) {
            logLine()
            
            text = ""
            populateTodayView()
        } else {
            print("You have to type something")
        }
    }
    
    private func populateTodayView() -> Void {
        // read log data into memory
        todayLogLines = readToday()
        // convert log data into [Entry]
        tableData = readTodayTable()
        // update the recent job picker
        buildRecentJobIdList()
    }
    
    private func clearTodayView() -> Void {
        todayLogLines = ""
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func writeToLog(output: Data) -> Void {
        let fileName = "\(category.title).log"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let fileHandle = try? FileHandle(forWritingTo: filePath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(output)
            fileHandle.closeFile()
        }
    }
    
    private func logNewDay() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n=========================\n\(date)\n=========================").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    private func logLine() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n\(date) - \(getJobId()) - \(text)").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    private func getJobId() -> String {
        if !taskUrl.isEmpty {
            jobId = String(taskUrl.suffix(5))
        }
        
        return jobId
    }
    
    private func readToday() -> String {
        return readTodayLines().joined(separator: "\n")
    }
    
    private func readNeighbourLines(_ neighbour: Int? = 0) -> [String] {
        var components = DateComponents()
        components.day = neighbour
        
        let calendar = Calendar.current
        let date = Date()
        let neighbourDate = calendar.date(byAdding: components, to: date)!
        
        return readLines(forDate: neighbourDate)
    }
    
    private func readTodayLines() -> [String] {
        return readNeighbourLines() // aka, today - 0 == today
    }
    
    private func readLines(forDate: Date) -> [String] {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = formatter.string(from: forDate)
            
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                if line.hasPrefix(date) {
                    lines.append(line)
                }
            }
        }
        
        return lines
    }
    
    private func readTodayTable() -> [Entry] {
        var data = readTodayLines()
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
