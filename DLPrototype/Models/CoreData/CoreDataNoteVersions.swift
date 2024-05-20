//
//  CoreDataNoteVersions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public class CoreDataNoteVersions: ObservableObject {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
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
    
    public func from(_ note: Note, source: SaveSource = .manual) -> Void {
        let version = NoteVersion(context: moc!)
        version.id = UUID()
        version.note = note
        version.title = note.title
        version.content = note.body
        version.starred = note.starred
        version.created = Date()
        version.source = source.name
        
        do {
            try moc!.save()
        } catch {
            print("Couldn't create note version for note \(note.id?.uuidString ?? "unknown")")
        }
    }
}
