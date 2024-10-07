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
                Button("Record") {
                    nav.view = AnyView(Today())
                    nav.parent = .today
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                Button("Note") {
                    nav.view = AnyView(NoteCreate())
                    nav.parent = .notes
                }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
                Button("Task") {
                    nav.view = AnyView(TaskDetail())
                    nav.parent = .tasks
                }
                    .keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Project") {
                    nav.view = AnyView(ProjectCreate())
                    nav.parent = .companies
                }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Company") {
                    nav.view = AnyView(CompanyCreate())
                    nav.parent = .companies
                }
                    .keyboardShortcut("c", modifiers: [.command, .shift])
                Button("Job") {
                    nav.view = AnyView(JobCreate())
                    nav.parent = .jobs
                }
                    .keyboardShortcut("j", modifiers: [.command, .shift])
            }

            Divider()
            Menu("Timeline navigation") {
                Button("Previous day") {nav.session.date -= 86400}
                    .keyboardShortcut(.leftArrow, modifiers: [.command, .shift])
                Button("Next day") {nav.session.date += 86400}
                    .keyboardShortcut(.rightArrow, modifiers: [.command, .shift])
                Divider()
                Button("Reset to today") {nav.session.date = Date()}
                    .keyboardShortcut("d", modifiers: [.command, .shift])
            }
        }
    }
}
