//
//  CoreDataNoteVersions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore
import CoreData

public class CoreDataNoteVersions: ObservableObject {
    /// Memory lock
    private let lock = NSLock()

    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    /// Finds notes created or updated on a specific date, that aren't hidden by their parent
    /// - Parameter date: Date
    /// - Returns: Array<Note>
    public func find(for date: Date) -> [NoteVersion] {
        let window = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "(created > %@ && created < %@)",
            window.0 as CVarArg,
            window.1 as CVarArg,
            window.0 as CVarArg,
            window.1 as CVarArg
        )

        return query(predicate)
    }

    /// Count up all the jobs referenced for a given day
    /// - Parameter date: Date
    /// - Returns: Int
    public func countByDate(for date: Date) -> Int {
        return self.find(for: date).count
    }

    public func by(id: UUID) -> [NoteVersion] {
        var results: [NoteVersion] = []
        let fetch: NSFetchRequest<NoteVersion> = NoteVersion.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \NoteVersion.created, ascending: false)]
        fetch.predicate = NSPredicate(format: "note.id = %@", id.uuidString)
        
        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("General Error: Unable to find task with ID \(id)")
        }
        
        return results
    }
    
    public func from(_ note: Note, source: SaveSource = .manual, saveByDefault: Bool = true) -> NoteVersion {
        let version = NoteVersion(context: moc!)
        version.id = UUID()
        version.note = note
        version.title = note.title
        version.content = note.body
        version.starred = note.starred
        version.created = Date()
        version.source = source.name
        
        do {
            if saveByDefault {
                try moc!.save()
            }
        } catch {
            print("Couldn't create note version for note \(note.id?.uuidString ?? "unknown")")
        }

        return version
    }

    /// Query function, finds and filters notes
    /// - Parameter predicate: A predicate to modify the results
    /// - Returns: Array<NoteVersion>
    private func query(_ predicate: NSPredicate? = nil) -> [NoteVersion] {
        lock.lock()

        var results: [NoteVersion] = []
        let fetch: NSFetchRequest<NoteVersion> = NoteVersion.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \NoteVersion.created?, ascending: true)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataNoteVersions.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataNoteVersions.query Unable to find records for query")
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
        let fetch: NSFetchRequest<NoteVersion> = NoteVersion.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \NoteVersion.created?, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataNoteVersions.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
