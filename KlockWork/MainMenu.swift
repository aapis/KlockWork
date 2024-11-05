//
//  File.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct MainMenu: Commands {
    @AppStorage("widgetlibrary.ui.isSidebarPresented") private var isSidebarPresented: Bool = false
    public var state: Navigation

    public var body: some Commands {
        CommandGroup(after: .newItem) {
            Menu("New...") {
                Button("Company") { self.state.to(.companyDetail) }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                Button("Person") { self.state.to(.peopleDetail) }
                    .keyboardShortcut("u", modifiers: [.command, .shift])
                Button("Project") { self.state.to(.projectDetail) }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Job") { self.state.to(.jobs) }
                    .keyboardShortcut("j", modifiers: [.command, .shift])
                Button("Note") { self.state.to(.noteDetail) }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
                Button("Task") { self.state.to(.taskDetail) }
                    .keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Record") { self.state.to(.today) }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
                Button("Definition") { self.state.to(.definitionDetail) }
                    .keyboardShortcut("d", modifiers: [.command, .shift])
            }

            Divider()
            Menu("Timeline navigation") {
                Button("Previous day") {self.state.session.date -= 86400}
                    .keyboardShortcut(.leftArrow, modifiers: [.control, .shift])
                Button("Next day") {self.state.session.date += 86400}
                    .keyboardShortcut(.rightArrow, modifiers: [.control, .shift])
                Button("Previous week") {self.state.session.date -= (86400 * 7)}
                    .keyboardShortcut(.upArrow, modifiers: [.control, .shift])
                Button("Next week") {self.state.session.date += (86400 * 7)}
                    .keyboardShortcut(.downArrow, modifiers: [.control, .shift])
                Divider()
                Button("Reset to today") {self.state.session.date = Date.now}
                    .keyboardShortcut("d", modifiers: [.control, .shift])
            }
        }

        CommandGroup(after: .sidebar) {
            Divider()
            Button("Show/hide Sidebar") { self.isSidebarPresented.toggle() }
                .keyboardShortcut("b", modifiers: [.control, .shift])
            Divider()
        }
    }
}
