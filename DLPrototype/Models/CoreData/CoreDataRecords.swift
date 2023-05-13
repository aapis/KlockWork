//
//  CoreDataRecords.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataRecords: ObservableObject {
    public var moc: NSManagedObjectContext?
    
    private let lock = NSLock()
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func createWithJob(job: Job, date: Date, text: String) -> Void {
        let record = LogRecord(context: moc!)
        record.timestamp = date
        record.message = text
        record.id = UUID()
        record.job = job
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }
    
    public func waitForRecent(_ numWeeks: Double = 6) async -> [LogRecord] {
        return recent(numWeeks)
    }
    
    public func waitForRecent(_ start: CVarArg, _ end: CVarArg) async -> [LogRecord] {
        return recent(start, end)
    }
    
    public func recent(_ numWeeks: Double = 6) -> [LogRecord] {
        let cutoff = DateHelper.daysPast(numWeeks * 7)
        
        let predicate = NSPredicate(
            format: "timestamp > %@",
            cutoff
        )
        
        return query(predicate)
    }
    
    public func recent(_ start: CVarArg, _ end: CVarArg) -> [LogRecord] {
        let predicate = NSPredicate(
            format: "timestamp > %@ && timestamp <= %@",
            start,
            end
        )
        
        return query(predicate)
    }
    
    public func countWordsIn(_ records: [LogRecord]) -> Int {
        var words: [String] = []
        
        for rec in records {
            if rec.message != nil {
                words.append(rec.message!)
            }
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))
        
        return wordSet.count
    }
    
    public func countJobsIn(_ records: [LogRecord]) -> Int {
        var jobs: [Double] = []
        for rec in records {
            if rec.job != nil {
                jobs.append(rec.job!.jid)
            }
        }
        
        let jobSet: Set = Set(jobs)
        
        return jobSet.count
    }
    
    public func forDate(_ date: Date) -> [LogRecord] {
        let endDate = date - 86400
        let predicate = NSPredicate(
            format: "timestamp > %@ && timestamp < %@",
            date as CVarArg,
            endDate as CVarArg
        )
        
        return query(predicate)
    }
    
    public func countForDate(_ date: Date? = nil) -> Int {
        if date == nil {
            return 0
        }
        
        let endDate = (date ?? Date()) + 86400
        let predicate = NSPredicate(
            format: "timestamp > %@ && timestamp < %@",
            date! as CVarArg,
            endDate as CVarArg
        )
        
        return count(predicate)
    }
    
    public func weeklyStats(after: () -> Void) async -> (Int, Int, Int) {        
        let recordsInPeriod = await waitForRecent(1)
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            after()
        }

        return (wc, jc, recordsInPeriod.count)
    }
    
    public func monthlyStats(after: () -> Void) async -> (Int, Int, Int) {
        let (start, end) = DateHelper.dayAtStartAndEndOfMonth() ?? (nil, nil)
        var recordsInPeriod: [LogRecord] = []
        
        if start != nil && end != nil {
            recordsInPeriod = await waitForRecent(start!, end!)
        } else {
            // if start and end periods could not be determined, default to -4 weeks
            recordsInPeriod = await waitForRecent(4)
        }
        
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            after()
        }
        
        return (wc, jc, recordsInPeriod.count)
    }
    
    public func yearlyStats(after: () -> Void) async -> (Int, Int, Int) {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        let recordsInPeriod = await waitForRecent(Double(currentWeek))
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            after()
        }
        
        return (wc, jc, recordsInPeriod.count)
    }
    
    private func query(_ predicate: NSPredicate) -> [LogRecord] {
        lock.lock()

        var results: [LogRecord] = []
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true
        
        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataRecords.query Unable to find records for predicate \(predicate.predicateFormat)")
        }
        
        lock.unlock()
        
        return results
    }
    
    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()
        
        var count = 0
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true
        
        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataRecords.query Unable to find records for predicate \(predicate.predicateFormat)")
        }
        
        lock.unlock()
        
        return count
    }
}
