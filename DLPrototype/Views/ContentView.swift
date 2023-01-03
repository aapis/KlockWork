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
    @ObservedObject public var records: Records
    
    var categories = [Category]()
    @State private var selected: String? = "Record";
    
    @State private var path: [any View] = []
    
    
    init(records: Records) {
        categories.append(Category(title: "Daily"))
//        categories.append(Category(title: "Standup"))
//        categories.append(Category(title: "Reflection"))
//        createLogFiles()
        self.records = records
    }
    
    var body: some View {
//        NavigationStack(path: $path) {
        NavigationStack {
            List {
                NavigationLink(destination: Add(category: Category(title: "Daily"), records: records)) {
                    HStack {
                        Image(systemName: "doc.append.fill")
                            .padding(.trailing, 10)
                        Text("Record")
                    }.padding(10)
                }
//                NavigationLink {
//                    Add(category: Category(title: "Daily"), records: records)
//                } label: {
//                    HStack {
//                        Image(systemName: "doc.append.fill")
//                            .padding(.trailing, 10)
//                        Text("Record")
//                    }.padding(10)
//                }
                NavigationLink {
                    Search(category: Category(title: "Daily"), records: records)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .padding(.trailing, 10)
                        Text("Search")
                    }.padding(10)
                }
            }.listStyle(SidebarListStyle())
        }
        
//        GeometryReader { geometry in
//            VStack {
//                NavigationView {
//                    List {
//                        ForEach(categories) { category in
//                            NavigationLink(tag: 0, selection: $selected) {
//                                Add(category: category, records: records)
//                            } label: {
//                                HStack {
//                                    Image(systemName: "doc.append.fill")
//                                        .padding(.trailing, 10)
//                                    Text("Record")
//                                }.padding(10)
//                            }
//
//                            NavigationLink(tag: 1, selection: $selected) {
//                                Search(category: category, records: records)
//                            } label: {
//                                HStack {
//                                    Image(systemName: "magnifyingglass.circle.fill")
//                                        .padding(.trailing, 10)
//                                    Text("Search")
//                                }.padding(10)
//                            }
//
//                            NavigationLink(tag: 2, selection: $selected) {
//                                CalendarView(category: category, records: records)
//                            } label: {
//                                HStack {
//                                    Image(systemName: "calendar")
//                                        .padding(.trailing, 10)
//                                    Text("Calendar")
//                                }.padding(10)
//                            }
//
//                            NavigationLink(tag: 3, selection: $selected) {
//                                Backup(category: category)
//                            } label: {
//                                HStack {
//                                    Image(systemName: "cloud.fill")
//                                        .padding(.trailing, 10)
//                                    Text("Backup")
//                                }.padding(10)
//                            }
//                        }
//                    }
//                    .listStyle(SidebarListStyle())
//                    .padding(.top)
//                    .frame(minWidth: 300, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//
//                }
//                .navigationViewStyle(DoubleColumnNavigationViewStyle())
//                .frame(width: geometry.size.width, height: geometry.size.height)
//            }
//        }
    }
    
//    func createLogFiles() -> URL {
//        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//
//        return paths[0]
//    }
}


