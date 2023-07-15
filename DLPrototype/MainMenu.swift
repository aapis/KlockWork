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

    public var body: some Commands {
        SidebarCommands()
        ToolbarCommands()
        TextEditingCommands()

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
}
