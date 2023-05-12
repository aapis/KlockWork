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
    @AppStorage("today.ltd.tasks.all") public var showAllJobsInDetailsPane: Bool = false
    
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func forDate(_ date: Date, from: [LogRecord]) -> [LogTask] {
        var results: [LogTask] = []
        var filterPredicate: NSCompoundPredicate

        // incomplete predicate
        let incompletePredicate = NSPredicate(format: "completedDate == null && cancelledDate == null")
        
        // job ID relevancy predicate
        if !showAllJobsInDetailsPane {
            // find unique job IDs in the from record set
            var ownerJobs: Set<String> = Set()
            for record in from {
                ownerJobs.insert(record.job!.jid.string)
            }
            
            // create compound predicate that includes INCOMPLETE and JOBRELEVANT predicates
            let jobRelevancyPredicate = NSPredicate(format: "owner.jid IN %@", ownerJobs)
            
            filterPredicate = NSCompoundPredicate(
                type: NSCompoundPredicate.LogicalType.and,
                subpredicates: [incompletePredicate, jobRelevancyPredicate]
            )
        } else {
            // create compound predicate to wrap INCOMPLETE predicate since filterPredicate must be compound
            filterPredicate = NSCompoundPredicate(
                type: NSCompoundPredicate.LogicalType.and,
                subpredicates: [incompletePredicate]
            )
        }
        
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogTask.created, ascending: false)]
        fetch.predicate = filterPredicate

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("Unable to find tasks for today")
        }
        
        return results
    }
    
    public func complete(_ task: LogTask) -> Void {
        task.completedDate = Date()
        task.lastUpdate = Date()
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }
    
    public func cancel(_ task: LogTask) -> Void {
        task.cancelledDate = Date()
        task.lastUpdate = Date()
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }
}
