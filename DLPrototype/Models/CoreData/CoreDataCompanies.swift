//
//  CoreDataCompanies.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-23.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataCompanies: ObservableObject {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    public func all() -> [Company] {
        return query()
    }

    public func unowned() -> [Company] {
        return query(
            NSPredicate(format: "projects.@count < 1")
        )
    }

    private func query(_ predicate: NSPredicate? = nil) -> [Company] {
        var results: [Company] = []
        let fetch: NSFetchRequest<Company> = Company.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Company.createdDate, ascending: false)]

        if predicate != nil {
            fetch.predicate = predicate
        }

        do {
            results = try moc!.fetch(fetch)
        } catch {
            if predicate != nil {
                print("[error] CoreDataCompanies.query Unable to find records for predicate \(predicate!.predicateFormat)")
            } else {
                print("[error] CoreDataCompanies.query Unable to find records for query")
            }
        }

        return results
    }
}
