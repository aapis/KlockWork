//
//  CDAssessmentThreshold.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-06-10.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import CoreData

class CDAssessmentThreshold {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    /// Find a list of active jobs
    /// - Parameter limit: Int
    /// - Returns: FetchRequest<AssessmentThreshold>
    static public func fetchAll(for date: Date? = nil, limit: Int? = nil) -> FetchRequest<AssessmentThreshold> {
        let fetch: NSFetchRequest<AssessmentThreshold> = AssessmentThreshold.fetchRequest()

        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \AssessmentThreshold.colour, ascending: false),
        ]

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    /// Create a new AssessmentThreshold
    /// - Parameters:
    ///   - colour: Color
    ///   - value: Int64
    ///   - defaultValue: Int64
    ///   - label: String
    ///   - emoji: String
    /// - Returns: Void
    public func create(colour: Color, value: Int64, defaultValue: Int64, label: String, emoji: String) -> Void {
        let _ = createAndReturn(colour: colour, value: value, defaultValue: defaultValue, label: label, emoji: emoji)
    }
    
    /// Create a new AssessmentThreshold
    /// - Parameters:
    ///   - colour: Color
    ///   - value: Int64
    ///   - defaultValue: Int64
    ///   - label: String
    ///   - emoji: String
    /// - Returns: AssessmentThreshold
    public func createAndReturn(colour: Color, value: Int64, defaultValue: Int64, label: String, emoji: String) -> AssessmentThreshold {
        lock.lock()
        let at = AssessmentThreshold(context: self.moc!)
        at.id = UUID()
        at.colour = colour.toStored()
        at.created = Date()
        at.lastUpdate = Date()
        at.value = value
        at.defaultValue = defaultValue
        at.label = label
        at.emoji = emoji

        PersistenceController.shared.save()
        lock.unlock()

        return at
    }

    /// Find all AssessmentThreshold objects
    /// - Returns: Array<AssessmentThreshold>
    public func all() -> [AssessmentThreshold] {
        return query()
    }

    /// Delete AssessmentThreshold objects
    /// - Returns: Void
    public func delete(threshold: AssessmentThreshold? = nil) -> Void {
        if let thresh = threshold {
            self.moc!.delete(thresh)
        } else {
            // Delete ALL assessment factors
            for ass in self.all() {
                self.moc!.delete(ass)
            }
        }

        PersistenceController.shared.save()
    }

    public func recreate() -> Void {
        self.delete()

        for weight in ActivityWeight.allCases {
            CDAssessmentThreshold(moc: self.moc).create(
                colour: weight.colour,
                value: 0,
                defaultValue: weight.defaultValue,
                label: weight.label,
                emoji: weight.emoji
            )
        }
    }

    public func recreateAndReturn() -> [AssessmentThreshold] {
        var statuses: [AssessmentThreshold] = []

        self.delete()

        for weight in ActivityWeight.allCases {
            statuses.append(
                CDAssessmentThreshold(moc: self.moc).createAndReturn(
                    colour: weight.colour,
                    value: weight.defaultValue,
                    defaultValue: weight.defaultValue,
                    label: weight.label,
                    emoji: weight.emoji
                )
            )
        }

        return statuses
    }

    /// Query function, finds and filters notes
    /// - Parameter predicate: A predicate to modify the results
    /// - Returns: Array<Note>
    private func query(_ predicate: NSPredicate? = nil) -> [AssessmentThreshold] {
        lock.lock()

        var results: [AssessmentThreshold] = []
        let fetch: NSFetchRequest<AssessmentThreshold> = AssessmentThreshold.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \AssessmentThreshold.defaultValue, ascending: false)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CDAssessmentThreshold.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CDAssessmentThreshold.query Unable to find records for query")
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
        let fetch: NSFetchRequest<AssessmentThreshold> = AssessmentThreshold.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \AssessmentThreshold.defaultValue, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CDAssessmentThreshold.count Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
