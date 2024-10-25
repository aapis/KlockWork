//
//  CoreDataNotes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore
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
    static public func fetchRecentNotes(limit: Int? = 0, daysPrior: Double = 7) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
        
        let date = DateHelper.daysPast(daysPrior)
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive == true && lastUpdate != nil && lastUpdate >= %@", date as CVarArg)
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

    /// Find notes whose title or content fields match a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<Note>
    static public func fetchMatching(term: String) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]

        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && (title CONTAINS[c] %@ || body CONTAINS[c] %@)",
            term,
            term
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all objects created on a given date
    /// - Parameters:
    ///   - date: Date
    ///   - limit: Int, 10 by default
    ///   - daysPrior: Int, 7 by default
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(for date: Date, limit: Int? = 10, daysPrior: Int = 7) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.title, ascending: true),
            NSSortDescriptor(keyPath: \Note.lastUpdate, ascending: true)
        ]

        var predicate: NSPredicate
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        let (start, end) = DateHelper.startAndEndOf(date)
        if let rangeStart = DateHelper.prior(numDays: daysPrior, from: start).last {
            predicate = NSPredicate(
                format: "alive == true && ((postedDate > %@ && postedDate <= %@) || (lastUpdate > %@ && lastUpdate <= %@)) && mJob.project.company.hidden == false",
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "alive == true && ((postedDate > %@ && postedDate <= %@) || (lastUpdate > %@ && lastUpdate <= %@)) && mJob.project.company.hidden == false",
                start as CVarArg,
                end as CVarArg,
                start as CVarArg,
                end as CVarArg
            )
        }

        fetch.predicate = predicate
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find all objects associated with the given job
    /// - Parameter job: Job
    /// - Returns: FetchRequest<NSManagedObject>
    static public func fetch(by job: Job) -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]

        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && mJob == %@",
            job
        )
        fetch.sortDescriptors = descriptors

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
            format: "alive == true"
        )

        return query(predicate)
    }

    /// Finds notes created or updated on a specific date, that aren't hidden by their parent
    /// - Parameter date: Date
    /// - Returns: Array<Note>
    public func find(for date: Date) -> [Note] {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "((postedDate > %@ && postedDate <= %@) || (lastUpdate > %@ && lastUpdate <= %@))", // && job.project.company.hidden == false
            window.0 as CVarArg,
            window.1 as CVarArg,
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        return query(predicate)
    }
    
    /// Find notes by Job
    /// - Parameter job: Job
    /// - Returns: [Note]
    public func find(by job: Job, allowKilled: Bool = false) -> [Note] {
        var predicate: NSPredicate
        if !allowKilled {
            predicate = NSPredicate(
                format: "mJob == %@",
                job
            )
        } else {
            predicate = NSPredicate(
                format: "alive == true && ANY mJob == %@",
                job
            )
        }

        return query(predicate)
    }

    /// Find notes by Job
    /// - Parameter project: Project
    /// - Returns: [Note]
    public func find(by project: Project, allowKilled: Bool = false) -> [Note] {
        var predicate: NSPredicate

        if !allowKilled {
            predicate = NSPredicate(
                format: "mJob.project == %@",
                project
            )
        } else {
            predicate = NSPredicate(
                format: "alive == true && mJob.project == %@",
                project
            )
        }


        return query(predicate)
    }

    /// Count up all the notes referenced for a given day
    /// - Parameter date: Date
    /// - Returns: Int
    public func countByDate(for date: Date) -> Int {
        return self.find(for: date).count
    }

    /// Count all notes
    /// - Returns: Int
    public func countAll() -> Int {
        return self.count(
            NSPredicate(
                format: "alive == true"
            )
        )
    }

    /// Updates a single NSManagedObject
    /// - Parameters:
    ///   - entity: Note, the target to modify
    ///   - alive: Bool
    ///   - body: String
    ///   - lastUpdate: Date
    ///   - postedDate: Date
    ///   - starred: Bool
    ///   - title: String
    ///   - saveByDefault: Bool
    /// - Returns: Void
    public func update(entity: Note, alive: Bool, body: String, lastUpdate: Date?, postedDate: Date?, starred: Bool, title: String, job: Job? = nil, saveByDefault: Bool = true) -> Void {
        entity.alive = alive
        entity.body = body
        entity.lastUpdate = lastUpdate
        entity.postedDate = postedDate
        entity.starred = starred
        entity.title = title
        entity.job = job
        entity.addToVersions(
            CoreDataNoteVersions(moc: self.moc!).from(entity, source: .manual)
        )

        if saveByDefault {
            PersistenceController.shared.save()
        }
    }

    /// Public method for creating a new note
    /// - Parameters:
    ///   - alive: Bool
    ///   - body: String
    ///   - lastUpdate: Date
    ///   - postedDate: Date
    ///   - starred: Bool
    ///   - title: String
    ///   - saveByDefault: Bool
    /// - Returns: Void
    public func create(alive: Bool, body: String, lastUpdate: Date?, postedDate: Date?, starred: Bool, title: String, job: Job? = nil, saveByDefault: Bool = true) -> Void {
        let _ = self.make(alive: alive, body: body, starred: starred, title: title, job: job, saveByDefault: saveByDefault)
    }

    /// Public method for creating and returning a new note
    /// - Parameters:
    ///   - alive: Bool
    ///   - body: String
    ///   - lastUpdate: Date
    ///   - postedDate: Date
    ///   - starred: Bool
    ///   - title: String
    ///   - saveByDefault: Bool
    /// - Returns: Note
    public func createAndReturn(alive: Bool, body: String, lastUpdate: Date?, postedDate: Date?, starred: Bool, title: String, job: Job? = nil, saveByDefault: Bool = true) -> Note {
        return self.make(alive: alive, body: body, starred: starred, title: title, job: job, saveByDefault: saveByDefault)
    }

    /// Internal method for creating a new note
    /// - Parameters:
    ///   - alive: Bool
    ///   - body: String
    ///   - lastUpdate: Date
    ///   - postedDate: Date
    ///   - starred: Bool
    ///   - title: String
    ///   - saveByDefault: Bool
    /// - Returns: Note
    private func make(alive: Bool, body: String, lastUpdate: Date? = Date(), postedDate: Date? = Date(), starred: Bool, title: String, job: Job? = nil, saveByDefault: Bool = true) -> Note {
        // Create the note
        let newNote = Note(context: self.moc!)
        newNote.alive = alive
        newNote.body = body
        newNote.id = UUID()
        newNote.lastUpdate = lastUpdate
        newNote.postedDate = postedDate
        newNote.starred = starred
        newNote.title = title
        // Create a version
        newNote.addToVersions(
            CoreDataNoteVersions(moc: self.moc!).from(newNote, source: .auto, saveByDefault: saveByDefault)
        )
        // Assign to job
        if let job = job {
            newNote.mJob = job
        }

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return newNote
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
            print("[error] CoreDataNotes.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
