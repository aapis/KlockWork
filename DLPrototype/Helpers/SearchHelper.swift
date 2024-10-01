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

    public func exec(_ searchText: Binding<String>) -> [LogTask] {
        return bucket.filter({
            matches(searchText, fields: [$0.content ?? "", $0.owner!.jid.string])
        })
    }
    
    public func findInProjects(_ searchText: Binding<String>) -> [Project] {
        return projectBucket.filter {
            matches(searchText, fields: [$0.name!, $0.pid.string])
        }
    }
    
    public func findInNotes(_ searchText: Binding<String>) -> [Note] {
        return noteBucket.filter {
            matches(searchText, fields: [$0.title!, $0.body!])
        }
    }
    
    public func findInRecords(_ searchText: Binding<String>) -> [LogRecord] {
        return recordBucket.filter {
            matches(searchText, fields: [$0.message!])
        }
    }

    public func findInCompanies(_ searchText: Binding<String>, allowHidden: Bool = false) -> [Company] {
        return companyBucket.filter {
            matches(searchText, fields: [$0.name!]) && $0.hidden == allowHidden
        }
    }

    public func findInDefinitions(_ searchText: Binding<String>) -> [TaxonomyTermDefinitions] {
        return definitionsBucket.filter {
            matches(searchText, fields: [$0.definition!, $0.term!.name!])
        }
    }

//    static public func highlight(phrase: String, bucket: [String]) -> [String] {
//        
//    }
    
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
