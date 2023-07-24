//
//  File.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct MainMenu: Commands {
    public var moc: NSManagedObjectContext

//    @StateObject public var rm: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
//    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
//    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
//    @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
//    @StateObject public var updater: ViewUpdater = ViewUpdater()

    // TODO: doesn't like NSApplication.shared on boot??!
    private let currentViewName: String = ""
    
    public var body: some Commands {
        SidebarCommands()
        ToolbarCommands()
        TextEditingCommands()

//        CommandGroup(after: .newItem) {
//            Divider()
//            Button("Save") {
//                viewCanSave()
//                let currentView = window.first!.title
//                print("DERPO currentView.title \(currentView)")
//
//                if currentView == "Notes" {
//
//                }
//            }
//            .disabled(currentView == "Notes")
//            .keyboardShortcut("s", modifiers: .command)
//        }

//        CommandMenu("Entities") {
            // TODO: this doesn't fucking work
//            NavigationLink {
//                NoteDashboard()
//                    .environmentObject(jm)
//                    .environmentObject(updater)
//                    .navigationTitle("Notes")
//                    .toolbar {
//                        Button(action: {}, label: {
//                            Image(systemName: "arrow.triangle.2.circlepath")
//                        })
//                        .buttonStyle(.borderless)
//                        .font(.title)
//                    }
//            } label: {
//                Image(systemName: "note.text")
//                    .padding(.trailing, 10)
//                Text("Notes")
//            }
//            .keyboardShortcut("1", modifiers: .command)
//        }
    }

    private func viewCanSave() -> Bool {
//        if let currentView = NSApplication.shared.orderedWindows.first {
//            if let nsView = currentView.contentView {
//                let view = nsView as View // doesn't work
//
//                print("DERPO view \(view)")
//                return true
//            }
//        }

        return false
    }
}
