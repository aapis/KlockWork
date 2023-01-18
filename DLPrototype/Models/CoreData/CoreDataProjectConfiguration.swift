//
//  CoreDataProjectConfiguration.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public final class CoreDataProjectConfiguration {
    public var moc: NSManagedObjectContext?
    
    static public var safeWord: String = "bleep"
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    static public func applyBannedWordsTo(_ record: LogRecord) -> LogRecord {
        let badWords = record.job?.project?.configuration?.bannedWords
        
        if badWords != nil {
            let bWords = badWords!.allObjects as! [BannedWord]
            
            if !bWords.isEmpty {
                for bad in bWords {
                    record.message = record.message?.replacingOccurrences(of: bad.word!, with: CoreDataProjectConfiguration.safeWord)
                }
            }
        }
        
        return record
    }
    
    public func allBannedWords() -> [BannedWord] {
        var results: [BannedWord] = []
        let fetch: NSFetchRequest<BannedWord> = BannedWord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \BannedWord.created, ascending: false)]

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("Unable to find any banned words")
        }
        
        return results
    }
    
    public func byWord(_ word: String) -> [BannedWord] {
        var results: [BannedWord] = []
        let fetch: NSFetchRequest<BannedWord> = BannedWord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \BannedWord.created, ascending: false)]
        
        fetch.predicate = NSPredicate(
            format: "word CONTAINS[c] %@",
            word
        )

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("Unable to find any banned words")
        }
        
        return results
    }
    
    public func byPid(_ pid: Int) -> [BannedWord] {
        var results: [BannedWord] = []
        let fetch: NSFetchRequest<BannedWord> = BannedWord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \BannedWord.created, ascending: false)]
        
        fetch.predicate = NSPredicate(
            format: "pid = %@",
            pid
        )

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("Unable to find any banned words")
        }
        
        return results
    }
}
