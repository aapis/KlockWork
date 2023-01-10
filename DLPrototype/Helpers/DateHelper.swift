//
//  DateHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

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
    
    static public func yesterday() -> CVarArg{
        return DateHelper.daysPast(1)
    }
    
    static public func twoDays() -> CVarArg{
        return DateHelper.daysPast(2)
    }
    
    static public func daysPast(_ numDays: Double) -> CVarArg{
        let date = Date() - (86400 * numDays)

        return Calendar.current.startOfDay(for: date) as CVarArg
    }
    
    static public func todayShort(_ date: Date? = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "MST")
        formatter.locale = NSLocale.current
        
        return formatter.string(from: date!)
    }
    
    static public func shortDate(_ date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "MST")
        formatter.locale = NSLocale.current
        
        return formatter.date(from: date)
    }
    
    static public func shortDateWithTime(_ date: Date? = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        formatter.timeZone = TimeZone(abbreviation: "MST")
        formatter.locale = NSLocale.current
        
        return formatter.string(from: date!)
    }
    
    static public func date(_ date: String, fmt: String? = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = fmt
        formatter.timeZone = TimeZone(abbreviation: "MST")
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
                fmt.timeZone = TimeZone(abbreviation: "MST")
                fmt.locale = NSLocale.current
                
                let fmtComputedDay = fmt.string(from: computedDay!)
                
                dates.append(fmtComputedDay)
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
        let fin = date + 86399
        
        return (start, fin)
    }
}
