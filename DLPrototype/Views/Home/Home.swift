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
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    @StateObject public var rm: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    
    @State private var selected: String?
    @State public var appVersion: String?
    @State public var splitDirection: Bool = false // false == horizontal, true == vertical
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                Section {
                    NavigationLink {
                        Today()
                            .navigationTitle("Today")
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(updater)
                            .toolbar {
                                Button(action: redraw, label: {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                })
                                .buttonStyle(.borderless)
                                .font(.title)
                                .keyboardShortcut("r")
                            }
                    } label: {
                        Image(systemName: "doc.append.fill")
                            .padding(.trailing, 10)
                        Text("Today")
                    }
                    
                    NavigationLink {
                        FindDashboard()
                            .navigationTitle("Find")
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(updater)
                            .toolbar {
                                Button(action: redraw, label: {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                })
                                .buttonStyle(.borderless)
                                .font(.title)
                                .keyboardShortcut("r")
                            }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing, 10)
                        Text("Find")
                    }
                }
                
                Section(header: Text("Entities")) {
                    NavigationLink {
                        NoteDashboard()
                            .navigationTitle("Notes")
                            .toolbar {
                                if showExperimentalFeatures {
                                    Button(action: {}, label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                }
                            }
                    } label: {
                        Image(systemName: "note.text")
                            .padding(.trailing, 10)
                        Text("Notes")
                    }
                    
                    NavigationLink {
                        TaskDashboard()
                            .navigationTitle("Tasks")
                            .environmentObject(rm)
                            .environmentObject(updater)
                            .toolbar {
                                if showExperimentalFeatures {
                                    Button(action: {}, label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                }
                            }
                    } label: {
                        Image(systemName: "list.number")
                            .padding(.trailing, 10)
                        Text("Tasks")
                    }
                    
                    NavigationLink {
                        ProjectsDashboard()
                            .navigationTitle("Projects")
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(updater)
                            .toolbar {
                                if showExperimentalFeatures {
                                    Button(action: {}, label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                }
                            }
                    } label: {
                        Image(systemName: "folder")
                            .padding(.trailing, 10)
                        Text("Projects")
                    }
                    
                    NavigationLink {
                        Import()
                            .navigationTitle("Import")
                            .environmentObject(rm)
                            .toolbar {
                                if showExperimentalFeatures {
                                    Button(action: {}, label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                }
                            }
                    } label: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .padding(.trailing, 10)
                        Text("In + Out")
                    }
                }
                
                if showExperimentalFeatures {                    
                    Section(header: Text("Experimental")) {
                        NavigationLink {
                            Split(direction: $splitDirection)
                                .navigationTitle("Multitasking")
                                .environmentObject(rm)
                                .toolbar {
                                    Button(action: setSplitViewDirection, label: {
                                        if !splitDirection {
                                            Image(systemName: "rectangle.split.1x2")
                                        } else {
                                            Image(systemName: "rectangle.split.2x1")
                                        }
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                    
                                    if showExperimentalFeatures {
                                        Button(action: {}, label: {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                        })
                                        .buttonStyle(.borderless)
                                        .font(.title)
                                    }
                                }
                        } label: {
                            Image(systemName: "rectangle.split.2x1")
                                .padding(.trailing, 10)
                            Text("Multitasking")
                        }
                        
                        NavigationLink {
                            Manage()
                                .navigationTitle("Manage")
                                .toolbar {
                                    if showExperimentalFeatures {
                                        Button(action: {}, label: {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                        })
                                        .buttonStyle(.borderless)
                                        .font(.title)
                                    }
                                }
                        } label: {
                            Image(systemName: "books.vertical")
                                .padding(.trailing, 10)
                            Text("Manage")
                        }
                        
                        NavigationLink {
                            CalendarView()
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
                    }
                }
            }
        } detail: {
            Text("This dashboard is great, isn't it")
                
        }
        .navigationTitle("DailyLogger b.\(appVersion ?? "0")")
        .onAppear(perform: updateName)
        .environmentObject(rm)
    }
    
    private func updateName() -> Void {
        appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    private func setSplitViewDirection() -> Void {
        splitDirection.toggle()
    }
    
    private func redraw() -> Void {
        updater.update()
    }
}

//struct HomePreview: PreviewProvider {
//    static var previews: some View {
//        Home(rm: LogRecords(moc: PersistenceController.preview.container.viewContext))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
//    }
//}
