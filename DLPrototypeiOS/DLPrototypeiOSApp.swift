//
//  DLPrototypeiOSApp.swift
//  DLPrototypeiOS
//
//  Created by Ryan Priebe on 2020-11-14.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

@main
struct DLPrototypeiOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
