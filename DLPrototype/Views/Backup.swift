//
//  Log.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Backup: View {
    @State private var lastBackupDate: String = ""
    
    var category: Category
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "cloud.fill"))
                    .font(.title)
                Text("Backup \(category.title).log")
                    .font(.title)
            }
            
            Divider()
            
            Text("Last Backup: ") + Text($lastBackupDate.wrappedValue)
            
            Button("Backup Now", action: {
                self.performBackup()
            })
                .background(Color.accentColor)
            
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .onAppear(perform: getLastBackupDate)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func getLastBackupDate() -> Void {
        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        
        if let logLines = try? String(contentsOf: log) {
            let lines = logLines.components(separatedBy: .newlines)
            
            if lines.count > 0 {
                $lastBackupDate.wrappedValue = lines.first!
            }
        }
    }
    
    private func performBackup() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        let to = getDocumentsDirectory().appendingPathComponent("Log Backups/\(category.title)-\(date).log")
        let at = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        
        if let _ = try? FileManager().copyItem(at: at, to: to) {
            let text = "Backed up to \"Log Backups/\(date)\""
            
            logLine(text: text)
            
            $lastBackupDate.wrappedValue = date
        }
    }
    
    private func writeToLog(output: Data) -> Void {
        let fileName = "\(category.title).log"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let fileHandle = try? FileHandle(forWritingTo: filePath) {
            fileHandle.truncateFile(atOffset: 0)
            fileHandle.write(output)
            fileHandle.closeFile()
        }
    }
    
    private func logLine(text: String) -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n\(date) - \(text)").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
}
