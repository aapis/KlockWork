//
//  Navigation.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct MainNavigationTab: View {
    public var name: String
    public var icon: String
    public var destination: AnyView?
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var rm: LogRecords
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        NavigationLink {
            destination
                .navigationTitle(name)
                .environmentObject(rm)
                .environmentObject(jm)
                .environmentObject(updater)
                .environment(\.managedObjectContext, moc)
                .toolbar {
                    Button(action: redraw, label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    })
                    .buttonStyle(.borderless)
                    .font(.title)
                    .keyboardShortcut("r")
                }
        } label: {
            ZStack {
                Color.clear
                
                HStack(spacing: 0) {
                    Image(systemName: icon)
                        .padding([.leading, .trailing], 15)
                        .font(.title)
                        .help(name)
                    Text(name)
                    Divider()
                        .foregroundColor(Color.white.opacity(0.2))
                }
            }
            
        }
        .background(Theme.toolbarColour)
        .buttonStyle(.borderless)
        .padding(0)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
    
    private func redraw() -> Void {
        updater.update()
    }
}

struct Navigation: View {
    @Binding public var selected: Int
    
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var rm: LogRecords
    @EnvironmentObject public var jm: CoreDataJob
    
    @State public var appVersion: String?
    @State public var splitDirection: Bool = false // false == horizontal, true == vertical
    
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
//                    NavigationLink {
//                        Today()
//                            .navigationTitle("Today")
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
//                        Image(systemName: "doc.append.fill")
//                            .padding(.trailing, 10)
//                            .font(.title)
//                        Text("Today")
//
//                    }
//                    .buttonStyle(.borderless)
                    MainNavigationTab(name: "Today", icon: "doc.append.fill", destination: AnyView(Today()))
                        .environmentObject(rm)
                        .environmentObject(jm)
                        .environmentObject(updater)
                    MainNavigationTab(name: "Notes", icon: "note.text", destination: AnyView(NoteDashboard()))
                        .environmentObject(rm)
                        .environmentObject(jm)
                        .environmentObject(updater)
                    MainNavigationTab(name: "Tasks", icon: "list.number", destination: AnyView(TaskDashboard()))
                        .environmentObject(rm)
                        .environmentObject(jm)
                        .environmentObject(updater)
                    MainNavigationTab(name: "Projects", icon: "folder", destination: AnyView(ProjectsDashboard()))
                        .environmentObject(rm)
                        .environmentObject(jm)
                        .environmentObject(updater)
                    MainNavigationTab(name: "In + Out", icon: "square.and.arrow.up.fill", destination: AnyView(Import()))
                        .environmentObject(rm)
                        .environmentObject(jm)
                        .environmentObject(updater)
                    
                    if showExperimentalFeatures {
                        Spacer()
                        MainNavigationTab(name: "Multitasking", icon: "rectangle.split.2x1", destination: AnyView(Split(direction: $splitDirection)))
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(updater)
                        MainNavigationTab(name: "Manage", icon: "books.vertical", destination: AnyView(Manage()))
                            .environmentObject(rm)
                            .environmentObject(jm)
                            .environmentObject(updater)
//                        MainNavigationTab(name: "In + Out", icon: "square.and.arrow.up.fill", destination: AnyView(Import()))
//                        MainNavigationTab(name: "In + Out", icon: "square.and.arrow.up.fill", destination: AnyView(Import()))
                    }
                    
//                    NavigationLink {
//                        NoteDashboard()
//                            .navigationTitle("Notes")
//                            .toolbar {
//                                if showExperimentalFeatures {
//                                    Button(action: {}, label: {
//                                        Image(systemName: "arrow.triangle.2.circlepath")
//                                    })
//                                    .buttonStyle(.borderless)
//                                    .font(.title)
//                                }
//                            }
//                    } label: {
//                        Image(systemName: "note.text")
//                            .padding(.trailing, 10)
//                            .font(.title)
//                    }
//
//                    NavigationLink {
//                        TaskDashboard()
//                            .navigationTitle("Tasks")
//                            .environmentObject(rm)
//                            .environmentObject(updater)
//                            .toolbar {
//                                if showExperimentalFeatures {
//                                    Button(action: {}, label: {
//                                        Image(systemName: "arrow.triangle.2.circlepath")
//                                    })
//                                    .buttonStyle(.borderless)
//                                    .font(.title)
//                                }
//                            }
//                    } label: {
//                        Image(systemName: "list.number")
//                            .padding(.trailing, 10)
//                            .font(.title)
//                    }
                    
//                    NavigationLink {
//                        ProjectsDashboard()
//                            .navigationTitle("Projects")
//                            .environmentObject(rm)
//                            .environmentObject(jm)
//                            .environmentObject(updater)
//                            .toolbar {
//                                if showExperimentalFeatures {
//                                    Button(action: {}, label: {
//                                        Image(systemName: "arrow.triangle.2.circlepath")
//                                    })
//                                    .buttonStyle(.borderless)
//                                    .font(.title)
//                                }
//                            }
//                    } label: {
//                        Image(systemName: "folder")
//                            .padding(.trailing, 10)
//                            .font(.title)
//                    }
                    
//                    NavigationLink {
//                        Import()
//                            .navigationTitle("Import")
//                            .environmentObject(rm)
//                            .toolbar {
//                                if showExperimentalFeatures {
//                                    Button(action: {}, label: {
//                                        Image(systemName: "arrow.triangle.2.circlepath")
//                                    })
//                                    .buttonStyle(.borderless)
//                                    .font(.title)
//                                }
//                            }
//                    } label: {
//                        Image(systemName: "square.and.arrow.up.fill")
//                            .padding(.trailing, 10)
//                            .font(.title)
//                    }
                    
//                    if showExperimentalFeatures {
//                        Divider()
//
//                        NavigationLink {
//                            Split(direction: $splitDirection)
//                                .navigationTitle("Multitasking")
//                                .environmentObject(rm)
//                                .toolbar {
//                                    Button(action: setSplitViewDirection, label: {
//                                        if !splitDirection {
//                                            Image(systemName: "rectangle.split.1x2")
//                                        } else {
//                                            Image(systemName: "rectangle.split.2x1")
//                                        }
//                                    })
//                                    .buttonStyle(.borderless)
//                                    .font(.title)
//
//                                    if showExperimentalFeatures {
//                                        Button(action: {}, label: {
//                                            Image(systemName: "arrow.triangle.2.circlepath")
//                                        })
//                                        .buttonStyle(.borderless)
//                                        .font(.title)
//                                    }
//                                }
//                        } label: {
//                            Image(systemName: "rectangle.split.2x1")
//                                .padding(.trailing, 10)
//                                .font(.title)
//                        }
                        
//                        NavigationLink {
//                            Manage()
//                                .navigationTitle("Manage")
//                                .toolbar {
//                                    if showExperimentalFeatures {
//                                        Button(action: {}, label: {
//                                            Image(systemName: "arrow.triangle.2.circlepath")
//                                        })
//                                        .buttonStyle(.borderless)
//                                        .font(.title)
//                                    }
//                                }
//                        } label: {
//                            Image(systemName: "books.vertical")
//                                .padding(.trailing, 10)
//                                .font(.title)
//                        }
                        
//                        NavigationLink {
//                            CalendarView()
//                                .navigationTitle("Calendar")
//                        } label: {
//                            Image(systemName: "calendar")
//                                .padding(.trailing, 10)
//                                .font(.title)
//                        }
//
//
//                        NavigationLink {
//                            Backup(category: Category(title: "Daily"))
//                                .navigationTitle("Backup")
//                        } label: {
//                            Image(systemName: "cloud.fill")
//                                .padding(.trailing, 10)
//                                .font(.title)
//                        }
//                    }
                }
            }
//            Spacer()
            Divider()
                .foregroundColor(Color.black.opacity(0.6))
        }
        .background(Color.black.opacity(0.1))
        
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
