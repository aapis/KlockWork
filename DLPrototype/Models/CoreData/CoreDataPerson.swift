//
//  CoreDataPerson.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import CoreData

public class CoreDataPerson: ObservableObject {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    /// Find people who have been updated recently
    /// - Parameter numDaysPrior: How far back to look, 7 days by default
    /// - Returns: FetchRequest<Person>
    static public func fetchRecent(numDaysPrior: Double = 7) -> FetchRequest<Person> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Person.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "lastUpdate >= %@",
            DateHelper.daysPast(numDaysPrior) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    public func byCompany(_ company: Company) -> [Person] {
        let predicate = NSPredicate(
            format: "company = %@",
            company as CVarArg
        )

        return query(predicate)
    }
    
    /// Count of all people in the system
    /// - Returns: Int
    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "name != nil"
        )

        return count(predicate)
    }

    private func query(_ predicate: NSPredicate? = nil) -> [Person] {
        lock.lock()

        var results: [Person] = []
        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Person.name, ascending: true)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataPerson.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataPerson.query Unable to find records for query")
            }

            print(error)
        }

        lock.unlock()

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Person.name, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataPerson.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
