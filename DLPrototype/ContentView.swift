//
//  ContentView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import Combine
import SwiftUI

struct Category: Identifiable {
    var id = UUID()
    var title: String
}

struct ContentView: View {
    var categories = [Category]()
    
    init() {
        categories.append(Category(title: "Daily"))
        categories.append(Category(title: "Standup"))
        categories.append(Category(title: "Reflection"))
        
//        createLogFiles()
    }
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    ForEach(categories) { category in
                        Text(category.title)
                            .bold()
                        
                        NavigationLink(destination: AddView(category: category)) {
                            Text("Add")
                                .padding(10)
                        }
                        
                        NavigationLink(destination: LogView(category: category)) {
                            Text("View")
                                .padding(10)
                        }
                    }
                }.listStyle(SidebarListStyle())
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
    
//    func createLogFiles() -> URL {
//        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//
//        return paths[0]
//    }
}

struct AddView : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var noLogMessageAlert = false
    @State private var noJobIdAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Append to \(category.title).log")
                .font(.title)
            
            HStack {
                TextField("Job ID", text: self.$jobId)
                    .frame(width: 100)
                
                TextField("Enter your daily log text here", text: $text)
                
                Button("Log", action: {
                    if self.$text.wrappedValue != "" && self.$jobId.wrappedValue != "" {
                        self.logLine()
                        
                        self.$text.wrappedValue = ""
                        self.$jobId.wrappedValue = ""
                    } else {
                        print("You have to type something")
                    }
                })
            }
            
            Spacer()
            
            Button("New Day", action: {
                self.logNewDay()
            })
        }
            .frame(width: 700, height: 700)
            .padding()
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
        let time = Date()
        guard let line: Data = ("=========================\n\(time)\n=========================\n").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    func logLine() -> Void {
        let time = Date()
        guard let line: Data = ("\n\(time) - \(self.$jobId.wrappedValue) - \(self.$text.wrappedValue)").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
}

struct LogView: View {
    var category: Category
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(category.title).log")
                .font(.title)
            
            Spacer()
            
            ScrollView {
                Text(readFile())
            }
            
            Spacer()
        }
        .frame(width: 700, height: 700)
        .padding()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func readFile() -> String {
        var lines: String = "nothing to see here"

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
            
        if let logLines = try? String(contentsOf: log) {
            if !logLines.isEmpty {
                lines = logLines
            }
        }
        
        return lines
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
