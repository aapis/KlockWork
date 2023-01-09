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
    @StateObject public var records: Records = Records()
    private let persistenceController = PersistenceController.shared
    @StateObject public var recordsModel: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Home(records: records)
//                .onAppear(perform: {
                    // TODO: Legacy api, remove!
//                    records.reload()
//                })
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(recordsModel)
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
