//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Add : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var noLogMessageAlert = false
    @State private var noJobIdAlert = false
    @State private var todayLogLines: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Append to \(category.title).log")
                .font(.title)
                .bold()
            Divider()
            
            HStack {
                TextField("Job ID", text: self.$jobId)
                    .frame(width: 100)
                
                TextField("Enter your daily log text here", text: $text)
                
                Button("Log", action: {
                    if self.$text.wrappedValue != "" && self.$jobId.wrappedValue != "" {
                        self.logLine()
                        
                        self.$text.wrappedValue = ""
                        self.$jobId.wrappedValue = ""
                        self.populateTodayView()
                    } else {
                        print("You have to type something")
                    }
                })
            }
            
            ScrollView {
                TextField("Content here", text: $todayLogLines)
                    .disabled(true)
            }
            
            HStack {
                Button("New Day", action: {
                    self.logNewDay()
                    self.populateTodayView()
                })
                
                Button("Copy log contents", action: {
                    let pasteBoard = NSPasteboard.general
                    let data = self.readToday()
                    
                    pasteBoard.clearContents()
                    pasteBoard.setString(data, forType: .string)
                })
            }
        }
            .frame(width: 700, height: 700)
            .padding()
            .onAppear(perform: populateTodayView)
    }
    
    private func populateTodayView() -> Void {
        self.$todayLogLines.wrappedValue = self.readToday()
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
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("=========================\n\(date)\n=========================\n").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    private func logLine() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n\(date) - \(self.$jobId.wrappedValue) - \(self.$text.wrappedValue)").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    private func readToday() -> String {
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
        
        return lines.joined(separator: "\n")
    }
}
