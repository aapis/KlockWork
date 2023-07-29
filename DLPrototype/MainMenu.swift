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
    public var nav: Navigation
    
    public var body: some Commands {
        SidebarCommands()
        ToolbarCommands()
        TextEditingCommands()

        CommandGroup(replacing: .newItem) {
            Menu("New") {
                Button("Record") {
                    nav.view = AnyView(Today())
                    nav.parent = .today
                }
                    .keyboardShortcut("n", modifiers: .command)
                Button("Note") {
                    nav.view = AnyView(NoteCreate())
                    nav.parent = .today
                }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
                Button("Task") {
                    nav.view = AnyView(TaskDashboard())
                    nav.parent = .today
                }
                    .keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Project") {
                    nav.view = AnyView(ProjectCreate())
                    nav.parent = .today
                }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Job") {
                    nav.view = AnyView(JobCreate())
                    nav.parent = .jobs
                }
                    .keyboardShortcut("j", modifiers: [.command, .shift])
            }
        }
    }
}
