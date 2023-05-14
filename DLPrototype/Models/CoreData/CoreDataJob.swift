//
//  CoreDataJob.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI


public class CoreDataJob: ObservableObject {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func getDefault() -> Job? {
        if let job = byId(11.0) {
            return job
        }
        
        return nil
    }
    
    public func byId(_ id: Double) -> Job? {
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "jid = %d", Int(id))
        fetch.fetchLimit = 1
        
        do {
            let results = try moc!.fetch(fetch)
            
            return results.first
        } catch {
            print("General Error: Unable to find task with ID \(id)")
        }
        
        return nil
    }
    
    public func byProject(_ projectId: UUID) -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project.id = %@ && alive = true", projectId.uuidString)
        
        
        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all jobs")
        }
        
        return all
    }
    
    public func all(_ stillAlive: Bool? = true) -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        
        if stillAlive! {
            fetch.predicate = NSPredicate(format: "alive = true")
        }
        
        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all jobs")
        }
        
        return all
    }
    
    public func owned() -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project != nil")
        
        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all owned jobs")
        }
        
        return all
    }
    
    public func unowned() -> [Job] {
        var all: [Job] = []
        let fetch: NSFetchRequest<Job> = Job.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Job.jid, ascending: false)]
        fetch.predicate = NSPredicate(format: "project = nil")
        
        do {
            all = try moc!.fetch(fetch)
        } catch {
            print("Couldn't retrieve all unowned jobs")
        }
        
        return all
    }
}
