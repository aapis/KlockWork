//
//  AppDelegate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

@main
struct DLPrototype: App {
    private let persistenceController = PersistenceController.shared
    @StateObject public var updater: ViewUpdater = ViewUpdater()
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var rm: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
    @State public var selected: Int = 0
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                VStack(spacing: 0) {
                    Navigation(selected: $selected)
                        .environmentObject(rm)
                        .environmentObject(jm)
                        .environmentObject(updater)
                }
                .environmentObject(rm)
                .environmentObject(jm)
                .environmentObject(updater)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } detail: {
                Text("what")
                //                    Today()
                //                        .navigationTitle("Today")
                //                    //                .toolbar {
                //                    //                    Button(action: redraw, label: {
                //                    //                        Image(systemName: "arrow.triangle.2.circlepath")
                //                    //                    })
                //                    //                    .buttonStyle(.borderless)
                //                    //                    .font(.title)
                //                    //                    .keyboardShortcut("r")
                //                    //                }
                //                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                //                        .environmentObject(updater)
                //                        .environmentObject(rm)
                //                        .environmentObject(jm)
//                                        .defaultAppStorage(.standard)
//                                        .onChange(of: scenePhase) { _ in
//                                            persistenceController.save()
//                                        }
            }
            .defaultAppStorage(.standard)
            .onChange(of: scenePhase) { _ in
                persistenceController.save()
            }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        
        // TODO: temp commented out, too early to include this
//        MenuBarExtra("name", systemImage: "keyboard.macwindow") {
//            Button("Quick Record") {
//                print("TODO: implement quick record")
//            }.keyboardShortcut("1")
//            Button("Quick Search") {
//                print("TODO: implement quick search")
//            }.keyboardShortcut("2")
//
//            Divider()
//            Button("Quit") {
//                NSApplication.shared.terminate(nil)
//            }.keyboardShortcut("q")
//        }
        #endif
    }
}
