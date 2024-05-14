//
//  CoreDataCompanies.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public class CoreDataCompanies: ObservableObject {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public var nextPid: Int64 {
        return Int64(count(NSPredicate(format: "name != nil")) + 1)
    }

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
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

    public func alive() -> [Company] {
        let predicate = NSPredicate(
            format: "alive = true && hidden == false"
        )

        return query(predicate)
    }

    public func all() -> [Company] {
        let predicate = NSPredicate(
            format: "name != nil && hidden == false"
        )

        return query(predicate)
    }

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
