//
//  CoreDataProjects.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
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
    static public func fetchProjects() -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.lastUpdate?, ascending: false)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive = true")
        fetch.sortDescriptors = descriptors

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
    public func byCompany(_ id: Int64) -> [Project] {
        let predicate = NSPredicate(
            format: "company = %@",
            id
        )

        return query(predicate)
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

    /// Find all projects
    /// - Returns: Array<Project>
    public func all() -> [Project] {
        return query()
    }

    /// Find all alive/active projects
    /// - Returns: Array<Project>
    public func alive() -> [Project] {
        let predicate = NSPredicate(
            format: "alive = true"
        )
        
        return query(predicate)
    }

    /// Find recently used projects
    /// - Parameter numWeeks: Number of weeks in the past to search
    /// - Returns: Array<Project>
    public func recent(_ numWeeks: Double? = 2) -> [Project] {
        var results: [Project] = []
        let records = CoreDataRecords(moc: moc!).recent(numWeeks!)
        
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

    /// Create a new project
    /// - Parameters:
    ///   - name: Project name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - pid: UI-friendly ID value
    ///   - alive: Is project alive?
    /// - Returns: Void
    public func create(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, pid: Int64, alive: Bool = true) -> Void {
        let project = Project(context: moc!)
        project.alive = alive
        project.abbreviation = abbreviation
        project.colour = colour
        project.created = created
        project.lastUpdate = updated ?? created
        project.name = name
        project.pid = pid
        
        // If this company already exists, do nothing!
        let predicate = NSPredicate(format: "name = %@", name as CVarArg)
        let results = query(predicate)
        
        if results.count == 0 {
            PersistenceController.shared.save()
        }
    }

    /// Query projects
    /// - Parameter predicate: Query predicate
    /// - Returns: Array<Project>
    private func query(_ predicate: NSPredicate? = nil) -> [Project] {
        lock.lock()

        var results: [Project] = []
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Project.created, ascending: false)]
        
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
