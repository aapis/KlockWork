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
        
        createLogFiles()
    }
    
    var body: some View {
        VStack {
            Text("DailyLogger Prototype")
                .font(.largeTitle)
            
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
//        .frame(minWidth: 700, minHeight: 700)
    }
    
    func createLogFiles() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        
        
        return paths[0]
    }
}

struct AddView : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var jobId: Int = 0
    @State private var noLogMessageAlert = false
    @State private var noJobIdAlert = false
    
    var body: some View {
        VStack {
            Text(category.title)
                .font(.title)
            
            HStack {
                NumberEntryField(title: "Job ID", value: self.$jobId)
                    .frame(width: 100)
                
                TextField("Enter your daily log text here", text: $text)
            }
            
            Spacer()
            
            Button("Log", action: {
                if self.$text.wrappedValue.count > 0 {
                    if self.$jobId.wrappedValue > 0 {
                        self.logLine()
                        
                        self.$text.wrappedValue = ""
                        self.$jobId.wrappedValue = 0
                    } else {
                        self.noJobIdAlert = true
                    }
                } else {
                    print("You have to type something")
                    self.noLogMessageAlert = true
                }
                
                
            })
                .alert(isPresented: $noLogMessageAlert) {
                    Alert(title: Text("Log text is a required field"), message: Text("You cannot log an empty string"), primaryButton: .default(Text("OK")), secondaryButton: .cancel()
                    )
                }
                .alert(isPresented: $noJobIdAlert) {
                    Alert(title: Text("Job ID is a required field"), message: Text("There is no job ID 0"), primaryButton: .default(Text("OK")), secondaryButton: .cancel()
                    )
                }
        }
            .frame(width: 700, height: 700)
            .padding()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func logLine() -> Void {
        print("Logged: \(self.$text.wrappedValue)")
        
//        let fileName = Bundle.main.path(forResource: category.title, ofType: "log")
        let fileName = "/Rolling Logs/\(category.title).log"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        print(fileName)
        
        do {
            try self.$text.wrappedValue.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Unable to write to file")
        }
    }
}

// thanks https://stackoverflow.com/a/61236221/7044855
struct NumberEntryField : View {
    @State private var enteredValue : String = ""
    
    var title: String
    
    @Binding var value: Int

    var body: some View {
        return TextField(title, text: $enteredValue)
            .onReceive(Just(enteredValue)) { typedValue in
                if let newValue = Int(typedValue) {
                    self.value = newValue
                }
        }.onAppear(perform:{self.enteredValue = "\(self.value)"})
    }
}

struct LogView: View {
    var category: Category
    
    var body: some View {
        VStack {
            Text("Viewing \(category.title) Log")
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
    
    func readFile() -> String {
        var lines: String = "nothing to see here"

        if let log = Bundle.main.url(forResource: category.title, withExtension: "log") {
            if let logLines = try? String(contentsOf: log) {
                if !logLines.isEmpty {
                    lines = logLines
                }
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
