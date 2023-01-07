//
//  PersistenceController.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentCloudKitContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // preview notes
        for _ in 0..<10 {
            let note = Note(context: controller.container.viewContext)
            note.title = "Sample Note"
            note.postedDate = Date()
            note.body = "Some text"
            note.id = UUID()
        }
        
        // preview records
        for _ in 0..<10 {
            let record = LogRecord(context: controller.container.viewContext)
            record.timestamp = Date()
            record.message = "Lorem ipsum dolor"
            record.id = UUID()
        }
        
//        // preview jobs
//        for i in 0..<10 {
//            let job = Job(context: controller.container.viewContext)
//            job.colour = Theme.rowColourAsDouble
//            job.jid = Double(i)
//            job.id = UUID()
//        }

        return controller
    }()

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Data")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/setting_up_core_data_with_cloudkit
        // Create a store description for a local store
        let address = Bundle.main.path(forResource: "DLPrototype", ofType: ".momd")
        let localStoreLocation = URL(fileURLWithPath: "\(address!)/Default.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Default"
//        print("STORE LOCATION local: \(localStoreLocation)")
//
        // Create a store description for a CloudKit-backed local store
        let cloudStoreLocation = URL(fileURLWithPath: "\(address!)/Cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        print("CLOUD LOC: \(cloudStoreLocation)")
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Set the container options on the cloud store
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.DLPrototype.data")
        
        // Update the container's list of store descriptions
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]

        container.loadPersistentStores { description, error in
            if let error = error {
                print(error)
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    public func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
