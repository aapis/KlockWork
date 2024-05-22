//
//  CoreDataCompanies.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
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
    /// - Returns: FetchRequest<Company>
    static public func all() -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true)
        ]

        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && hidden == false")
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Finds all active companies
    /// - Returns: FetchRequest<Company>
    static public func fetch() -> FetchRequest<Company> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Company.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive = true")
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Retreive all companies by pid
    /// - Parameter id: PID value to find
    /// - Returns: Company|nil
    public func byPid(_ id: Int) -> Company? {
        let predicate = NSPredicate(
            format: "pid = %d && hidden == false",
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
            format: "name = %@ && hidden == false",
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
            format: "alive = true && hidden == false"
        )

        return query(predicate)
    }

    /// Find all companies that have a name and are not hidden
    /// - Returns: Array<Company>
    public func all() -> [Company] {
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
            format: "isDefault = true"
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }
    
    /// Create a new company
    /// - Parameters:
    ///   - name: Company name
    ///   - abbreviation: Abbreviation used by various search syntaxes
    ///   - colour: Colour as an array of Double's
    ///   - created: Created date
    ///   - updated: Updated date
    ///   - isDefault: Is this the default company?
    ///   - pid: UI-friendly ID value
    ///   - alive: Is company alive?
    ///   - hidden: Is company hidden?
    /// - Returns: Void
    public func create(name: String, abbreviation: String, colour: [Double], created: Date, updated: Date? = nil, isDefault: Bool, pid: Int64, alive: Bool = true, hidden: Bool = false) -> Void {
        let company = Company(context: moc!)
        company.alive = alive
        company.hidden = hidden
        company.abbreviation = abbreviation
        company.colour = colour
        company.createdDate = created
        company.lastUpdate = updated ?? created
        company.isDefault = isDefault
        company.name = name
        company.pid = pid
        
        // If this company already exists, do nothing!
        let predicate = NSPredicate(format: "name = %@", name as CVarArg)
        let results = query(predicate)
        
        if results.count == 0 {
            PersistenceController.shared.save()
        }
    }

    /// Query companies
    /// - Parameter predicate: Query predicate
    /// - Returns: Array<Company>
    private func query(_ predicate: NSPredicate? = nil) -> [Company] {
        lock.lock()

        var results: [Company] = []
        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Company.createdDate, ascending: false)]

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
