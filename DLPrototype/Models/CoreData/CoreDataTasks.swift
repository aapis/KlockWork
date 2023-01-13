//
//  CoreDataTasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataTasks {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func forDate(_ date: Date, include: [Int]? = []) -> [LogTask] {
        var results: [LogTask] = []
        let (before, after) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogTask.created, ascending: false)]
        let datePredicate = NSPredicate(
            format: "(created > %@ && created <= %@) || (lastUpdate > %@ && lastUpdate <= %@)",
            before as CVarArg,
            after as CVarArg,
            before as CVarArg,
            after as CVarArg
        )
        
        if !include!.isEmpty {
            // TODO: this shouldn't be necessary...
            var predicateString: String = ""
            for i in 1...include!.count {
                predicateString += "ANY owner.jid.integerValue = %@"
                
                if i < include!.count {
                    predicateString += " OR "
                }
            }

            let jobPredicate = NSPredicate(format: predicateString, argumentArray: include!)
            let completedPredicate = NSPredicate(format: "completedDate == null")
            fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, completedPredicate, jobPredicate])
        } else {
            fetch.predicate = datePredicate
        }
        
        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("General Error: Unable to find tasks for date \(date.debugDescription)")
        }
        
        return results
    }
    
    public func complete(_ task: LogTask) -> Void {
        task.completedDate = Date()
        
        PersistenceController.shared.save()
    }
}
