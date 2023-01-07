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

struct Home: View {
    @ObservedObject public var records: Records
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var selected: String?
    @State public var appVersion: String?
    
//    private let sm: SyncMonitor = SyncMonitor()
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                NavigationLink {
                    ExperimentalToday(category: Category(title: "Daily"), records: records)
                        .navigationTitle("[Experimental] Today")
                } label: {
                    Image(systemName: "command")
                        .padding(.trailing, 10)
                    Text("[Experimental] Today")
                }
                
                NavigationLink {
                    Today(category: Category(title: "Daily"))
                        .navigationTitle("Today")
                } label: {
                    HStack {
                        Image(systemName: "doc.append.fill")
                            .padding(.trailing, 10)
                        Text("Today")
//                        Spacer()
//                        ProgressView()
                    }
                }
                
                NavigationLink {
                    Search(category: Category(title: "Daily"), records: records)
                        .navigationTitle("Search")
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .padding(.trailing, 10)
                    Text("Search")
                }
                
                NavigationLink {
                    NotesHome()
                        .navigationTitle("Notes")
                } label: {
                    Image(systemName: "note.text")
                        .padding(.trailing, 10)
                    Text("Notes")
                }

                NavigationLink {
                    CalendarView(category: Category(title: "Daily"), records: records)
                        .navigationTitle("Calendar")
                } label: {
                    Image(systemName: "calendar")
                        .padding(.trailing, 10)
                    Text("Calendar")
                }

                NavigationLink {
                    Backup(category: Category(title: "Daily"))
                        .navigationTitle("Backup")
                } label: {
                    Image(systemName: "cloud.fill")
                        .padding(.trailing, 10)
                    Text("Backup")
                }
                
                NavigationLink {
                    Import()
                        .navigationTitle("Import")
                } label: {
                    Image(systemName: "square.and.arrow.up.fill")
                        .padding(.trailing, 10)
                    Text("Import")
                }
            }
        } detail: {
            Text("Hello, world")
        }
        .navigationTitle("DailyLogger b.\(appVersion ?? "0")")
        .onAppear(perform: updateName)
//        .onReceive(sm.pub) { x in
//            print(x)
//            received()
//        }
    }
    
    private func updateName() -> Void {
        appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
//    private func received() -> Void {
//        print("SM: [Home] Received")
//    }
}

struct HomePreview: PreviewProvider {
    static var previews: some View {
        Home(records: Records())
    }
}
