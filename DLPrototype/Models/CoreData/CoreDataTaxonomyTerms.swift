//
//  CoreDataTaxonomyTerms.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public class CoreDataTaxonomyTerms {
    public var moc: NSManagedObjectContext?
    
    private let lock = NSLock()
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    /// Find tasks whose content matches a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<TaxonomyTerm>
    static public func fetchMatching(term: String) -> FetchRequest<TaxonomyTerm> {
        let descriptors = [
            NSSortDescriptor(keyPath: \TaxonomyTerm.created, ascending: true)
        ]
        
        let fetch: NSFetchRequest<TaxonomyTerm> = TaxonomyTerm.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && name CONTAINS %@",
            term
        )
        fetch.sortDescriptors = descriptors
        
        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find tasks whose content matches a given string
    /// - Parameter job: Job
    /// - Returns: FetchRequest<TaxonomyTerm>
    static public func fetch(job: Job) -> FetchRequest<TaxonomyTerm> {
        let descriptors = [
            NSSortDescriptor(keyPath: \TaxonomyTerm.created, ascending: true)
        ]
        
        let fetch: NSFetchRequest<TaxonomyTerm> = TaxonomyTerm.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "ANY definitions.job == %@",
            job
        )
        fetch.sortDescriptors = descriptors
        
        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Find all terms owned by a given Job
    /// - Parameters:
    ///   - job: Job
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetchDefinitions(job: Job) -> FetchRequest<TaxonomyTermDefinitions> {
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

    /// Find taxonomy terms by name (key)
    /// - Parameter name: String
    /// - Returns: Optional(TaxonomyTerm)
    public func byName(_ name: String) -> TaxonomyTerm? {
        let results = self.query(NSPredicate(format: "name == %@", name))

        if results.isEmpty {
            return nil
        }

        return results.first
    }

    /// Find taxonomy terms by job
    /// - Parameter job: Job
    /// - Returns: Optional(TaxonomyTerm)
    public func byJob(_ job: Job) -> [TaxonomyTerm]? {
        let results = self.query(
            NSPredicate(
                format: "ANY definitions.job == %@",
                job
            )
        )

        if results.isEmpty {
            return nil
        }

        return results
    }

    /// All taxonomy terms
    /// - Returns: Array<TaxonomyTerm>
    public func all() -> [TaxonomyTerm] {
        return self.query(NSPredicate(format: "alive == true"))
    }
    
    /// Count all taxonomy terms
    /// - Returns: Int
    public func countAll() -> Int {
        return self.count(NSPredicate(format: "alive == true"))
    }

    /// Query function, finds and filters notes
    /// - Parameter predicate: A predicate to modify the results
    /// - Returns: Array<NoteVersion>
    private func query(_ predicate: NSPredicate? = nil) -> [TaxonomyTerm] {
        lock.lock()

        var results: [TaxonomyTerm] = []
        let fetch: NSFetchRequest<TaxonomyTerm> = TaxonomyTerm.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TaxonomyTerm.created?, ascending: true)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataTaxonomyTerms.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataTaxonomyTerms.query Unable to find records for query")
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
        let fetch: NSFetchRequest<TaxonomyTerm> = TaxonomyTerm.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TaxonomyTerm.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataTaxonomyTerm.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
