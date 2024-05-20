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
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: KlockWorkiOSMigrationPlan.self) {
            ContentView()
        }
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
