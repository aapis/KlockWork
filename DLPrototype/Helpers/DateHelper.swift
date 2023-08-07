//
//  DateHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public struct IdentifiableDay: Identifiable {
    public var id: UUID = UUID()
    public var string: String = ""
    public var date: Date?
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
            let computedDay = Calendar.current.date(byAdding: components, to: Date())
            
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

    static public func dateObjectsBeforeToday(_ numDays: Int, dateFormat: String? = "yyyy-MM-dd") -> [IdentifiableDay] {
        var dates: [IdentifiableDay] = []

        for i in 0...numDays {
            var components = DateComponents()
            components.day = -(1*i)


            if let computedDay = Calendar.current.date(byAdding: components, to: Date()) {
                let fmt = DateFormatter()
                fmt.dateFormat = dateFormat
                fmt.timeZone = TimeZone.autoupdatingCurrent
                fmt.locale = NSLocale.current

                let fmtComputedDay = fmt.string(from: computedDay)

                let identifiable = IdentifiableDay(string: fmtComputedDay, date: computedDay)
                dates.append(identifiable)
            }
        }

        return dates
    }
    
    static public func datesAround(_ date: Date) -> (Date, Date) {
        let before = date - 86400
        let after = date + 86400
        
        return (before, after)
    }
    
    static public func startAndEndOf(_ date: Date) -> (Date, Date) {
        let start = Calendar.current.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1

        return (
            start,
            Calendar.current.date(byAdding: components, to: start)!
        )
    }
    
    static public func dayAtStartAndEndOfMonth() -> (CVarArg, CVarArg)? {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        let startOfMonth = calendar.date(from: components)
        
        if startOfMonth != nil {
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth!)
            
            if endOfMonth != nil {
                return (
                    startOfMonth! as CVarArg,
                    endOfMonth! as CVarArg
                )
            }
        }
        
        return nil
    }
}
