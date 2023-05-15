//
//  CalendarService.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

public enum CalendarEventType {
    case inProgress, upcoming
}

// TODO: combine with CoreDataCalendarEvent
final public class CalendarService {
    public var store: EKEventStore = EKEventStore()
    
    private var inProgress: [EKEvent] = []
    
    public func find(calendar: String, _ callback: (String) -> [EKEvent]) -> [EKEvent] {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        var events: [EKEvent] = []

        switch (status) {
        case .notDetermined:
            requestAccess()
        case .authorized:
            events = callback(calendar)
            break
        case .restricted, .denied: break
            
        @unknown default:
            fatalError()
        }
        
        return events
    }
    
    public func eventsInProgress(_ calendarName: String, _ ce: CoreDataCalendarEvent) -> [EKEvent] {
        return find(calendar: calendarName) { calendar in
            let events = self.inProgress(calendar)
            let _ = ce.store(events: events, type: .upcoming)

            return events
        }
    }
    
    public func eventsUpcoming(_ calendarName: String, _ ce: CoreDataCalendarEvent) -> [EKEvent] {
        return find(calendar: calendarName) { calendar in
            let events = self.upcoming(calendar)
            let _ = ce.store(events: events, type: .upcoming)

            return events
        }
    }
    
    public func getCalendar(_ calendarName: String) -> EKCalendar? {
        for calendar in getCalendars() {
            if calendarName == calendar.title {
                return calendar
            }
        }
        
        return nil
    }
    
    public func getCalendarName(_ id: Int) -> String? {
        for item in getCalendarsForPicker() {
            if id == item.tag {
                return item.title
            }
        }
        
        return nil
    }
    
    public func getCalendars() -> [EKCalendar] {
        return store.calendars(for: .event)
    }
    
    public func getCalendarsForPicker() -> [CustomPickerItem] {
        var pickerItems: [CustomPickerItem] = []
        var id = 0;
        
        for calendar in getCalendars() {
            pickerItems.append(CustomPickerItem(title: calendar.title, tag: id))
            id += 1
        }
        
        return pickerItems
    }
    
    private func inProgress(_ calendarName: String) -> [EKEvent] {
        var eventsInProgress: [EKEvent] = []
        let now = Date()
        let (start, end) = DateHelper.startAndEndOf(now)
        let calendar = getCalendar(calendarName)
        
        if calendar != nil {
            let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar!])
            let events = store.events(matching: predicate)
            let df = DateFormatter()
            df.timeZone = TimeZone.autoupdatingCurrent
            df.locale = NSLocale.current
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for event in events {
                if !event.isAllDay {
                    let sDate = df.string(from: event.startDate!)
                    let eDate = df.string(from: event.endDate!)
                    let fmtNow = df.string(from: now)

                    if sDate <= fmtNow && eDate >= fmtNow {
                        eventsInProgress.append(event)
                    }
                }
            }
        }
        
        return eventsInProgress
    }
    
    private func upcoming(_ calendarName: String) -> [EKEvent] {
        var upcomingEvents: [EKEvent] = []
        let now = Date()
        let (start, end) = DateHelper.startAndEndOf(now)
        let calendar = getCalendar(calendarName)
        
        if calendar != nil {
            let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar!])
            let events = store.events(matching: predicate)
            let df = DateFormatter()
            df.timeZone = TimeZone.autoupdatingCurrent
            df.locale = NSLocale.current
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for event in events {
                if !event.isAllDay {
                    let sDate = df.string(from: event.startDate!)
                    let fmtNow = df.string(from: now)
                    
                    if sDate >= fmtNow {
                        upcomingEvents.append(event)
                    }
                }
            }
        }
        
        return upcomingEvents
    }
    
    private func requestAccess() -> Void {
        store.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            if !accessGranted {
                print("[warning] User denied/ignored calendar permission prompt")
            }
        }
    }
}
