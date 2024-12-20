//
//  CoreDataCompanies.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreData

public class CoreDataCompanies: ObservableObject {
    /// Context for updating CD objects
    public var moc: NSManagedObjectContext?
    
    /// Thread lock
    private let lock = NSLock()
    
    /// Calculate next  pid value
    public var nextPid: Int64 {
        return Int64(count(NSPredicate(format: "name != nil")) + 1)
    }
    
    /// Create new CoreDataCompanies instance
    /// - Parameter moc: NSManagedObjectContext
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    /// Fetch request to find all items
    /// - Parameter allowKilled: Bool
    /// - Returns: FetchRequest<Company>
    static public func all(_ allowKilled: Bool = false) -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true)
        ]

        let fetch: NSFetchRequest<Company> = Company.fetchRequest()

        if allowKilled {
            fetch.predicate = NSPredicate(format: "hidden == false")
        } else {
            fetch.predicate = NSPredicate(format: "alive == true && hidden == false")
        }

        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Finds all active companies
    /// - Parameter allowKilled: Bool
    /// - Returns: FetchRequest<Company>
    static public func fetch(_ allowKilled: Bool = false) -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true),
        ]

        let fetch: NSFetchRequest<Company> = Company.fetchRequest()

        if allowKilled {
            fetch.predicate = NSPredicate(format: "createdDate < %@", Date() as CVarArg)
        } else {
            fetch.predicate = NSPredicate(format: "alive == true")
        }
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find all active companies that have been updated within the last week
    /// - Parameter numDaysPrior: How far back to look, 7 days by default
    /// - Returns: FetchRequest<Company>
    static public func fetchRecent(numDaysPrior: Double = 7) -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && lastUpdate >= %@",
            DateHelper.daysPast(numDaysPrior) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find companies whose name matches a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<Company>
    static public func fetchMatching(term: String) -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && name CONTAINS[c] %@", term as CVarArg)
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all objects created on a given date
    /// - Parameters:
    ///   - date: Date
    ///   - limit: Int, 10 by default
    ///   - daysPrior: Int, 7 by default
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(for date: Date, limit: Int? = 10, daysPrior: Int = 7) -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true),
            NSSortDescriptor(keyPath: \Company.createdDate?, ascending: true)
        ]

        var predicate: NSPredicate
        let (start, end) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        if let rangeStart = DateHelper.prior(numDays: daysPrior, from: start).last {
            predicate = NSPredicate(
                format: "alive == true && ((createdDate > %@ && createdDate < %@) || (lastUpdate > %@ && lastUpdate < %@)) && hidden == false",
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "alive == true && ((createdDate > %@ && createdDate < %@) || (lastUpdate > %@ && lastUpdate < %@)) && hidden == false",
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

    /// Fetch request to find all items
    /// - Returns: FetchRequest<Company>
    public func active() -> [Company] {
        let predicate = NSPredicate(
            format: "alive == true"
        )

        return query(predicate)
    }

    /// Fetch request to find all items
    /// - Returns: FetchRequest<Company>
    public func all(allowKilled: Bool = false, allowPlanMembersOnly: Bool = false, planMembers: Set<Company>) -> [Company] {
        if allowPlanMembersOnly {
            var subpredicates: [NSPredicate] = []

            // Add alive check if required
            if allowKilled {
                subpredicates.append(
                    NSPredicate(format: "alive == true")
                )
            }

            // Add plan members to query
            for member in planMembers {
                subpredicates.append(
                    NSPredicate(format: "name == %@", member.name!)
                )
            }

            let filterPredicate = NSCompoundPredicate(
                type: NSCompoundPredicate.LogicalType.or,
                subpredicates: subpredicates
            )

            return query(filterPredicate)
        } else {
            let predicate = NSPredicate(
                format: !allowKilled ? "createdDate < %@" : "alive == true && createdDate < %@",
                Date() as CVarArg
            )

            return query(predicate)
        }
    }

    /// Retreive all companies by pid
    /// - Parameter id: PID value to find
    /// - Returns: Company|nil
    public func byPid(_ id: Int) -> Company? {
        let predicate = NSPredicate(
            format: "pid == %d && hidden == false",
            id as CVarArg
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// Find companies by name
    /// - Parameter name: Company name
    /// - Returns: Company|nil
    public func byName(_ name: String) -> Company? {
        let predicate = NSPredicate(
            format: "name == %@ && hidden == false",
            name as CVarArg
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// Find all alive companies
    /// - Returns: Array<Company>
    public func alive() -> [Company] {
        let predicate = NSPredicate(
            format: "alive == true && hidden == false"
        )

        return query(predicate)
    }

    /// Find all companies that have a name and are not hidden
    /// - Returns: Array<Company>
    public func indescriminate() -> [Company] {
        let predicate = NSPredicate(
            format: "name != nil && hidden == false"
        )

        return query(predicate)
    }
    
    /// Total number of active companies
    /// - Returns: Int
    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "alive == true && hidden == false"
        )

        return count(predicate)
    }

    /// Finds the default company
    /// - Returns: Company|nil
    public func findDefault() -> Company? {
        let predicate = NSPredicate(
            format: "isDefault == true && alive == true"
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// Finds people created or updated on a given day
    /// - Parameter date: Date
    /// - Returns: Array<Company>
    public func forDate(_ date: Date) -> [Company] {
        let (before, after) = DateHelper.startAndEndOf(date)
        return self.query(
            NSPredicate(
                format: "(createdDate > %@ && createdDate < %@) || (lastUpdate > %@ && lastUpdate < %@)",
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
    public func interactionsOn(_ date: Date) -> [Company] {
        let records = CoreDataRecords(moc: self.moc!).forDate(date)
        if records.count == 0 {
            return []
        }

        var set: Set<Company> = []

        for record in records {
            if let company = record.job?.project?.company {
                set.insert(company)
            }
        }

        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "(createdDate > %@ && createdDate < %@) || (lastUpdate > %@ && lastUpdate < %@)",
            window.0 as CVarArg,
            window.1 as CVarArg,
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
    public func interactionsIn(start: Date?, end: Date?) -> [Company] {
        if start != nil && end != nil {
            let records = CoreDataRecords(moc: self.moc!).inRange(start: start!, end: end!)
            if records.count == 0 {
                return []
            }

            var set: Set<Company> = []

            for record in records {
                if let company = record.job?.project?.company {
                    set.insert(company)
                }
            }

            let predicate = NSPredicate(
                format: "(createdDate > %@ && createdDate < %@) || (lastUpdate > %@ && lastUpdate < %@)",
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

    /// Create a new company
    /// - Parameters:
    ///   - name: Company name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - projects: NSSet(Array<Project>)
    ///   - isDefault: Is this the default company?
    ///   - pid: UI-friendly ID value
    ///   - alive: Is company alive?
    ///   - hidden: Is company hidden?
    /// - Returns: Void
    private func make(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, projects: NSSet, isDefault: Bool, pid: Int64? = nil, alive: Bool = true, hidden: Bool = false, saveByDefault: Bool = true) -> Company {
        let company = Company(context: moc!)
        company.alive = alive
        company.hidden = hidden
        company.abbreviation = abbreviation
        company.colour = colour
        company.createdDate = created
        company.lastUpdate = updated ?? created
        company.isDefault = isDefault
        company.name = name

        if pid == nil {
            company.pid = Int64.random(in: 1...1999999999999)
        } else {
            company.pid = pid!
        }

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return company
    }

    /// Create a new company
    /// - Parameters:
    ///   - name: Company name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - projects: NSSet(Array<Project>)
    ///   - isDefault: Is this the default company?
    ///   - pid: UI-friendly ID value
    ///   - alive: Is company alive?
    ///   - hidden: Is company hidden?
    /// - Returns: Void
    public func create(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, projects: NSSet, isDefault: Bool, pid: Int64? = nil, alive: Bool = true, hidden: Bool = false, saveByDefault: Bool = true) -> Void {
        let _ = self.make(
            name: name,
            abbreviation: abbreviation,
            colour: colour,
            created: created,
            updated: updated,
            projects: projects,
            isDefault: isDefault,
            pid: pid,
            saveByDefault: saveByDefault
        )
    }

    /// Create a new company and return it
    /// - Parameters:
    ///   - name: Company name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - projects: NSSet(Array<Project>)
    ///   - isDefault: Is this the default company?
    ///   - pid: UI-friendly ID value
    ///   - alive: Is company alive?
    ///   - hidden: Is company hidden?
    /// - Returns: Void
    public func createAndReturn(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, projects: NSSet, isDefault: Bool, pid: Int64? = nil, alive: Bool = true, hidden: Bool = false, saveByDefault: Bool = true) -> Company {
        return self.make(
            name: name,
            abbreviation: abbreviation,
            colour: colour,
            created: created,
            updated: updated,
            projects: projects,
            isDefault: isDefault,
            pid: pid,
            saveByDefault: saveByDefault
        )
    }

    /// Find companies matching the provided search term
    /// - Parameter term: String - Search term
    /// - Returns: Array<Company>
    public func matching(term: String) -> [Company] {
        let predicate = NSPredicate(
            format: "name CONTAINS[c] %@",
            term.lowercased() as CVarArg,
            term.lowercased() as CVarArg
        )

        return query(predicate)
    }

    /// Query companies
    /// - Parameter predicate: Query predicate
    /// - Returns: Array<Company>
    private func query(_ predicate: NSPredicate? = nil, sort: [NSSortDescriptor] = [
        NSSortDescriptor(keyPath: \Company.isDefault, ascending: false),
        NSSortDescriptor(keyPath: \Company.name?, ascending: true),
        NSSortDescriptor(keyPath: \Company.createdDate?, ascending: true)
    ]) -> [Company] {
        lock.lock()

        var results: [Company] = []
        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.sortDescriptors = sort

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataCompanies.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataCompanies.query Unable to find records for query")
            }

            print(error)
        }

        lock.unlock()

        return results
    }
    
    /// Count companies
    /// - Parameter predicate: Query predicate
    /// - Returns: Int
    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Company.createdDate, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataCompanies.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
