//
//  CoreDataNotes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public class CoreDataNotes {
    /// Used to query Coredata
    public var moc: NSManagedObjectContext?

    /// Memory lock
    private let lock = NSLock()
    
    /// Create a new CoreDataNotes instance
    /// - Parameter moc: Optional NSManagedObjectContext object
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    /// Fetch request to find all starred notes
    /// - Parameter limit: Max number of items to return
    /// - Returns: FetchRequest<Note>
    static public func starredFetchRequest(limit: Int? = 0) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
        
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && starred == true")
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }
        
        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Fetch request to find all recent notes
    /// - Parameter limit: Max number of items to return
    /// - Returns: FetchRequest<Note>
    static public func fetchRecentNotes(limit: Int? = 0) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]

        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && lastUpdate != nil")
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Fetch request to find all notes, with an option to only return those flagged as favourites
    /// - Parameter favouritesOnly: Flag to return only favourite notes
    /// - Returns: FetchRequest<Note>
    static public func fetchNotes(favouritesOnly: Bool = false) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]

        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        if favouritesOnly {
            fetch.predicate = NSPredicate(format: "alive == true && starred == true && mJob.project.company.hidden == false")
        } else {
            fetch.predicate = NSPredicate(format: "alive == true && mJob != nil && mJob.project.company.hidden == false")
        }
        fetch.sortDescriptors = descriptors
        fetch.fetchLimit = 1000

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Get all notes posted on a given day
    /// - Parameter date: Date
    /// - Returns: Array<Note>
    public func forDate(_ date: Date) -> [Note] {
        var results: [Note] = []
        
        let (before, after) = DateHelper.startAndEndOf(date)
        
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)]
        fetch.predicate = NSPredicate(
            format: "(postedDate > %@ && postedDate <= %@) || (lastUpdate > %@ && lastUpdate <= %@) && alive = true",
            before as CVarArg,
            after as CVarArg,
            before as CVarArg,
            after as CVarArg
        )

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("Unable to find records for today")
        }
        
        return results
    }

    /// Find all favourited notes
    /// - Parameter limit: Maximum number of items to return
    /// - Returns: Array<Note>
    public func starred(limit: Int? = 0) -> [Note] {
        var results: [Note] = []
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
        
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive = true && starred = true")
        fetch.sortDescriptors = descriptors
        fetch.fetchLimit = limit!
        
        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataNotes.starred Unable to find starred notes")
        }
        
        return results
    }

    /// All notes
    /// - Returns: Array<Note>
    public func all() -> [Note] {
        return query()
    }

    /// Only notes that haven't been soft deleted
    /// - Returns: Array<Note>
    public func alive() -> [Note] {
        let predicate = NSPredicate(
            format: "alive = true"
        )

        return query(predicate)
    }

    /// Query function, finds and filters notes
    /// - Parameter predicate: A predicate to modify the results
    /// - Returns: Array<Note>
    private func query(_ predicate: NSPredicate? = nil) -> [Note] {
        lock.lock()

        var results: [Note] = []
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)]
        
        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataNotes.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataNotes.query Unable to find records for query")
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
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Note.postedDate?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataProjects.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
