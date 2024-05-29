//
//  DateHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public struct IdentifiableDay: Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    public var string: String = ""
    public var date: Date?
    public var recordCount: Int = 0
}

public struct DateBounds {
    public var upper: Date
    public var lower: Date
}

final public class DateHelper {
    // Returns string like 2020-06-11 representing a date, for use in filtering
    static public func thisAm() -> CVarArg {
        let date = Date()

        return Calendar.current.startOfDay(for: date) as CVarArg
    }
    
    static public func tomorrow() -> CVarArg {
        let date = Date() + 86400

        return Calendar.current.startOfDay(for: date) as CVarArg
    }
    
    static public func yesterday() -> CVarArg {
        return DateHelper.daysPast(1)
    }
    
    static public func twoDays() -> CVarArg {
        return DateHelper.daysPast(2)
    }
    
    static public func daysPast(_ numDays: Double) -> CVarArg {
        let date = Date() - (86400 * numDays)

        return Calendar.current.startOfDay(for: date) as CVarArg
    }
    
    /// Returns a list of date objects representing the numDays prior to from
    /// - Parameter numDays: Double
    /// - Parameter from: Date
    /// - Returns: Array<Date>
    static public func prior(numDays: Int, from: Date) -> [Date] {
        var entries: [Date] = []

        for idx in 0...numDays {
            let dblIndex = Double(idx)
            let entry = from - (86400 * (dblIndex + 1.0)) // first list item is yesterday
            entries.append(entry)
        }

        return entries
    }

    static public func todayShort(_ date: Date? = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = NSLocale.current
        
        return formatter.string(from: date!)
    }
    
    static public func shortDate(_ date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = NSLocale.current
        
        return formatter.date(from: date)
    }

    static public func shortDateWithTime(_ date: Date? = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = NSLocale.current
        
        return formatter.string(from: date!)
    }
    
    static public func longDate(_ timestamp: Date) -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone.autoupdatingCurrent 
        df.locale = NSLocale.current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: timestamp)
    }
    
    static public func date(_ date: String, fmt: String? = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = fmt
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = NSLocale.current
        
        return formatter.date(from: date)
    }
    
    static public func dateFromRecord(_ record: LogRecord) -> String {
        return DateHelper.todayShort(record.timestamp!)
    }
    
    static public func datesBeforeToday(numDays: Int, dateFormat: String? = "yyyy-MM-dd") -> [String] {
        var dates: [String] = []
        
        for i in 0...numDays {
            var components = DateComponents()
            components.day = -(1*i)
            let computedDay = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())

            if computedDay != nil {
                let fmt = DateFormatter()
                fmt.dateFormat = dateFormat
                fmt.timeZone = TimeZone.autoupdatingCurrent
                fmt.locale = NSLocale.current
                
                let fmtComputedDay = fmt.string(from: computedDay!)
                
                dates.append(fmtComputedDay)
            }
        }

        return dates
    }

    static public func dateObjectsBeforeToday(_ numDays: Int, dateFormat: String? = "yyyy-MM-dd", moc: NSManagedObjectContext) -> [IdentifiableDay] {
        var dates: [IdentifiableDay] = []
        let cdr = CoreDataRecords(moc: moc)

        // negative values result in that many days in the future being included in the list
        for i in -2...numDays {
            var components = DateComponents()
            components.day = -(1*i)


            if let computedDay = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date()) {
                let fmt = DateFormatter()
                fmt.dateFormat = dateFormat
                fmt.timeZone = TimeZone.autoupdatingCurrent
                fmt.locale = NSLocale.current

                let fmtComputedDay = fmt.string(from: computedDay)

                let identifiable = IdentifiableDay(
                    string: fmtComputedDay,
                    date: computedDay,
                    recordCount: cdr.countForDate(computedDay)
                )

                dates.append(identifiable)
            }
        }

        return dates
    }

    static public func identifiedDate(for date: Date, moc: NSManagedObjectContext) -> IdentifiableDay {
        let cdr = CoreDataRecords(moc: moc)
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone.autoupdatingCurrent
        fmt.locale = NSLocale.current

        let fmtComputedDay = fmt.string(from: date)

        let identifiable = IdentifiableDay(
            string: fmtComputedDay,
            date: date,
            recordCount: cdr.countForDate(date)
        )
        return identifiable
    }
    
    static public func datesAround(_ date: Date) -> (Date, Date) {
        let before = date - 86400
        let after = date + 86400
        
        return (before, after)
    }
    
    static public func startAndEndOf(_ date: Date) -> (Date, Date) {
        let start = Calendar.autoupdatingCurrent.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1

        return (
            start,
            Calendar.autoupdatingCurrent.date(byAdding: components, to: start)!
        )
    }

    static public func bounds(_ date: Date) -> DateBounds {
        let start = Calendar.autoupdatingCurrent.startOfDay(for: date)
        var sComponents = DateComponents()
        sComponents.day = -7

        let end = Calendar.autoupdatingCurrent.startOfDay(for: date)
        var eComponents = DateComponents()
        eComponents.day = +7

        return DateBounds(
            upper: Calendar.autoupdatingCurrent.date(byAdding: sComponents, to: start)!,
            lower: Calendar.autoupdatingCurrent.date(byAdding: eComponents, to: end)!
        )
    }
    
    /// Determine the start of the month for a given Date object
    /// - Parameter date: Date
    /// - Returns: Optional(Date)
    static public func startOfMonth(for date: Date) -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month], from: date)
        let sComponents = DateComponents(year: components.year, month: components.month, day: 1)

        return calendar.date(from: sComponents)
    }
    
    /// Determine the last day of the month for a given Date object
    /// - Parameter date: Date
    /// - Returns: Optional(Date)
    static public func endOfMonth(for date: Date) -> Date? {
        if let start = self.startOfMonth(for: date) {
            return Calendar.autoupdatingCurrent.date(byAdding: DateComponents(month: 1, day: -1), to: start)
        }

        return nil
    }

    /// Create date objects for days at the start and end of the provided month
    /// - Parameter date: Date
    /// - Returns: Optional(Date, Date)
    static public func datesAtStartAndEndOfMonth(for date: Date) -> (Date, Date)? {
        let start = self.startOfMonth(for: date)
        let end = self.endOfMonth(for: date)

        if (start != nil && end != nil) {
            return (start!, end!)
        }

        return nil
    }
    
    /// Find days at the beginning and end of the CURRENT month
    /// - Returns: Optional((CVarArg, CVarArg))>
    static public func dayAtStartAndEndOfMonth() -> (CVarArg, CVarArg)? {
        if let dates = DateHelper.datesAtStartAndEndOfMonth(for: Date()) {
            return (dates.0 as CVarArg, dates.1 as CVarArg)
        }

        return nil
    }

    /// Checks to see if the selected date is the current day
    /// - Parameter day: IdentifiableDay
    /// - Returns: Bool
    static public func isCurrentDay(_ day: IdentifiableDay) -> Bool {
        let currentDay = Date.now.timeIntervalSince1970
        if let date = day.date {
            let rowDay = date.timeIntervalSince1970
            let window = (currentDay - 86400, currentDay + 84600)

            return rowDay > window.0 && rowDay <= window.1
        }

        return false
    }
}
