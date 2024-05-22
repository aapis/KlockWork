//
//  CoreDataTasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public class CoreDataTasks {
    @AppStorage("today.ltd.tasks.all") public var showAllJobsInDetailsPane: Bool = false
    
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    static private var availableTasks: NSPredicate {
        NSPredicate(
            format: "completedDate == nil && cancelledDate == nil && owner.project.alive == true && owner.project.company.hidden == false"
        )
    }
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    static public func recentTasksWidgetData(limit: Int? = 1500) -> FetchRequest<LogTask> {
        let descriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \LogTask.owner?.jid, ascending: false)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.predicate = CoreDataTasks.availableTasks
        fetch.sortDescriptors = descriptors
        fetch.fetchLimit = limit!

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    public func forDate(_ date: Date, from: [LogRecord]) -> [LogTask] {
        var results: [LogTask] = []
        var filterPredicate: NSCompoundPredicate
        
        // job ID relevancy predicate
        if !showAllJobsInDetailsPane {
            // find unique job IDs in the from record set
            var ownerJobs: Set<String> = Set()
            for record in from {
                if let job = record.job {
                    ownerJobs.insert(job.jid.string)
                }
            }
            
            // create compound predicate that includes INCOMPLETE and JOBRELEVANT predicates
            let jobRelevancyPredicate = NSPredicate(format: "owner.jid IN %@ && owner.alive == true && owner.project.company.hidden == false", ownerJobs)

            filterPredicate = NSCompoundPredicate(
                type: NSCompoundPredicate.LogicalType.and,
                subpredicates: [CoreDataTasks.availableTasks, jobRelevancyPredicate]
            )
        } else {
            // create compound predicate to wrap INCOMPLETE predicate since filterPredicate must be compound
            filterPredicate = NSCompoundPredicate(
                type: NSCompoundPredicate.LogicalType.and,
                subpredicates: [CoreDataTasks.availableTasks]
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

            CoreDataRecords(moc: moc).createWithJob(
                job: task.owner!,
                date: task.lastUpdate!,
                text: "Completed task: \(task.content ?? "Invalid task")"
            )
        } catch {
            PersistenceController.shared.save()
        }
    }
    
    public func cancel(_ task: LogTask) -> Void {
        task.cancelledDate = Date()
        task.lastUpdate = Date()
        
        do {
            try moc!.save()

            CoreDataRecords(moc: moc).createWithJob(
                job: task.owner!,
                date: task.lastUpdate!,
                text: "Cancelled task: \(task.content ?? "Invalid task")"
            )
        } catch {
            PersistenceController.shared.save()
        }
    }

    public func all() -> [LogTask] {
        let predicate = NSPredicate(
            format: "created <= %@ && owner.project.company.hidden == false",
            Date() as CVarArg
        )

        return query(predicate)
    }

    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "created <= %@ && owner.project.company.hidden == false",
            Date() as CVarArg
        )

        return count(predicate)
    }
    
    /// Count of all tasks
    /// @TODO: the other countAll method needs to be renamed or deleted
    /// - Returns: Int
    public func countAllTime() -> Int {
        let predicate = NSPredicate(
            format: "owner.project.company.hidden == false"
        )

        return count(predicate)
    }

    private func query(_ predicate: NSPredicate) -> [LogTask] {
        lock.lock()

        var results: [LogTask] = []
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogTask.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataTasks.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogTask.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataTasks.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
