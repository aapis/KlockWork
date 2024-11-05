//
//  CoreDataProjects.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreData

public class CoreDataProjects: ObservableObject {
    /// Context for updating CD objects
    public var moc: NSManagedObjectContext?

    /// Thread lock
    private let lock = NSLock()

    /// Create new CoreDataProjects instance
    /// - Parameter moc: NSManagedObjectContext
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    /// Fetch request to find recent projects
    /// - Returns: FetchRequest<Project>
    static public func fetchAll() -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && name != \"Unassigned jobs\"")
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Fetch request to find unowned projects
    /// - Returns: FetchRequest<Project>
    static public func fetchUnowned() -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && name != \"Unassigned jobs\" && company == nil")
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Fetch request to find recent projects
    /// - Parameter numDaysPrior: How far back to look, 7 days by default
    /// - Returns: FetchRequest<Project>
    static public func fetchProjects(numDaysPrior: Double = 7) -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.lastUpdate?, ascending: false)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && name != \"Unassigned jobs\" && lastUpdate >= %@",
            DateHelper.daysPast(numDaysPrior) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find notes whose title or content fields match a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<Project>
    static public func fetchMatching(term: String) -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && (ANY name CONTAINS[c] %@ || ANY company.name CONTAINS[c] %@)",
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
    ///   - daysPrior: Int, 7 by default
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(for date: Date, limit: Int? = 10, daysPrior: Int = 7) -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.company?.name, ascending: true),
            NSSortDescriptor(keyPath: \Project.created, ascending: true)
        ]

        var predicate: NSPredicate
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        let (start, end) = DateHelper.startAndEndOf(date)
        if let rangeStart = DateHelper.prior(numDays: daysPrior, from: start).last {
            predicate = NSPredicate(
                format: "alive == true && ((created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@))",
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "alive == true && ((created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@))",
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

    /// Find all objects for a given company
    /// - Parameters:
    ///   - date: Date
    ///   - limit: Int, 10 by default
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(by company: Company, limit: Int? = 10) -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.company?.name, ascending: true),
            NSSortDescriptor(keyPath: \Project.created, ascending: true)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && company == %@",
            company as CVarArg
        )

        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find project by ID
    /// - Parameter id: PID value to search for
    /// - Returns: Project|nil
    public func byId(_ id: Int64) -> Project? {
        let predicate = NSPredicate(
            format: "pid = %d",
            id as CVarArg
        )
        
        let results = query(predicate)
        
        if results.isEmpty {
            return nil
        }
        
        return results.first
    }

    /// Find projects by company PID
    /// - Parameter id: Company PID
    /// - Returns: Array<Project>
    public func byCompany(_ company: Company, allowKilled: Bool = false) -> [Project] {
        var subpredicates: [NSPredicate] = []
        subpredicates.append(
                NSPredicate(
                format: "company == %@",
                company
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

        return query(filterPredicate)
    }

    /// Find projects whose name matches the term
    /// - Parameter term: Search term
    /// - Returns: Array<Project>
    public func anyName(_ term: String) -> [Project] {
        let predicate = NSPredicate(
            format: "name = %@",
            term
        )

        return query(predicate)
    }

    /// Find a specific project by name
    /// - Parameter term: Search term
    /// - Returns: Project|nil
    public func byName(_ term: String) -> Project? {
        let predicate = NSPredicate(
            format: "name = %@",
            term
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// Find projects by UUID (aka, by id)
    /// - Parameter term: A project's UUID
    /// - Returns: Optional(Project)
    public func byUuid(_ term: UUID) -> Project? {
        let predicate = NSPredicate(
            format: "name = %@",
            term.uuidString
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// Find projects by company PID
    /// - Parameter id: Company PID
    /// - Returns: Array<Project>
    public func byOwnership(isOwned: Bool) -> [Project] {
        var predicate = NSPredicate(
            format: "alive == true && company == nil"
        )

        if isOwned {
            predicate = NSPredicate(
                format: "alive == true && company != nil"
            )
        }

        return query(predicate)
    }

    /// Find all projects
    /// - Returns: Array<Project>
    public func all() -> [Project] {
        return query()
    }

    /// Find all alive/active projects
    /// - Returns: Array<Project>
    public func alive() -> [Project] {
        let predicate = NSPredicate(
            format: "alive == true"
        )
        let sortOptions = [
            NSSortDescriptor(keyPath: \Project.company?.isDefault, ascending: false),
            NSSortDescriptor(keyPath: \Project.company?.name, ascending: true),
            NSSortDescriptor(keyPath: \Project.name, ascending: true),
        ]

        return query(predicate, sort: sortOptions)
    }

    /// Find recently used projects
    /// - Parameter numWeeks: Number of weeks in the past to search
    /// - Returns: Array<Project>
    public func recent(_ numWeeks: Double = 2) -> [Project] {
        var results: [Project] = []
        let records = CoreDataRecords(moc: moc!).recent(numWeeks)
        
        for rec in records {
            if rec.job != nil {
                if let project = rec.job!.project {
                    if !results.contains(where: {($0.id == project.id)}) {
                        results.append(project)
                    }
                }
            }
        }
        
        return results
    }

    /// Count all living projects
    /// - Returns: Int
    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "alive == true"
        )

        return count(predicate)
    }

    /// Finds people created or updated on a given day
    /// - Parameter date: Date
    /// - Returns: Array<Project>
    public func forDate(_ date: Date) -> [Project] {
        let (before, after) = DateHelper.startAndEndOf(date)
        return self.query(
            NSPredicate(
                format: "(created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@)",
                after as CVarArg,
                before as CVarArg,
                after as CVarArg,
                before as CVarArg
            )
        )
    }

    /// Find all entities interacted with on a given date
    /// - Parameter date: Date
    /// - Returns: Array<NSManagedObject>
    public func interactionsOn(_ date: Date) -> [Project] {
        let records = CoreDataRecords(moc: self.moc!).forDate(date)
        if records.count == 0 {
            return []
        }

        var set: Set<Project> = []

        for record in records {
            if let entity = record.job?.project {
                set.insert(entity)
            }
        }

        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "(created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@)",
            window.0 as CVarArg,
            window.1 as CVarArg,
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        for entity in query(predicate) {
            set.insert(entity)
        }

        return Array(set).sorted(by: {$0.lastUpdate ?? Date() > $1.lastUpdate ?? Date()})
    }

    /// Find all projects that have a name and are not hidden
    /// - Returns: Array<Project>
    public func indescriminate() -> [Project] {
        let predicate = NSPredicate(
            format: "name != nil && company.hidden == false"
        )

        return query(predicate)
    }

    /// Create a new project
    /// - Parameters:
    ///   - name: Project name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - pid: UI-friendly ID value
    ///   - alive: Is project alive?
    ///   - company: Optional(Company)
    ///   - saveByDefault: Bool: True by default)
    /// - Returns: Project
    private func make(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, pid: Int64? = nil, alive: Bool = true, company: Company? = nil, jobs: NSSet? = nil, saveByDefault: Bool = true) -> Project {
        let project = Project(context: moc!)
        project.alive = alive
        project.abbreviation = abbreviation
        project.colour = colour
        project.created = created
        project.lastUpdate = updated ?? created
        project.name = name

        if pid == nil {
            project.pid = Int64.random(in: 1...1999999999999)
        } else {
            project.pid = pid!
        }

        project.company = company
        project.id = UUID()
        project.jobs = jobs

        // Use default company if we don't have one
        if company == nil {
            if let corpo = CoreDataCompanies(moc: self.moc!).findDefault() {
                project.company = corpo
            }
        }

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return project
    }
    
    /// Create a new project
    /// - Parameters:
    ///   - name: Project name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - pid: UI-friendly ID value
    ///   - alive: Is project alive?
    ///   - company: Optional(Company)
    ///   - saveByDefault: Bool: True by default)
    /// - Returns: Project
    public func create(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, pid: Int64? = nil, alive: Bool = true, company: Company? = nil, jobs: NSSet? = nil, saveByDefault: Bool = true) -> Void {
        let _ = self.make(name: name, abbreviation: abbreviation, colour: colour, created: created, pid: pid, company: company, jobs: jobs, saveByDefault: saveByDefault)
    }

    /// Create and return a new project
    /// - Parameters:
    ///   - name: Project name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - pid: UI-friendly ID value
    ///   - alive: Is project alive?
    ///   - company: Optional(Company)
    ///   - saveByDefault: Bool: True by default)
    /// - Returns: Project
    public func createAndReturn(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, pid: Int64? = nil, alive: Bool = true, company: Company? = nil, jobs: NSSet? = nil, saveByDefault: Bool = true) -> Project {
        return self.make(name: name, abbreviation: abbreviation, colour: colour, created: created, pid: pid, company: company, jobs: jobs, saveByDefault: saveByDefault)
    }

    /// Query projects
    /// - Parameter predicate: NSPredicate
    /// - Parameter sort: [NSSortDescriptor]
    /// - Returns: Array<Project>
    private func query(_ predicate: NSPredicate? = nil, sort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Project.created, ascending: false)]) -> [Project] {
        lock.lock()

        var results: [Project] = []
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.sortDescriptors = sort

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataProjects.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataProjects.query Unable to find records for query")
            }

            print("[error] \(error)")
        }

        lock.unlock()

        return results
    }

    /// Count projects
    /// - Parameter predicate: Query predicate
    /// - Returns: Int
    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Project.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataProjects.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
