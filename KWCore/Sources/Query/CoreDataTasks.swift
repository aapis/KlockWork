//
//  CoreDataTasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore
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

    /// Find all active tasks that have been updated within the last week
    /// - Parameter numDaysPrior: How far back to look, 7 days by default
    /// - Returns: FetchRequest<LogTask>
    static public func fetchRecent(numDaysPrior: Double = 7) -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.created, ascending: true)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "completedDate == nil && cancelledDate == nil && owner.project.alive == true && lastUpdate >= %@",
            DateHelper.daysPast(numDaysPrior) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find tasks whose content matches a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<LogTask>
    static public func fetchMatching(term: String) -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.created, ascending: true)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "completedDate == nil && cancelledDate == nil && ANY content CONTAINS[c] %@",
            term
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all objects created on a given date
    /// - Parameters:
    ///   - date: Date
    ///   - limit: Int, 10 by default
    ///   - daysPrior: Int, 7 by default
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(for date: Date, limit: Int? = 10, daysPrior: Int = 7) -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.owner?.title?, ascending: true),
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        var predicate: NSPredicate
        let (start, end) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        if let rangeStart = DateHelper.prior(numDays: daysPrior, from: start).last {
            predicate = NSPredicate(
                format: "((created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@) || (due > %@ && due < %@)) && completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false",
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "((created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@) || (due > %@ && due < %@)) && completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false",
                start as CVarArg,
                end as CVarArg,
                start as CVarArg,
                end as CVarArg,
                start as CVarArg,
                end as CVarArg,
                start as CVarArg,
                end as CVarArg
            )
        }

        fetch.predicate = predicate
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find all objects associated with the given job
    /// - Parameter job: Job
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(by job: Job) -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "completedDate == nil && cancelledDate == nil && owner == %@ && owner.project.company.hidden == false",
            job
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all upcoming tasks
    /// - Parameter date: Date
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetchUpcoming(_ date: Date = Date()) -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "due > %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
            date as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all upcoming tasks
    /// - Parameter date: Date
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetchDue(on date: Date = Date()) -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "due > %@ && due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
            date as CVarArg,
            (DateHelper.endOfDay(date) ?? date) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all overdue tasks
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetchOverdue() -> FetchRequest<LogTask> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        let now = Date()
        fetch.predicate = NSPredicate(
            format: "due < %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
            now as CVarArg
        )
        fetch.sortDescriptors = descriptors

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
        task.hasScheduledNotification = false
        NotificationHelper.clean(identifier: task.id?.uuidString ?? "no-id")

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
    
    /// Delay a task to a specific day
    /// - Parameters:
    ///   - task: LogTask
    ///   - date: Date
    /// - Returns: Void
    public func delay(_ task: LogTask, to date: Date? = nil) -> Void {
        if let due = task.due {
            if let delayTargetDate = date {
                self.due(on: delayTargetDate, task: task)
            } else if let newDate = DateHelper.endOfTomorrow(due) {
                self.due(on: newDate, task: task)
            }
        }
    }

    public func cancel(_ task: LogTask) -> Void {
        task.cancelledDate = Date()
        task.lastUpdate = Date()
        task.hasScheduledNotification = false
        NotificationHelper.clean(identifier: task.id?.uuidString ?? "no-id")

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
    
    /// Set task due date and save
    /// - Parameters:
    ///   - date: Date
    ///   - task: LogTask
    /// - Returns: Void
    public func due(on date: Date, task: LogTask) -> Void {
        task.due = date
        task.hasScheduledNotification = true

        do {
            try moc!.save()

            CoreDataRecords(moc: moc).createWithJob(
                job: task.owner!,
                date: Date(),
                text: "Delayed task: \(task.content ?? "Invalid task") to \(date.formatted(date: .abbreviated, time: .omitted))"
            )
        } catch {
            PersistenceController.shared.save()
        }
    }

    /// Find overdue tasks
    /// - Returns: Array<LogTask>
    public func overdue(_ date: Date = Date()) -> [LogTask] {
        let predicate = NSPredicate(
            format: "due < %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
            date as CVarArg
        )
        let sort = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        return query(predicate, sort)
    }

    /// Find tasks that have no due date
    /// - Returns: Array<LogTask>
    public func noDueDate() -> [LogTask] {
        let predicate = NSPredicate(
            format: "due == nil && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)"
        )
        let sort = [
            NSSortDescriptor(keyPath: \LogTask.owner?.title, ascending: true)
        ]

        return query(predicate, sort)
    }

    /// Find upcoming tasks
    /// - Returns: Array<LogTask>
    public func upcoming(_ date: Date = Date()) -> [LogTask] {
        let predicate = NSPredicate(
            format: "due > %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
            date as CVarArg
        )
        let sort = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        return query(predicate, sort)
    }

    /// Find upcoming tasks by their scheduled notification status
    /// - Returns: Array<LogTask>
    public func upcoming(_ date: Date = Date(), hasScheduledNotification: Bool) -> [LogTask] {
        var predicate: NSPredicate

        if hasScheduledNotification {
            predicate = NSPredicate(
                format: "due > %@ && hasScheduledNotification == true && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                date as CVarArg,
                hasScheduledNotification as NSNumber
            )
        } else {
            predicate = NSPredicate(
                format: "due > %@ && hasScheduledNotification == false && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                date as CVarArg,
                hasScheduledNotification as NSNumber
            )
        }

        let sort = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        return query(predicate, sort)
    }
    
    /// Find jobs for the tasks which are due today. Used to overwrite AppState.planning.jobs
    /// - Parameter date: Date
    /// - Returns: Set<Job>
    public func jobsForTasksDueToday(_ date: Date = Date.now) -> Set<Job> {
        let suggested = CoreDataTasks(moc: self.moc!).dueToday(date)
        var sJobs: Set<Job> = []

        if !suggested.isEmpty {
            for task in suggested {
                if let job = task.owner {
                    sJobs.insert(job)
                }
            }
        }

        return sJobs
    }

    /// Find tasks due today
    /// - Returns: Array<LogTask>
    public func dueToday(_ date: Date = Date()) -> [LogTask] {
        let predicate = NSPredicate(
            format: "due > %@ && due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
            date as CVarArg,
            (DateHelper.endOfDay(date) ?? date) as CVarArg
        )
        let sort = [
            NSSortDescriptor(keyPath: \LogTask.due, ascending: true)
        ]

        return query(predicate, sort)
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

    /// Finds notes created or updated on a specific date, that aren't hidden by their parent
    /// - Parameter date: Date
    /// - Returns: Array<LogTask>
    public func find(for date: Date) -> [LogTask] {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "(completedDate > %@ && completedDate <= %@) || (lastUpdate > %@ && lastUpdate <= %@)",
            window.0 as CVarArg,
            window.1 as CVarArg,
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        return query(predicate)
    }

    /// Count up all the jobs referenced for a given day
    /// - Parameter date: Date
    /// - Returns: Int
    public func countByDate(for date: Date) -> Int {
        return self.find(for: date).count
    }

    /// Find all entities created within a date range
    /// - Parameters:
    ///   - start: Date
    ///   - end: Date
    /// - Returns: Array<NSManagedObjedct>
    public func inRange(start: Date?, end: Date?) -> [LogTask] {
        if (start == nil || end == nil) || end! < start! {
            return []
        }

        let predicate = NSPredicate(
            format: "owner != nil && completedDate == nil && cancelledDate == nil && ((due > %@ && due <= %@) || (created > %@ && created <= %@) || (lastUpdate > %@ && lastUpdate <= %@))",
            start! as CVarArg,
            end! as CVarArg,
            start! as CVarArg,
            end! as CVarArg,
            start! as CVarArg,
            end! as CVarArg
        )

        return query(predicate)
    }

    /// Find links added to tasks created on this day
    /// - Parameter start: Optional(Date)
    /// - Parameter end: Optional(Date)
    /// - Returns: Array<Activity>
    public func links(start: Date?, end: Date?) async -> [Activity] {
        var activities: [Activity] = []
        if start != nil && end != nil {
            let tasks = CoreDataTasks(moc: self.moc!).inRange(
                start: start,
                end: end
            )
            let linkLength = 40

            for task in tasks {
                if task.uri != nil {
                    if let content = task.uri {
                        var label: String = content.absoluteString
                        if label.count > linkLength {
                            label = label.prefix(linkLength) + "..."
                        }

                        if !activities.contains(where: {$0.name == label}) {
                            activities.append(
                                Activity(
                                    name: label,
                                    help: content.absoluteString,
                                    page: .tasks,
                                    type: .activity,
                                    job: task.owner,
                                    source: task,
                                    url: content
                                )
                            )
                        }
                    }
                }
            }
        }

        return activities
    }

    /// Public method to create new LogTask objects
    /// - Parameters:
    ///   - cancelledDate: Date
    ///   - completedDate: Date
    ///   - content: String
    ///   - created: Date
    ///   - due: Date
    ///   - lastUpdate: Date
    ///   - job: Job
    ///   - url: Optional(String)
    ///   - saveByDefault: Bool
    /// - Returns: LogTask
    public func create(cancelledDate: Date? = nil, completedDate: Date? = nil, content: String, created: Date, due: Date, lastUpdate: Date? = Date(), job: Job? = nil, url: String? = nil, saveByDefault: Bool = true) -> Void {
        let _ = self.make(cancelledDate: cancelledDate, completedDate: completedDate, content: content, created: created, due: due, lastUpdate: lastUpdate, job: job, url: url, saveByDefault: saveByDefault)
    }

    /// Public method to create new LogTask objects
    /// - Parameters:
    ///   - cancelledDate: Date
    ///   - completedDate: Date
    ///   - content: String
    ///   - created: Date
    ///   - due: Date
    ///   - lastUpdate: Date
    ///   - job: Job
    ///   - url: Optional(String)
    ///   - saveByDefault: Bool
    /// - Returns: LogTask
    public func createAndReturn(cancelledDate: Date? = nil, completedDate: Date? = nil, content: String, created: Date, due: Date, lastUpdate: Date? = Date(), job: Job? = nil, url: String? = nil, saveByDefault: Bool = true) -> LogTask {
        return self.make(cancelledDate: cancelledDate, completedDate: completedDate, content: content, created: created, due: due, lastUpdate: lastUpdate, job: job, url: url, saveByDefault: saveByDefault)
    }

    /// Internal method to create new LogTask objects
    /// - Parameters:
    ///   - cancelledDate: Date
    ///   - completedDate: Date
    ///   - content: String
    ///   - created: Date
    ///   - lastUpdate: Date
    ///   - due: Date
    ///   - job: Job
    ///   - url: Optional(String)
    ///   - saveByDefault: Bool
    /// - Returns: LogTask
    private func make(cancelledDate: Date? = nil, completedDate: Date? = nil, content: String, created: Date, due: Date, lastUpdate: Date? = Date(), job: Job?, url: String? = nil, saveByDefault: Bool = true) -> LogTask {
        let newTask = LogTask(context: self.moc!)
        newTask.cancelledDate = cancelledDate
        newTask.completedDate = completedDate
        newTask.content = content
        newTask.created = created
        newTask.id = UUID()
        newTask.lastUpdate = Date()
        newTask.due = due

        if job != nil {
            newTask.owner = job!
        }

        if url != nil {
            if let uri = URL(string: url!) {
                newTask.uri = uri
            }
        }

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return newTask
    }

    private func query(_ predicate: NSPredicate, _ sort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \LogTask.created?, ascending: false)]) -> [LogTask] {
        var results: [LogTask] = []
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.sortDescriptors = sort
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true
        fetch.returnsObjectsAsFaults = false

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataTasks.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        var count = 0
        let fetch: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogTask.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true
        fetch.returnsObjectsAsFaults = false

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataTasks.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        return count
    }
}
