//
//  CDSavedSearch.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-15.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreData

public class CDSavedSearch: ObservableObject {
    /// Context for updating CD objects
    public var moc: NSManagedObjectContext?
    
    /// Thread lock
    private let lock = NSLock()
    
    /// Create new CDSavedSearch instance
    /// - Parameter moc: NSManagedObjectContext
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    /// Find all saved searches
    /// - Returns: [SavedSearch]
    public func all() -> [SavedSearch] {
        let predicate = NSPredicate(
            format: "created < %@",
            Date() as CVarArg
        )

        return self.query(predicate)
    }
    
    /// Find SavedSearch objects by term
    /// - Parameter term: String
    /// - Returns: Optional(SavedSearch
    public func find(by term: String) -> SavedSearch? {
        let predicate = NSPredicate(
            format: "term == %@",
            term
        )

        let results = self.query(predicate)

        if let result = results.first {
            return result
        }

        return nil
    }

    /// Destroy all saved search terms
    /// - Returns: Void
    public func destroyAll() -> Void {
        let entities = self.query(NSPredicate(format: "created < %@", Date.now as CVarArg))

        for entity in entities {
            self.moc!.delete(entity)
        }

        PersistenceController.shared.save()
    }

    /// Destroy a saved search term
    /// - Parameter term: SavedSearch
    /// - Returns: Void
    public func destroy(_ term: String) -> Void {
        if let entity = self.query(NSPredicate(format: "term == %@", term)).first {
            self.moc!.delete(entity)

            PersistenceController.shared.save()
        }
    }

    /// Create and return a new saved search term
    /// - Parameters:
    ///   - term: String
    ///   - created: Date
    ///   - saveByDefault: Bool(true)
    /// - Returns: Void
    public func createAndReturn(term: String, created: Date) -> SavedSearch {
        return self.make(term: term, created: created)
    }

    /// Create a new saved search term
    /// - Parameters:
    ///   - term: String
    ///   - created: Date
    ///   - saveByDefault: Bool(true)
    /// - Returns: Void
    public func create(term: String, created: Date) -> Void {
        let _ = self.make(term: term, created: created)
    }

    /// Create a new saved search term
    /// - Parameters:
    ///   - term: String
    ///   - created: Date
    ///   - saveByDefault: Bool(true)
    /// - Returns: SavedSearch
    private func make(term: String, created: Date, saveByDefault: Bool = true) -> SavedSearch {
        let savedSearch = SavedSearch(context: self.moc!)
        savedSearch.term = term
        savedSearch.created = created

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return savedSearch
    }

    /// Query companies
    /// - Parameter predicate: Query predicate
    /// - Parameter sort: [NSSortDescriptor]
    /// - Returns: Array<SavedSearch>
    private func query(_ predicate: NSPredicate? = nil, _ sort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \SavedSearch.created?, ascending: true)]) -> [SavedSearch] {
        lock.lock()

        var results: [SavedSearch] = []
        let fetch: NSFetchRequest<SavedSearch> = SavedSearch.fetchRequest()
        fetch.sortDescriptors = sort
        fetch.returnsDistinctResults = true
        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CDSavedSearch.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CDSavedSearch.query Unable to find records for query")
            }

            print(error)
        }

        lock.unlock()

        return results
    }

    /// Count companies
    /// - Parameter predicate: Query predicate
    /// - Parameter sort: [NSSortDescriptor]
    /// - Returns: Int
    private func count(_ predicate: NSPredicate, sort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \SavedSearch.created?, ascending: true)]) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<SavedSearch> = SavedSearch.fetchRequest()
        fetch.sortDescriptors = sort
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CDSavedSearch.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
