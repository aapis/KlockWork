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

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    public func byPid(_ id: Int) -> Company? {
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

    public func alive() -> [Company] {
        let predicate = NSPredicate(
            format: "alive = true"
        )

        return query(predicate)
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
