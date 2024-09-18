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

    public func forToday(_ date: Date = Date()) -> [Plan] {
        let (start, _) = DateHelper.startAndEndOf(date)
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
    
    /// Create and return a new plan
    /// - Parameters:
    ///   - date: Date
    ///   - jobs: Set<Job>
    ///   - tasks: Set<LogTask>
    ///   - notes: Set<Note>
    ///   - projects: Set<Project>
    ///   - companies: Set<Company>
    ///   - estimatedScore Int64
    /// - Returns: Plan
    public func createAndReturn(date: Date, jobs: Set<Job>, tasks: Set<LogTask>, notes: Set<Note>, projects: Set<Project>, companies: Set<Company>) -> Plan {
        let plan = Plan(context: self.moc!)
        plan.id = UUID()
        plan.created = date
        plan.jobs = NSSet(set: jobs)
        plan.tasks = NSSet(set: tasks)
        plan.notes = NSSet(set: notes)
        plan.projects = NSSet(set: projects)
        plan.companies = NSSet(set: companies)

        PersistenceController.shared.save()
        return plan
    }

    /// Create a new plan object
    /// - Parameters:
    ///   - date: Date
    ///   - jobs: Set<Job>
    ///   - tasks: Set<LogTask>
    ///   - notes: Set<Note>
    ///   - projects: Set<Project>
    ///   - companies: Set<Company>
    /// - Returns: Void
    public func create(date: Date, jobs: Set<Job>, tasks: Set<LogTask>, notes: Set<Note>, projects: Set<Project>, companies: Set<Company>) -> Void {
        let _ = createAndReturn(
            date: date,
            jobs: jobs,
            tasks: tasks,
            notes: notes,
            projects: projects,
            companies: companies
        )
    }
    
    /// Delete all plans for a specified date
    /// - Parameter date: Date
    /// - Returns: Void
    public func deleteAll(for date: Date) -> Void {
        let plans = CoreDataPlan(moc: self.moc!).forToday(date)
        for plan in plans {
            plan.jobs = []
            plan.tasks = []
            plan.notes = []
            plan.projects = []
            plan.companies = []
            
            do {
                try plan.validateForDelete()
                self.moc!.delete(plan)

                PersistenceController.shared.save()
            } catch {
                print("[error] CoreDataPlan.deleteAll Unable to delete all plans for date \(date)")
            }
        }
    }

    public func score(_ plan: Plan) -> Int {
        return 0
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
