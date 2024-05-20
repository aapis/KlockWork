//
//  CoreDataRecords.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

// TODO: rename this to something else. Currently meant to represent how many 15 minute periods a task intersected
// TODO: with, rate is the percent of the total number of sections per day
public struct Intersection {
    public var index: Int = 0
    public var rate: Float = 0.0

    @AppStorage("today.startOfDay") public var startOfDay: Int = 9
    @AppStorage("today.endOfDay") public var endOfDay: Int = 18

    public init(start: LogRecord, end: LogRecord) {
        let billablePeriodsToday = (endOfDay - startOfDay) * 4
        let dates = [start, end].map { $0!.timestamp! }
        let intersection = Int((dates.first!.timeIntervalSince1970 - dates.last!.timeIntervalSince1970) / 900)

        index = intersection
        rate = Float(intersection) / Float(billablePeriodsToday) * 100
    }
}

public class CoreDataRecords: ObservableObject {
    public var moc: NSManagedObjectContext?
    
    private let lock = NSLock()

    @AppStorage("general.syncColumns") public var syncColumns: Bool = false
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    static public func softDelete(_ record: LogRecord) -> Void {
        record.alive = false
        PersistenceController.shared.save()
    }

//    static public func hardDelete(_ record: LogRecord) -> (() -> Void) {
//        let cb: (() -> Void)
//
//        CoreDataRecords.softDelete(record)
//        PersistenceController.shared.delete(record)
//
//        return cb
//    }

    static public func fetchForDate(_ date: Date, limit: Int? = 10) -> FetchRequest<LogRecord> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)
        ]

        let (start, end) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "alive == true && (timestamp > %@ && timestamp <= %@) && job.project.company.hidden == false",
            start as CVarArg,
            end as CVarArg
        )
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }
    
    static public func fetchSummarizedForDate(_ date: Date, limit: Int? = 10) -> FetchRequest<LogRecord> {
        let descriptors = [
            NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)
        ]

        let (start, end) = DateHelper.startAndEndOf(date)
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "@message.count > 0 && alive == true && (timestamp > %@ && timestamp <= %@) && job.project.company.hidden == false",
            start as CVarArg,
            end as CVarArg
        )
        fetch.sortDescriptors = descriptors

        if let lim = limit {
            fetch.fetchLimit = lim
        }

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
    }

    static public func fetchRecent() -> FetchRequest<LogRecord> {
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)
        ]

        let date = DateHelper.daysPast(14)

        fetch.predicate = NSPredicate(
            format: "(alive == true && timestamp >= %@) && job.project.company.hidden == false",
            date
        )

        return FetchRequest(fetchRequest: fetch, animation: .easeInOut)
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
    
    public func createWithJobAndReturn(job: Job, date: Date, text: String) -> LogRecord {
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
        
        return record
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
            format: "timestamp > %@ && job.project.company.hidden == false",
            cutoff
        )
        
        return query(predicate)
    }
    
    public func recent(_ start: CVarArg, _ end: CVarArg) -> [LogRecord] {
        let predicate = NSPredicate(
            format: "(timestamp > %@ && timestamp <= %@) && job.project.company.hidden == false",
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
            if let jerb = rec.job {
                jobs.append(jerb.jid)
            }
        }
        
        let jobSet: Set = Set(jobs)
        
        return jobSet.count
    }

    public func countAll() -> Int {
        let predicate = NSPredicate(
            format: "alive == true && job.project.company.hidden == false"
        )

        return count(predicate)
    }
    
    public func forDate(_ date: Date) -> [LogRecord] {
        let (start, end) = DateHelper.startAndEndOf(date)
        let predicate = NSPredicate(
            format: "(alive == true && timestamp > %@ && timestamp <= %@) && job.project.company.hidden == false",
            start as CVarArg,
            end as CVarArg
        )
        
        return query(predicate)
    }
    
    public func countForDate(_ date: Date? = nil) -> Int {
        if let d = date {
            let (start, end) = DateHelper.startAndEndOf(d)
            let predicate = NSPredicate(
                format: "(timestamp > %@ && timestamp <= %@) && job.project.company.hidden == false",
                start as CVarArg,
                end as CVarArg
            )

            return count(predicate)
        }

        return 0
    }
    
    public func weeklyStats(after: (() -> Void)? = nil) async -> (Int, Int, Int) {
        let recordsInPeriod = await waitForRecent(1)
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            if let callback = after {
                callback()
            }
        }

        return (wc, jc, recordsInPeriod.count)
    }
    
    public func monthlyStats(after: (() -> Void)? = nil) async -> (Int, Int, Int) {
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
            if let callback = after {
                callback()
            }
        }
        
        return (wc, jc, recordsInPeriod.count)
    }
    
    public func yearlyStats(after: (() -> Void)? = nil) async -> (Int, Int, Int) {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        let recordsInPeriod = await waitForRecent(Double(currentWeek))
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            if let callback = after {
                callback()
            }
        }
        
        return (wc, jc, recordsInPeriod.count)
    }

    public func calculateBillablePeriodIntersections(_ groupedRecords: [Dictionary<Job?, [LogRecord]>.Element]) -> [Intersection] {
        var intersections: [Intersection] = []

        for group in groupedRecords {
            if group.key != nil {
                if group.value.count > 0 {
                    intersections.append(Intersection(start: group.value.first!, end: group.value.last!))
                }
            }
        }
        return intersections
    }

    public func createExportableRecordsFrom(_ records: [LogRecord], grouped: Bool? = false) -> String {
        if grouped! {
            return exportableGroupedRecordsAsString(records).0
        }

        return exportableRecords(records)
    }

#if os(macOS)
    public func createExportableGroupedRecordsAsViews(_ records: [LogRecord]) -> [FancyStaticTextField] {
        var views: [FancyStaticTextField] = []

        let gr = exportableGroupedRecordsAsString(records)
        let groupedRecords = gr.0.split(separator: "\t\n")
        var i = 0

        for group in groupedRecords {
            views.append(
                FancyStaticTextField(
                    placeholder: "Records...",
                    lineLimit: 10,
                    text: String(group),
                    intersection: gr.1[i],
                    project: gr.2[i],
                    job: gr.3[i]
                )
            )

            i += 1
        }

        views = views.sorted(by: ({$0.intersection.index > $1.intersection.index}))

        return views
    }
#endif

    private func exportableGroupedRecordsAsString(_ records: [LogRecord]) -> (String, [Intersection], [Project], [Job]) {
        var buffer = ""
        let groupedRecords = Dictionary(grouping: records, by: {$0.job}).sorted(by: {
            if $0.key != nil && $1.key != nil {
                return $0.key!.jid > $1.key!.jid
            }
            return false
        })
        var projects: [Project] = []
        var jobs: [Job] = []

        for group in groupedRecords {
            if group.key != nil {
                let jid = String(Int(group.key!.jid))
                let shredable = group.key!.shredable ? " (SR&ED)" : ""

                if group.key!.uri != nil {
                    buffer += "\(jid)\(shredable): \(group.key!.uri!.absoluteString)\n"
                } else {
                    buffer += "\(jid)\n"
                }

                for record in group.value {
                    // column.index intentionally not supported in grouped exports
                    // column.jobId intentionally not supported in group exports
                    if syncColumns && showColumnTimestamp {
                        buffer += " - \(record.timestamp!)"
                    }

                    buffer += " - \(record.message!)\n"
                }

                buffer += "\t\n" // specifically added to allow split in createExportableGroupedRecordsAsViews

                projects.append(group.key!.project!)
                jobs.append(group.key!)
            }
        }

        return (
            buffer,
            calculateBillablePeriodIntersections(groupedRecords),
            projects,
            jobs
        )
    }

    private func exportableRecords(_ records: [LogRecord]) -> String {
        if records.count == 0 {
            return ""
        }

        var buffer = ""
        var i = 0

        for item in records {
            if let job = item.job {
                let cleaned = CoreDataProjectConfiguration.applyBannedWordsTo(item)

                if let ignoredJobs = job.project?.configuration?.ignoredJobs {
                    if !ignoredJobs.contains(job.jid.string) {
                        let shredableMsg = job.shredable ? " (SR&ED)" : ""
                        var jobSection = ""
                        var line = ""

                        if syncColumns && showColumnIndex {
                            jobSection += " \(String(Int(job.jid)))"
                            line += "\(i) - "
                        } else {
                            jobSection += String(Int(job.jid))
                        }

                        if syncColumns && showColumnJobId {
                            if let uri = job.uri {
                                jobSection += " - \(uri.absoluteString)" + shredableMsg
                            } else {
                                jobSection += shredableMsg
                            }
                        }

                        if syncColumns && showColumnTimestamp {
                            line += "\(item.timestamp!)"
                            line += " - \(jobSection)"
                        } else {
                            line += jobSection
                        }

                        if line.count > 0 {
                            line += " - \(cleaned.message!)\n"
                        } else {
                            line += "\(cleaned.message!)\n"
                        }


                        buffer += line
                    }
                }
            }

            i += 1
        }

        return buffer
    }
    
    private func query(_ predicate: NSPredicate) -> [LogRecord] {
        lock.lock()

        var results: [LogRecord] = []
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)]
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
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: false)]
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
