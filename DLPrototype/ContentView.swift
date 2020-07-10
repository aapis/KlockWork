//
//  ContentView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

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
//        .frame(minWidth: 900, minHeight: 900)
    }
}

struct AddView : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            Text(category.title)
                .font(.title)
            
            TextField("Enter your daily log text here", text: $text)
            
            Spacer()
            
            Button("Log", action: {
                if self.$text.wrappedValue.count > 0 {
                    print("Logged \(self.$text.wrappedValue)")
                    self.$text.wrappedValue = ""
                } else {
                    print("You have to type something")
                    self.showingAlert = true
                }
            })
                .alert(isPresented:$showingAlert) {
                    Alert(title: Text("You must enter some text"), message: Text("You cannot log an empty string"), primaryButton: .default(Text("OK")), secondaryButton: .cancel()
                    )
                }
        }
            .frame(width: 900, height: 900)
            .padding()
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
                Text(readFile(whichLog: category.title))
            }
            
            Spacer()
        }
        .frame(width: 900, height: 900)
        .padding()
    }
    
    func readFile(whichLog: String) -> String {
        var lines: String = "nothing to see here"

        if let dailyLog = Bundle.main.url(forResource: whichLog, withExtension: "log") {
            if let logLines = try? String(contentsOf: dailyLog) {
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
