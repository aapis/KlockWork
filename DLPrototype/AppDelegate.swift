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
struct AppDelegate: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        MenuBarExtra("name", systemImage: "keyboard.macwindow") {
            Button("Quick Record") {
                print("TODO: implement quick record")
            }.keyboardShortcut("1")
            Button("Quick Search") {
                print("TODO: implement quick search")
            }.keyboardShortcut("2")
            
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}
