//
//  CDAssessmentFactor.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-30.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreData

public class CDAssessmentFactor {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    /// Find a list of active jobs
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<AssessmentFactor>
    static public func nsfetch(date: Date? = nil, limit: Int? = nil) -> NSFetchRequest<AssessmentFactor> {
        let fetch: NSFetchRequest<AssessmentFactor> = AssessmentFactor.fetchRequest()

        if date != nil {
            let (start, end) = DateHelper.startAndEndOf(date!)
            fetch.predicate = NSPredicate(
                format: "alive == true && (date >= %@ && date <= %@)",
                start as CVarArg,
                end as CVarArg
            )
        } else {
            fetch.predicate = NSPredicate(format: "alive == true")
        }

        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \AssessmentFactor.created, ascending: false),
        ]

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return fetch
    }

    /// Find a list of active jobs
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<AssessmentFactor>
    static public func fetchAll(for date: Date? = nil, limit: Int? = nil) -> FetchRequest<AssessmentFactor> {
        let fetch: NSFetchRequest<AssessmentFactor> = AssessmentFactor.fetchRequest()
        
        if date != nil {
            let (start, end) = DateHelper.startAndEndOf(date!)
            fetch.predicate = NSPredicate(
                format: "alive == true && (date >= %@ && date <= %@)",
                start as CVarArg,
                end as CVarArg
            )
        } else {
            fetch.predicate = NSPredicate(format: "alive == true")
        }

        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \AssessmentFactor.created, ascending: false),
        ]

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all assessment factors for a given date
    /// - Parameter date: Date
    /// - Returns: Array<AssessmentFactor>
    public func all(for date: Date? = nil, limit: Int? = nil) -> [AssessmentFactor] {
        var all: [AssessmentFactor] = []
        do {
            var aFactor: NSFetchRequest<AssessmentFactor>
            if date != nil {
                aFactor = CDAssessmentFactor.nsfetch(date: date!, limit: limit)
            } else {
                aFactor = CDAssessmentFactor.nsfetch(limit: limit)
            }

            all = try self.moc!.fetch(aFactor)
        } catch {
            print("[error] CoreDataAssessmentFactor query error \(error)")
        }

        return all
    }
    
    /// Delete AssessmentFactor objects
    /// @TODO: Remove in favour of a "global" one like PersistenceController.shared.delete()
    /// - Returns: Void
    public func delete(factor: AssessmentFactor? = nil) -> Void {
        if let fact = factor {
            self.moc!.delete(fact)
        } else {
            // Delete ALL assessment factors
            let items = CDAssessmentFactor(moc: self.moc!).all()
            for ass in items {
                self.moc!.delete(ass)
            }
        }

        PersistenceController.shared.save()
    }

    public func delete(by date: Date) -> Void {
        for ass in CDAssessmentFactor(moc: self.moc!).all(for: date) {
            self.moc!.delete(ass)
        }

        PersistenceController.shared.save()
    }
}
