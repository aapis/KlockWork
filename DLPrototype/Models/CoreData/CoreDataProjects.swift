//
//  CoreDataProjects.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataProjects {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func byId(_ id: Int) -> Project? {
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Project.created, ascending: false)]
        fetch.predicate = NSPredicate(
            format: "pid = %d",
            id as CVarArg
        )
        fetch.fetchLimit = 1

        do {
            var results: [Project] = []
            results = try moc!.fetch(fetch)
            
            return results.first
        } catch {
            print("Unable to find records for today")
        }
        
        return nil
    }
}
