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

    public func byCompany(_ company: Company) -> [Person] {
        let predicate = NSPredicate(
            format: "company = %@",
            company as CVarArg
        )

        return query(predicate)
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
