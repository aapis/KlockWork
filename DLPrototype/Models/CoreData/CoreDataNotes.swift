//
//  CoreDataNotes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataNotes {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
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

    static public func fetchNotes() -> FetchRequest<Note> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Note.mJob?.project?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.mJob?.id, ascending: false),
            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]

        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
//        if let txt = text {
//            fetch.predicate = NSPredicate(format: "alive == true && title CONTAINS[c] %s", txt.wrappedValue)
//        } else {
            fetch.predicate = NSPredicate(format: "alive == true")
//        }
        fetch.sortDescriptors = descriptors
        fetch.fetchLimit = 1000

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
}
