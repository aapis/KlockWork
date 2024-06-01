//
//  CoreDataJob.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import CoreData

public class CoreDataJob: ObservableObject {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    static public func recentJobsWidgetData() -> FetchRequest<Job> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Job.lastUpdate?, ascending: false)
        ]

        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && lastUpdate != nil && project != nil && project.company.hidden == false")
        fetch.sortDescriptors = descriptors
        fetch.fetchLimit = 10

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all active jobs that have been updated within the last week
    /// - Parameter numDaysPrior: How far back to look, 7 days by default
    /// - Returns: FetchRequest<Job>
    static public func fetchRecent(numDaysPrior: Double = 7, from date: Date = Date()) -> FetchRequest<Job> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Job.jid, ascending: true)
        ]

        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive = true && ANY records.timestamp >= %@",
            DateHelper.daysPast(numDaysPrior, from: date) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find a list of active jobs
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<Job>
    static public func fetchAll(limit: Int? = nil) -> FetchRequest<Job> {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && project != nil && project.alive == true && project.company.hidden == false")
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.project?, ascending: false),
            NSSortDescriptor(keyPath: \Job.jid, ascending: false)
        ]

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find jobs whose JID or title fields match a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<Job>
    static public func fetchMatching(term: String) -> FetchRequest<Job> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Job.jid, ascending: true)
        ]

        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && (ANY jid.string CONTAINS[c] %@ || ANY title CONTAINS[c] %@)",
            term,
            term
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all objects created on a given date
    /// - Parameters:
    ///   - date: Date
    ///   - limit: Int, 10 by default
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(for date: Date, limit: Int? = 10) -> FetchRequest<Job> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Job.created, ascending: true)
        ]

        let (start, end) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && ((created > %@ && created <= %@) || (lastUpdate > %@ && lastUpdate <= %@)) && project.company.hidden == false",
            start as CVarArg,
            end as CVarArg,
            start as CVarArg,
            end as CVarArg
        )
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    public func getRecentlyUsed(records: FetchedResults<LogRecord>) -> [Job] {
        var jobs: Set<Job> = []

        for rec in records {
            if let job = rec.job {
                if job.project != nil {
                    jobs.insert(job)
                }
            }
        }

        return jobs.sorted {$0.project!.pid > $1.project!.pid}
    }
    
    public func getDefault() -> Job? {
        if let job = byId(11.0) {
            return job
        }
        
        return nil
    }
    
    public func byId(_ id: Double) -> Job? {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "jid = %d", Int(id))
        fetch.fetchLimit = 1
        
        do {
            let results = try moc!.fetch(fetch)
            
            return results.first
        } catch {
            print("General Error: Unable to find task with ID \(id)")
        }
        
        return nil
    }

    public func byUrl(_ url: URL) -> Job? {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "uri = %@", url as CVarArg)
        fetch.fetchLimit = 1

        do {
            let results = try moc!.fetch(fetch)

            return results.first
        } catch {
            print("General Error: Unable to find task with URL \(url)")
        }

        return nil
    }
    
    public func byProject(_ projectId: UUID) -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project.id = %@ && project.alive == true", projectId.uuidString)

        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all jobs")
        }
        
        return all
    }
    
    /// Find all jobs created on a specific date. Used in aggregate queries, mainly.
    /// - Parameter date: Date
    /// - Returns: Array<Job>
    public func byDate(_ date: Date) -> [Job] {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "created >= %@ && created <= %@",
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        return query(predicate)
    }

    /// Count of all jobs created on a specific date. Used in aggregate queries, mainly.
    /// - Parameter date: Date
    /// - Returns: Array<Job>
    public func countByDate(for date: Date) -> Int {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "created >= %@ && created <= %@",
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        return count(predicate)
    }

    /// Count of all jobs created on a specific date. Used in aggregate queries, mainly.
    /// - Parameter date: Date
    /// - Parameter term: String
    /// - Returns: Array<Job>
    public func countByDateOrTerm(date: Date, term: String) -> Int {
        let window = DateHelper.startAndEndOf(date)
        var predicate: NSPredicate

        if term.isEmpty {
            predicate = NSPredicate(
                format: "(created >= %@ && created <= %@) || (lastUpdate >= %@ && lastUpdate <= %@)",
                window.0 as CVarArg,
                window.1 as CVarArg,
                window.0 as CVarArg,
                window.1 as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "((created >= %@ && created <= %@) || (lastUpdate >= %@ && lastUpdate <= %@)) || (jid.string CONTAINS[c] %@ || title CONTAINS[c] %@)",
                window.0 as CVarArg,
                window.1 as CVarArg,
                window.0 as CVarArg,
                window.1 as CVarArg,
                term,
                term
            )
        }


        return count(predicate)
    }

    public func all(_ stillAlive: Bool? = true, fetchLimit: Int? = nil, resultLimit: Int? = nil) -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        
        if let lim = fetchLimit {
            fetch.fetchLimit = lim
        }
        
        if stillAlive! {
            fetch.predicate = NSPredicate(format: "alive == true")
        }
        
        do {
            all = try moc!.fetch(fetch)
            
            if let resLim = resultLimit {
                all = Array(all.prefix(upTo: resLim))
            }
        } catch {
            print("Couldn't retrieve all jobs")
        }
        
        return all
    }
    
    public func startsWith(_ id: String) -> [Job] {
        return self.all().filter {$0.alive == true && $0.jid.string.starts(with: id)}
    }
    
    public func owned() -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project != nil")
        
        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all owned jobs")
        }
        
        return all
    }
    
    public func unowned() -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project = nil")
        
        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all unowned jobs")
        }
        
        return all
    }

    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "alive == true"
        )

        return count(predicate)
    }

    private func query(_ predicate: NSPredicate) -> [Job] {
        lock.lock()

        var results: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataJob.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataJob.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
