//
//  CoreDataTaxonomyTermDefinitions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public class CoreDataTaxonomyTermDefinitions {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    /// Find all terms owned by a given Job
    /// - Parameters:
    ///   - job: Job
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(job: Job) -> FetchRequest<TaxonomyTermDefinitions> {
        let descriptors = [
            NSSortDescriptor(keyPath: \TaxonomyTermDefinitions.created, ascending: false)
        ]

        let fetch: NSFetchRequest<TaxonomyTermDefinitions> = TaxonomyTermDefinitions.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && job == %@",
            job as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find taxonomy definitions by Job
    /// - Parameter job: Job
    /// - Returns: Optional(TaxonomyTermDefinition)
    public func byJob(_ job: Job) -> TaxonomyTermDefinitions? {
        let results = self.query(NSPredicate(format: "job == %@", job))

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// All taxonomy terms
    /// - Returns: Array<TaxonomyTerm>
    public func all() -> [TaxonomyTermDefinitions] {
        return self.query(NSPredicate(format: "alive == true"))
    }

    /// Query function, finds and filters notes
    /// - Parameter predicate: A predicate to modify the results
    /// - Returns: Array<NoteVersion>
    private func query(_ predicate: NSPredicate? = nil) -> [TaxonomyTermDefinitions] {
        lock.lock()

        var results: [TaxonomyTermDefinitions] = []
        let fetch: NSFetchRequest<TaxonomyTermDefinitions> = TaxonomyTermDefinitions.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TaxonomyTermDefinitions.created?, ascending: true)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataTaxonomyTermDefinitions.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataTaxonomyTermDefinitions.query Unable to find records for query")
            }

            print("[error] \(error)")
        }

        lock.unlock()

        return results
    }

    /// Count function, returns a number of results for a given predicate
    /// - Parameter predicate: A predicate to modify the results
    /// - Returns: Int
    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<TaxonomyTermDefinitions> = TaxonomyTermDefinitions.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TaxonomyTermDefinitions.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataTaxonomyTermDefinitions.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}

