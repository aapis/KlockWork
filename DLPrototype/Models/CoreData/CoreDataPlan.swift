//
//  CoreDataPlan.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import CoreData

public final class CoreDataPlan {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    public func all() -> [Plan] {
        let predicate = NSPredicate(
            format: "created <= %@",
            Date() as CVarArg
        )

        return query(predicate)
    }

    public func byId(_ id: UUID) -> [Plan] {
        let predicate = NSPredicate(
            format: "id == %@",
            id.uuidString as CVarArg
        )

        return query(predicate)
    }

    public func forToday() -> [Plan] {
        let (start, _) = DateHelper.startAndEndOf(Date())
        let predicate = NSPredicate(
            format: "created >= %@",
            start as CVarArg
        )

        return query(predicate)
    }

    public func countForToday() -> Int {
        let (start, _) = DateHelper.startAndEndOf(Date())
        let predicate = NSPredicate(
            format: "created >= %@",
            start as CVarArg
        )

        return count(predicate)
    }

    public func forDate(_ date: Date) -> [Plan] {
        let (start, end) = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "created > %@ && created <= %@",
            start as CVarArg,
            end as CVarArg
        )

        return query(predicate)
    }

    private func query(_ predicate: NSPredicate) -> [Plan] {
        lock.lock()

        var results: [Plan] = []
        let fetch: NSFetchRequest<Plan> = Plan.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Plan.created?, ascending: false)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataPlan.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Plan> = Plan.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Plan.created?, ascending: false)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataPlan.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
