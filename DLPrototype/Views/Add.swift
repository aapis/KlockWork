//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Entry: Identifiable {
    let timestamp: String
    let job: String
    let message: String
    let id = UUID()
}

struct Add : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var noLogMessageAlert = false
    @State private var noJobIdAlert = false
    @State private var todayLogLines: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "doc.append.fill"))
                    .font(.title)
                Text("Record an entry")
                    .font(.title)
            }

            Divider()

            HStack {
                TextField("Job ID", text: $jobId)
                    .frame(width: 100)
                    .font(Font.system(size: 16, design: .default))

                TextField("Type and hit enter to save...", text: $text)
                    .font(Font.system(size: 16, design: .default))
                    .onSubmit {
                        submitAction()
                    }
            }

            Divider()
            
            Table(readTodayTable()) {
                TableColumn("Timestamp", value: \.timestamp)
                    .width(120)
                TableColumn("Job ID", value: \.job)
                    .width(60)
                TableColumn("Message", value: \.message)
            }

            HStack {
                Button("New Day", action: newDayAction)
                Button("Copy all rows", action: copyAction)
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
            .onAppear(perform: populateTodayView)
    }
    
    private func newDayAction() -> Void {
        self.logNewDay()
        self.populateTodayView()
    }
    
    private func copyAction() -> Void {
        let pasteBoard = NSPasteboard.general
        let data = self.readToday()
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
    
    private func submitAction() -> Void {
        if self.$text.wrappedValue != "" && self.$jobId.wrappedValue != "" {
            self.logLine()
            
            self.$text.wrappedValue = ""
            self.populateTodayView()
        } else {
            print("You have to type something")
        }
    }
    
    func populateTodayView() -> Void {
        self.$todayLogLines.wrappedValue = self.readToday()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func writeToLog(output: Data) -> Void {
        let fileName = "\(category.title).log"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let fileHandle = try? FileHandle(forWritingTo: filePath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(output)
            fileHandle.closeFile()
        }
    }
    
    func logNewDay() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n=========================\n\(date)\n=========================").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    func logLine() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n\(date) - \(self.$jobId.wrappedValue) - \(self.$text.wrappedValue)").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    func readToday() -> String {
        return readTodayLines().joined(separator: "\n")
    }
    
    private func readTodayLines() -> [String] {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = formatter.string(from: Date())
            
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
        
        guard !data.isEmpty else {
            let entry = Entry(timestamp: "0", job: "0", message: "No results for that search term or date")
            entries.append(entry)
            
            return entries;
        }
        
        // removes the "new day" entry
        data.removeFirst()
        
        for line in data {
            let parts = line.components(separatedBy: " - ")
            let entry = Entry(timestamp: parts[0], job: parts[1], message: parts[2])
            
            entries.append(entry)
        }
        
        return entries
    }
}
