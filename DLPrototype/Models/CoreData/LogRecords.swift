//
//  LogRecords.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

class LogRecords: ObservableObject, Identifiable, Equatable {
    public var moc: NSManagedObjectContext?
    public var id = UUID()
    
    @Published public var recordsForToday: [LogRecord] = []
    
    public init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    static func == (lhs: LogRecords, rhs: LogRecords) -> Bool {
        return lhs.id == rhs.id
    }
    
    static public func todayFromFetched(results: FetchedResults<LogRecord>) -> [Entry] {
        var entries: [Entry] = []

        for record in results {
            let timestamp = LogRecords.timestampToString(record.timestamp!)
            let job = String(record.job?.jid.string ?? "No ID")
            
            entries.append(Entry(timestamp: timestamp, job: job, message: record.message!))
        }
        
        return entries
    }
    
    static public func timestampToString(_ timestamp: Date) -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "MST")
        df.locale = NSLocale.current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: timestamp)
    }
    
    public func fromToday() -> Void {
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: true)]
        fetch.predicate = NSPredicate(format: "timestamp > %@", DateHelper.thisAm())
        
        do {
            recordsForToday = try moc!.fetch(fetch)
        } catch {
            print("Unable to find records for today")
        }
    }
    
//    public func today() -> [Entry]? {
//        if let results = fromToday() {
//            return asEntries(results)
//        }
//
//        return nil
//    }
    
    public func asEntries(_ records: [LogRecord]) -> [Entry] {
        var entries: [Entry] = []
        
        for record in records {
            let timestamp = LogRecords.timestampToString(record.timestamp!)
            let job = String(record.job?.jid.string ?? "No ID")
            
            entries.append(Entry(timestamp: timestamp, job: job, message: record.message!))
        }
        
        return entries
    }
}
