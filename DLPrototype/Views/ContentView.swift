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
    @State private var activeTab = true;
    
    init() {
        categories.append(Category(title: "Daily"))
//        categories.append(Category(title: "Standup"))
//        categories.append(Category(title: "Reflection"))
//        createLogFiles()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                NavigationView {
                    List {
                        ForEach(categories) { category in                            
                            NavigationLink(destination: Add(category: category), isActive: $activeTab) {
                                HStack {
                                    Image(systemName: "doc.append.fill")
                                        .padding(.trailing, 10)
                                    Text("Record")
                                }.padding(10)
                            }
                            
                            NavigationLink(destination: Search(category: category)) {
                                HStack {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .padding(.trailing, 10)
                                    Text("Search")
                                }.padding(10)
                            }
                            
                            NavigationLink(destination: CalendarView(category: category)) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .padding(.trailing, 10)
                                    Text("Calendar")
                                }.padding(10)
                            }
                            
                            NavigationLink(destination: Log(category: category)) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .padding(.trailing, 10)
                                    Text("View")
                                }.padding(10)
                            }
                            
                            NavigationLink(destination: Backup(category: category)) {
                                HStack {
                                    Image(systemName: "cloud.fill")
                                        .padding(.trailing, 10)
                                    Text("Backup")
                                }.padding(10)
                            }
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .padding(.top)
                    .frame(minWidth: 300, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

                }
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
//    func createLogFiles() -> URL {
//        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//
//        return paths[0]
//    }
}


