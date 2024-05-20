//
//  KlockWorkiOSApp.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-18.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct KlockWorkiOSApp: App {
    private let persistenceController = PersistenceController.shared
    
    @State private var items: [Note] = []

    var body: some Scene {
        WindowGroup {
            ContentView(items: $items)
                .onAppear(perform: {
                    items = CoreDataNotes(moc: persistenceController.container.viewContext).alive()
                })
        }
    }
}

extension Double {
    var string: String {
        return self.formatted()
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct KlockWorkiOSMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        KlockWorkiOSVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct KlockWorkiOSVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
