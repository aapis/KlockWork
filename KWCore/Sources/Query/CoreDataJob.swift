//
//  CoreDataJob.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
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
    /// - Parameter date: The date from which we look back from
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<Job>
    static public func fetchRecent(numDaysPrior: Double = 7, from date: Date = Date(), limit: Int = 0) -> FetchRequest<Job> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Job.title?, ascending: true),
            NSSortDescriptor(keyPath: \Job.jid, ascending: true)
        ]
        let end = DateHelper.startAndEndOf(date).1
        let outerBound = DateHelper.daysPast(numDaysPrior, from: date) as CVarArg

        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && (ANY records.timestamp > %@ || created > %@ && created < %@ || lastUpdate > %@ && lastUpdate < %@) && project != nil",
            outerBound,
            outerBound,
            end as CVarArg,
            outerBound,
            end as CVarArg
        )
        fetch.sortDescriptors = descriptors

        if limit > 0 {
            fetch.fetchLimit = limit
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find a list of active jobs
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<Job>
    static public func fetchAll(limit: Int? = nil) -> FetchRequest<Job> {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && project != nil && project.alive == true && project.company.hidden == false")
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.lastUpdate, ascending: false),
            NSSortDescriptor(keyPath: \Job.title, ascending: false),
            NSSortDescriptor(keyPath: \Job.jid, ascending: false)
        ]

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find a list of active jobs that don't belong to a project yet
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<Job>
    static public func fetchUnowned(limit: Int? = nil) -> FetchRequest<Job> {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && project == nil")
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.lastUpdate, ascending: false),
            NSSortDescriptor(keyPath: \Job.title, ascending: false),
            NSSortDescriptor(keyPath: \Job.jid, ascending: false)
        ]

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find a list of commonly used Jobs
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<Job>
    static public func fetchCommon(limit: Int? = nil) -> FetchRequest<Job> {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && project != nil && project.alive == true && project.company.hidden == false")
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.lastUpdate, ascending: false),
            NSSortDescriptor(keyPath: \Job.project?.name?, ascending: false),
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
            format: "alive == true && project != nil && (ANY jid.string CONTAINS[c] %@ || ANY title CONTAINS[c] %@)",
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
            format: "alive == true && project != nil && ((created > %@ && created <= %@) || (lastUpdate > %@ && lastUpdate <= %@)) && project.company.hidden == false",
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
    
    /// Fetch Jobs belonging to a specific Project
    /// - Parameters:
    ///   - project: Project
    ///   - limit: Int
    /// - Returns: FetchedRequest<Job>?
    static public func fetch(project: Project?, limit: Int? = 10) -> FetchRequest<Job>? {
        if project == nil {
            return nil
        }

        let descriptors = [
            NSSortDescriptor(keyPath: \Job.created, ascending: true)
        ]

        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && project == %@",
            project! as CVarArg
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
    
    /// Find projects
    /// - Parameters:
    ///   - project: Project
    ///   - allowKilled: Bool(false)
    /// - Returns: Array<Job>
    public func byProject(_ project: Project, allowKilled: Bool = false) -> [Job] {
        var subpredicates: [NSPredicate] = []
        subpredicates.append(
                NSPredicate(
                format: "project == %@",
                project
            )
        )

        // Add alive check if required
        if allowKilled {
            subpredicates.append(
                NSPredicate(format: "alive == true")
            )
        }

        let filterPredicate = NSCompoundPredicate(
            type: NSCompoundPredicate.LogicalType.and,
            subpredicates: subpredicates
        )

        return self.query(filterPredicate)
    }

    public func byProject(_ project: Project) -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project = %@ && project.alive == true", project as CVarArg)

        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all jobs")
        }
        
        return all
    }
    
    /// Find jobs belonging to a given Company
    /// - Parameter company: Company
    /// - Returns: Array<Job>
    public func byCompany(_ company: Company) -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project.company == %@ && project.alive == true && project.company.alive == true", company as CVarArg)

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
    public func forDate(_ date: Date) -> [Job] {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "created > %@ && created <= %@ && project != nil",
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        return query(predicate)
    }
    
    /// Find all entities created within a date range
    /// - Parameters:
    ///   - start: Date
    ///   - end: Date
    /// - Returns: Array<NSManagedObject>
    public func inRange(start: Date?, end: Date?) -> [Job] {
        if (start == nil || end == nil) || end! < start! {
            return []
        }

        let predicate = NSPredicate(
            format: "created > %@ && created <= %@ && project != nil",
            start! as CVarArg,
            end! as CVarArg
        )

        return query(predicate)
    }

    /// Find all entities interacted with on a given date
    /// - Parameter date: Date
    /// - Returns: Array<NSManagedObject>
    public func interactionsOn(_ date: Date) -> [Job] {
        let records = CoreDataRecords(moc: self.moc!).forDate(date)
        if records.count == 0 {
            return []
        }

        var set: Set<Job> = []

        for record in records {
            if let entity = record.job {
                set.insert(entity)
            }
        }

        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "created > %@ && created <= %@ && project != nil",
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        for entity in query(predicate) {
            set.insert(entity)
        }

        return Array(set).sorted(by: {$0.lastUpdate ?? Date() < $1.lastUpdate ?? Date()})
    }

    /// Find all interactions within a certain date range
    /// - Parameter start: Date
    /// - Parameter end: Date
    /// - Returns: Array<NSManagedObject>
    public func interactionsIn(start: Date?, end: Date?) -> [Job] {
        if start != nil && end != nil {
            let records = CoreDataRecords(moc: self.moc!).inRange(start: start!, end: end!)
            if records.count == 0 {
                return []
            }

            var set: Set<Job> = []

            for record in records {
                if let entity = record.job {
                    set.insert(entity)
                }
            }

            let predicate = NSPredicate(
                format: "created > %@ && created < %@ && project != nil",
                start! as CVarArg,
                end! as CVarArg,
                start! as CVarArg,
                end! as CVarArg
            )

            for entity in query(predicate) {
                set.insert(entity)
            }

            return Array(set).sorted(by: {$0.lastUpdate ?? Date() < $1.lastUpdate ?? Date()})
        }

        return []
    }

    /// Count of all jobs created on a specific date. Used in aggregate queries, mainly.
    /// - Parameter date: Date
    /// - Returns: Array<Job>
    public func countByDate(for date: Date) -> Int {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "created > %@ && created <= %@ && project != nil",
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
                format: "(created >= %@ && created <= %@) || (lastUpdate >= %@ && lastUpdate <= %@) && project != nil",
                window.0 as CVarArg,
                window.1 as CVarArg,
                window.0 as CVarArg,
                window.1 as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "((created >= %@ && created <= %@) || (lastUpdate >= %@ && lastUpdate <= %@)) || (jid.string CONTAINS[c] %@ || title CONTAINS[c] %@) && project != nil",
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
            fetch.predicate = NSPredicate(format: "alive == true && project != nil")
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

    /// Get links from jobs created or updated on a given day
    /// - Parameter start: Optional(Date)
    /// - Parameter end: Optional(Date)
    /// - Returns: Array<Activity>
    public func getLinksFromJobs(start: Date?, end: Date?) async -> [Activity] {
        let jobs = self.inRange(
            start: start,
            end: end
        )
        var activities: [Activity] = []

        for job in jobs {
            if let uri = job.uri {
                if uri.absoluteString != "https://" {
                    activities.append(
                        Activity(
                            name: uri.absoluteString,
                            page: .dashboard, //self.state.parent ??
                            type: .activity,
                            job: job,
                            url: uri.absoluteURL
                        )
                    )
                }
            }
        }

        return activities
    }

    /// Create a new Job
    /// - Parameters:
    ///   - alive: Bool
    ///   - colour: Array<Double>
    ///   - created: Date
    ///   - jid: Double
    ///   - overview: Optional(String)
    ///   - shredable: Bool
    ///   - title: Optional(String)
    ///   - uri: String
    ///   - project: Optional(Project)
    ///   - saveByDefault: Bool(true) - Save immediately after creating the obejct, or not
    /// - Returns: Void
    public func create(alive: Bool, colour: [Double], created: Date = Date(), jid: Double, overview: String?, shredable: Bool, title: String?, uri: String, project: Project? = nil, saveByDefault: Bool = true) -> Void {
        let _ = self.make(
            alive: alive,
            colour: colour,
            jid: jid,
            overview: overview,
            shredable: shredable,
            title: title,
            uri: uri,
            project: project,
            saveByDefault: saveByDefault
        )
    }

    /// Create and return a new Job
    /// - Parameters:
    ///   - alive: Bool
    ///   - colour: Array<Double>
    ///   - created: Date
    ///   - jid: Double
    ///   - overview: Optional(String)
    ///   - shredable: Bool
    ///   - title: Optional(String)
    ///   - uri: String
    ///   - project: Optional(Project)
    ///   - saveByDefault: Bool(true) - Save immediately after creating the obejct, or not
    /// - Returns: Void
    public func createAndReturn(alive: Bool, colour: [Double], created: Date = Date(), jid: Double, overview: String?, shredable: Bool, title: String?, uri: String, project: Project? = nil, saveByDefault: Bool = true) -> Job {
        return self.make(
            alive: alive,
            colour: colour,
            jid: jid,
            overview: overview,
            shredable: shredable,
            title: title,
            uri: uri,
            project: project,
            saveByDefault: saveByDefault
        )
    }

    /// Internal method for creating jobs
    /// - Parameters:
    ///   - alive: Bool
    ///   - colour: Array<Double>
    ///   - created: Date
    ///   - jid: Double
    ///   - overview: Optional(String)
    ///   - shredable: Bool
    ///   - title: Optional(String)
    ///   - uri: String
    ///   - project: Optional(Project)
    ///   - saveByDefault: Bool(true)
    /// - Returns: Void
    private func make(alive: Bool, colour: [Double], created: Date = Date(), id: UUID = UUID(), jid: Double, lastUpdate: Date = Date(), overview: String?, shredable: Bool, title: String?, uri: String, project: Project? = nil, saveByDefault: Bool = true) -> Job {
        let newJob = Job(context: self.moc!)
        newJob.alive = alive
        newJob.colour = colour
        newJob.created = created
        newJob.id = id
        newJob.jid = jid
        newJob.lastUpdate = lastUpdate
        newJob.overview = overview
        newJob.shredable = shredable
        newJob.title = title
        newJob.uri = URL(string: uri)

        if let proj = project {
            newJob.project = proj
        }

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return newJob
    }

    private func query(_ predicate: NSPredicate, sort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Job.created?, ascending: true)]) -> [Job] {
        lock.lock()

        var results: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = sort
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
