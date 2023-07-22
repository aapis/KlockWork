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

struct Home: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    @StateObject public var rm: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
//    @StateObject public var pr: CoreDataProjects = CoreDataProjects(moc: PersistenceController.shared.container.viewContext)
    
    @State public var appVersion: String?
    @State public var splitDirection: Bool = false // false == horizontal, true == vertical
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false

    // TODO: started trying to add "child items" under each nav link but it didn't work as expected so I moved on
//    private var projects: [Any] {
//        var links: [Any] = []
//
//        let alive = pr.alive()
//
//        for p in alive {
//            let link = NavigationLink {
//                ProjectsDashboard()
//                    .navigationTitle("Project 1")
//                    .environmentObject(rm)
//                    .environmentObject(jm)
//                    .environmentObject(updater)
//            } label: {
//                Text(p.name ?? "Item")
//            }
//
//            links.append(link)
//        }
//
//        return links
//    }
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    NavigationLink {
                        Dashboard()
                            .navigationTitle("Dashboard")
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(ce)
                            .environmentObject(crm)
//                            .environmentObject(pr)
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
                        Image(systemName: "house")
                            .padding(.trailing, 5)
                        Text("Dashboard")
                    }
                }
                
                Section(header: Text("Views")) {
                    NavigationLink {
                        Today()
                            .navigationTitle("Today")
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(ce)
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
                    
//                    NavigationLink {
//                        FindDashboard()
//                            .navigationTitle("Find")
//                            .environmentObject(rm)
//                            .environmentObject(jm)
//                            .environmentObject(updater)
//                            .toolbar {
//                                Button(action: redraw, label: {
//                                    Image(systemName: "arrow.triangle.2.circlepath")
//                                })
//                                .buttonStyle(.borderless)
//                                .font(.title)
//                                .keyboardShortcut("r")
//                            }
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                            .padding(.trailing, 10)
//                        Text("Find")
//                    }
                }
                
                Section(header: Text("Entities")) {
                    NavigationLink {
                        NoteDashboard()
                            .environmentObject(jm)
                            .environmentObject(updater)
                            .navigationTitle("Notes")
                            .toolbar {
                                if showExperimentalFeatures {
                                    Button(action: {}, label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                }
                                NavigationLink {
                                    NoteCreate()
                                        .environmentObject(jm)
                                        .environmentObject(updater)
                                } label: {
                                    Image(systemName: "plus")
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
                        Image(systemName: "list.number")
                            .padding(.trailing, 10)
                        Text("Tasks")
                    }

                    NavigationLink {
                        CompanyDashboard()
                            .environmentObject(jm)
                            .environmentObject(updater)
                            .navigationTitle("Companies")
                            .toolbar {
                                if showExperimentalFeatures {
                                    Button(action: {}, label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    })
                                    .buttonStyle(.borderless)
                                    .font(.title)
                                }
                                NavigationLink {
                                    CompanyView(company: nil)
                                        .environmentObject(jm)
                                        .environmentObject(updater)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title)
                                }
                            }
                    } label: {
                        Image(systemName: "person.2")
                            .padding(.trailing, 10)
                        Text("Companies")
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
                        JobDashboard()
                            .navigationTitle("Jobs")
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
                        Image(systemName: "hammer")
                            .padding(.trailing, 10)
                        Text("Jobs")
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
                }
            }
        } detail: {
            Dashboard()
                .navigationTitle("Dashboard")
                .environmentObject(rm)
                .environmentObject(jm)
                .environmentObject(crm)
                .environmentObject(ce)
                .environmentObject(updater)
//                .environmentObject(pr)
                .toolbar {
                    Button(action: redraw, label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    })
                    .buttonStyle(.borderless)
                    .font(.title)
                    .keyboardShortcut("r")
                }
        }
        .navigationTitle("ClockWork b.\(appVersion ?? "0")")
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
