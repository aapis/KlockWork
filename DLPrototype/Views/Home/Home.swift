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
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var recordsModel: LogRecords
    
    @State private var selected: String?
    @State public var appVersion: String?
    @State public var splitDirection: Bool = false // false == horizontal, true == vertical
    
//    @ObservedObject public var sm: SyncMonitor = SyncMonitor()
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                NavigationLink {
                    Today()
                        .navigationTitle("Today")
                        .environmentObject(recordsModel)
//                        .environmentObject(sm)
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
                    Image(systemName: "doc.append.fill")
                        .padding(.trailing, 10)
                    Text("Today")
                }
                
                // TODO: remove in a later version
//                NavigationLink {
//                    Search(category: Category(title: "Daily"), records: records)
//                        .navigationTitle("Search")
////                        .environmentObject(sm)
//                } label: {
//                    Image(systemName: "magnifyingglass.circle.fill")
//                        .padding(.trailing, 10)
//                    Text("Search")
//                }
                
                NavigationLink {
                    NotesHome()
                        .navigationTitle("Notes")
                        .navigationSplitViewColumnWidth(ideal: 300)
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
                    Split(direction: $splitDirection)
                        .navigationTitle("Split")
                        .environmentObject(recordsModel)
                        .navigationSplitViewColumnWidth(ideal: 300)
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
                    //                        .environmentObject(sm)
                } label: {
                    Image(systemName: "command")
                        .padding(.trailing, 10)
                    Text("Split")
                }
                
                NavigationLink {
                    Import()
                        .navigationTitle("Import")
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
                    Text("Import")
                }
                
                if showExperimentalFeatures {
                    Divider()
                
                    NavigationLink {
                        CalendarView(category: Category(title: "Daily"), records: records)
                            .navigationTitle("Calendar")
                    } label: {
                        Image(systemName: "calendar")
                            .padding(.trailing, 10)
                        Text("Calendar")
                    }
                

                    // TODO: remove in a later version
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
        } detail: {
            Text("This dashboard is great, isn't it")
        }
        .navigationTitle("DailyLogger b.\(appVersion ?? "0")")
        .onAppear(perform: updateName)
        .environmentObject(recordsModel)
    }
    
    private func updateName() -> Void {
        appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    private func setSplitViewDirection() -> Void {
        splitDirection.toggle()
    }
}

//struct HomePreview: PreviewProvider {
//    static var previews: some View {
//        Home(records: Records(), recordsModel: LogRecords(moc: PersistenceController.preview.container.viewContext))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
//    }
//}
