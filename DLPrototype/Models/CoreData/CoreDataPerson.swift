//
//  CoreDataPerson.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import CoreData

public class CoreDataPerson: ObservableObject {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()

    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    /// Find all people
    /// - Returns: FetchRequest<Person>
    static public func fetchAll() -> FetchRequest<Person> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Person.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "company != nil"
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find people who have been updated recently
    /// - Parameter numDaysPrior: How far back to look, 7 days by default
    /// - Returns: FetchRequest<Person>
    static public func fetchRecent(numDaysPrior: Double = 7) -> FetchRequest<Person> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Person.name?, ascending: true)
        ]

        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "lastUpdate >= %@",
            DateHelper.daysPast(numDaysPrior) as CVarArg
        )
        fetch.sortDescriptors = descriptors

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    /// Find people whose names match a given string
    /// - Parameter term: String
    /// - Returns: FetchRequest<Person>
    static public func fetchMatching(term: String) -> FetchRequest<Person> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Person.name, ascending: true)
        ]

        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "ANY name CONTAINS[c] %@",
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
    static public func fetch(for date: Date, limit: Int? = 10, daysPrior: Int = 7) -> FetchRequest<Person> {
        let descriptors = [
            NSSortDescriptor(keyPath: \Person.name?, ascending: true),
            NSSortDescriptor(keyPath: \Person.created, ascending: true)
        ]

        var predicate: NSPredicate
        let (start, end) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        if let rangeStart = DateHelper.prior(numDays: daysPrior, from: start).last {
            predicate = NSPredicate(
                format: "((created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@)) && company.hidden == false",
                rangeStart as CVarArg,
                end as CVarArg,
                rangeStart as CVarArg,
                end as CVarArg
            )
        } else {
            predicate = NSPredicate(
                format: "((created > %@ && created < %@) || (lastUpdate > %@ && lastUpdate < %@)) && company.hidden == false",
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

    public func byCompany(_ company: Company) -> [Person] {
        let predicate = NSPredicate(
            format: "company = %@",
            company as CVarArg
        )

        return query(predicate)
    }
    
    /// Find all people
    /// - Returns: Array<Person>
    public func all() -> [Person] {
        let predicate = NSPredicate(
            format: "name != nil"
        )

        return query(predicate)
    }

    /// Count of all people in the system
    /// - Returns: Int
    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "name != nil"
        )

        return count(predicate)
    }
    
    /// Create a new Person entity
    /// - Parameters:
    ///   - created: Date
    ///   - lastUpdate: Date
    ///   - name: String
    ///   - title: String
    ///   - company: Company
    ///   - saveByDefault: Bool(true)
    /// - Returns: Person
    public func create(created: Date, lastUpdate: Date, name: String, title: String, company: Company, saveByDefault: Bool = true) -> Void {
        let _ = self.make(
            created: created,
            lastUpdate: lastUpdate,
            name: name,
            title: title,
            company: company,
            saveByDefault: saveByDefault
        )
    }

    /// Create a new Person entity
    /// - Parameters:
    ///   - created: Date
    ///   - lastUpdate: Date
    ///   - name: String
    ///   - title: String
    ///   - company: Company
    ///   - saveByDefault: Bool(true)
    /// - Returns: Person
    public func createAndReturn(created: Date, lastUpdate: Date, name: String, title: String, company: Company, saveByDefault: Bool = true) -> Person {
        return self.make(
            created: created,
            lastUpdate: lastUpdate,
            name: name,
            title: title,
            company: company,
            saveByDefault: saveByDefault
        )
    }

    /// Create a new Person entity
    /// - Parameters:
    ///   - created: Date
    ///   - lastUpdate: Date
    ///   - name: String
    ///   - title: String
    ///   - company: Company
    ///   - saveByDefault: Bool(true)
    /// - Returns: Person
    private func make(created: Date, lastUpdate: Date, name: String, title: String, company: Company, saveByDefault: Bool = true) -> Person {
        let person = Person(context: self.moc!)
        person.created = created
        person.lastUpdate = lastUpdate
        person.id = UUID()
        person.name = name
        person.title = title
        person.company = company

        if saveByDefault {
            PersistenceController.shared.save()
        }

        return person
    }

    private func query(_ predicate: NSPredicate? = nil) -> [Person] {
        lock.lock()

        var results: [Person] = []
        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Person.name, ascending: true)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataPerson.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataPerson.query Unable to find records for query")
            }

            print(error)
        }

        lock.unlock()

        return results
    }

    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()

        var count = 0
        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Person.name, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true

        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataPerson.query Unable to find records for predicate \(predicate.predicateFormat)")
        }

        lock.unlock()

        return count
    }
}
