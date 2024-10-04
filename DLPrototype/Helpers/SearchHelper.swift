//
//  SearchHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: replace this entire class with "CONTAINS[c]" predicates
public final class SearchHelper {
    public var bucket: [LogTask] = [] // TODO: make this class+prop generic
    public var projectBucket: [Project] = []
    public var noteBucket: [Note] = []
    public var recordBucket: [LogRecord] = []
    public var companyBucket: [Company] = []
    public var definitionsBucket: [TaxonomyTermDefinitions] = []
    public var peopleBucket: [Person] = []
    public var fields: [String] = []
    
    public init(bucket: FetchedResults<LogTask>) {
        self.bucket = Array(bucket)
    }
    
    public init(bucket: FetchedResults<Project>) {
        self.projectBucket = Array(bucket)
    }
    
    public init(bucket: FetchedResults<Note>) {
        self.noteBucket = Array(bucket)
    }
    
    public init(bucket: FetchedResults<LogRecord>) {
        self.recordBucket = Array(bucket)
    }

    public init(bucket: FetchedResults<Company>) {
        self.companyBucket = Array(bucket)
    }

    public init(bucket: [TaxonomyTermDefinitions]) {
        self.definitionsBucket = bucket
    }

    public init(bucket: [Person]) {
        self.peopleBucket = bucket
    }

    /// Find matching entities of type LogTask
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInTasks(_ searchText: Binding<String>) -> [LogTask] {
        return bucket.filter({
            matches(searchText, fields: [$0.content ?? "", $0.owner!.jid.string])
        })
    }

    /// Find matching entities of type Project
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInProjects(_ searchText: Binding<String>) -> [Project] {
        return projectBucket.filter {
            matches(searchText, fields: [$0.name!, $0.pid.string])
        }
    }

    /// Find matching entities of type Note
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInNotes(_ searchText: Binding<String>) -> [Note] {
        return noteBucket.filter {
            matches(searchText, fields: [$0.title!, $0.body!])
        }
    }

    /// Find matching entities of type LogRecord
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInRecords(_ searchText: Binding<String>) -> [LogRecord] {
        return recordBucket.filter {
            matches(searchText, fields: [$0.message!])
        }
    }
    /// Find matching entities of type Company
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInCompanies(_ searchText: Binding<String>, allowHidden: Bool = false) -> [Company] {
        return companyBucket.filter {
            matches(searchText, fields: [$0.name!]) && $0.hidden == allowHidden
        }
    }
    /// Find matching entities of type TaxonomyTermDefinitions
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInDefinitions(_ searchText: Binding<String>) -> [TaxonomyTermDefinitions] {
        return definitionsBucket.filter {
            matches(searchText, fields: [$0.definition!, $0.term!.name!])
        }
    }
    
    /// Find matching entities of type Person
    /// - Parameter searchText: Binding(String)
    /// - Returns: [NSManagedObject]
    public func findInPeople(_ searchText: Binding<String>) -> [Person] {
        return peopleBucket.filter {
            matches(searchText, fields: [$0.name!])
        }
    }
    
    private func matches(_ searchText: Binding<String>, fields: [String]) -> Bool {
        do {
            let caseInsensitiveTerm = try Regex(searchText.wrappedValue).ignoresCase()
            
            return fields.filter({
                $0.contains(caseInsensitiveTerm)
            }).count > 0
        } catch {
            print("[error] Searching LogTable::search(term: String) - Unable to process string \(error.localizedDescription)")
        }
        
        return false
    }
}
