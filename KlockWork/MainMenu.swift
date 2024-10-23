//
//  File.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct MainMenu: Commands {
    public var moc: NSManagedObjectContext
    public var nav: Navigation

    public var body: some Commands {
        SidebarCommands()
        ToolbarCommands()
        TextEditingCommands()

        CommandGroup(after: .newItem) {
            Menu("New...") {
                Button("Company") { self.nav.to(.companyDetail) }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                Button("Person") { self.nav.to(.peopleDetail) }
                    .keyboardShortcut("u", modifiers: [.command, .shift])
                Button("Project") { self.nav.to(.projectDetail) }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Job") { self.nav.to(.jobs) }
                    .keyboardShortcut("j", modifiers: [.command, .shift])
                Button("Note") { self.nav.to(.noteDetail) }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
                Button("Task") { self.nav.to(.taskDetail) }
                    .keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Record") { self.nav.to(.today) }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
                Button("Definition") { self.nav.to(.definitionDetail) }
                    .keyboardShortcut("d", modifiers: [.command, .shift])
            }

            Divider()
            Menu("Timeline navigation") {
                Button("Previous day") {nav.session.date -= 86400}
                    .keyboardShortcut(.leftArrow, modifiers: [.control, .shift])
                Button("Next day") {nav.session.date += 86400}
                    .keyboardShortcut(.rightArrow, modifiers: [.control, .shift])
                Divider()
                Button("Reset to today") {nav.session.date = Date()}
                    .keyboardShortcut("d", modifiers: [.control, .shift])
            }
        }
    }
}
