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
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(updater)
                .onChange(of: scenePhase) { _ in
                    persistenceController.save()
                }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
