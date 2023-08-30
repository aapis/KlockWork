//
//  CoreDataProjects.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataProjects: ObservableObject {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    static public func recentProjectsWidgetData() -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.lastUpdate?, ascending: false)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive = true")
        fetch.sortDescriptors = descriptors
        fetch.fetchLimit = 10

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    static public func fetchProjects() -> FetchRequest<Project> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Project.lastUpdate?, ascending: false)
        ]

        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.predicate = NSPredicate(format: "alive = true")
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    public func byId(_ id: Int) -> Project? {
        let predicate = NSPredicate(
            format: "pid = %d",
            id as CVarArg
        )
        
        let results = query(predicate)
        
        if results.isEmpty {
            return nil
        }
        
        return results.first
    }

    public func anyName(_ term: String) -> [Project] {
        let predicate = NSPredicate(
            format: "name = %@",
            term
        )

        return query(predicate)
    }

    public func byName(_ term: String) -> Project? {
        let predicate = NSPredicate(
            format: "name = %@",
            term
        )

        let results = query(predicate)

        if results.isEmpty {
            return nil
        }

        return results.first
    }
    
    public func all() -> [Project] {
        return query()
    }
    
    public func alive() -> [Project] {
        let predicate = NSPredicate(
            format: "alive = true"
        )
        
        return query(predicate)
    }
    
    public func recent(_ numWeeks: Double? = 2) -> [Project] {
        var results: [Project] = []
        let records = CoreDataRecords(moc: moc!).recent(numWeeks!)
        
        for rec in records {
            if rec.job != nil {
                if let project = rec.job!.project {
                    if !results.contains(where: {($0.id == project.id)}) {
                        results.append(project)
                    }
                }
            }
        }
        
        return results
    }

    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "alive == true"
        )

        return count(predicate)
    }

    private func query(_ predicate: NSPredicate? = nil) -> [Project] {
        lock.lock()

        var results: [Project] = []
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Project.created, ascending: false)]
        
        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataProjects.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataProjects.query Unable to find records for query")
            }

            print(error)
        }

        lock.unlock()

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Project> = Project.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Project.created?, ascending: true)]
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
