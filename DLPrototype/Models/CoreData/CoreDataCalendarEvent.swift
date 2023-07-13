//
//  CoreDataCalendarEvent.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

public enum CalendarEventType: String, CaseIterable {
    case inProgress = "In Progress"
    case upcoming = "Upcoming"
    case records = "Records"

    var colour: Color {
        switch (self) {
        case .inProgress:
            return Theme.rowStatusGreen
        case .upcoming:
            return Theme.rowStatusYellow
        case .records:
            return Theme.rowColour
        }
    }
}

public enum CalendarEventStatus {
    case joined, cancelled, ended
}

public class CoreDataCalendarEvent: ObservableObject {
    public var moc: NSManagedObjectContext?
    public var store: EKEventStore = EKEventStore()

    private let lock = NSLock()

    @AppStorage("today.calendar") public var calendar: Int = -1
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    public func selectedCalendar() -> String? {
        if calendar > -1 {
            return getCalendarName(calendar)
        }

        return nil
    }

    public func all() -> [CalendarEvent] {
        return query(NSPredicate(format: "eid > 0"))
    }

    public func byType(_ type: CalendarEventType) -> [CalendarEvent] {
        return query(NSPredicate(format: "type = %@", "\(type)"))
    }
    
    public func store(events: [EKEvent], type: CalendarEventType) -> [CalendarEvent] {
        var calendarEvents: [CalendarEvent] = []

        for event in events {
            calendarEvents.append(self.store(event: event, type: type))
        }

        return calendarEvents
    }

    public func store(event: EKEvent, type: CalendarEventType) -> CalendarEvent {
        let entity = CalendarEvent(context: moc!)
        entity.id = UUID()
        entity.eid = Int64(event.hash)
        entity.startDate = event.startDate!
        entity.endDate = event.endDate!
        entity.interactionDate = Date()
        entity.status = String(event.status.rawValue)
        entity.title = event.title
        entity.type = "\(type)"

        persist()

        return entity
    }

    public func delete(_ event: CalendarEvent) -> Void {
        moc!.delete(event)
    }

    public func truncate(_ type: CalendarEventType? = nil) -> Void {
        if let selectedType = type {
            for cevent in byType(selectedType) {
                delete(cevent)
            }
        } else {
            for cevent in all() {
                delete(cevent)
            }
        }
    }

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

    public func findInCalendar(calendar: String, _ callback: (EKCalendar) -> [EKEvent]) -> [EKEvent] {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        var events: [EKEvent] = []
        let ekCalendar = getCalendar(calendar)

        if ekCalendar == nil {
            return []
        }

        switch (status) {
        case .notDetermined:
            requestAccess()
        case .authorized:
            events = callback(ekCalendar!)
            break
        case .restricted, .denied: break

        @unknown default:
            fatalError()
        }

        return events
    }

    public func eventsInProgress(_ calendarName: String, at: Int? = nil) -> [EKEvent] {
        return find(calendar: calendarName) { calendar in
            return  self.inProgress(calendar, block: at)
        }
    }

    public func eventsUpcoming(_ calendarName: String) -> [EKEvent] {
        return find(calendar: calendarName) { calendar in
            return self.upcoming(calendar)
        }
    }

    public func events(_ calendarName: String) -> [EKEvent] {
        return self.findInCalendar(calendar: calendarName) { calendar in
            return self.eventsForDay(calendar)
        }
    }

    // TODO: move to CoreDataRecord
    public func plotRecords(_ records: [LogRecord]) -> [EKEvent] {
        var evRecords: [EKEvent] = []

        for (index, record) in records.enumerated() {
//            let ev = DLPEKEvent(eventStore: store, colour: Color.fromStored(record.job?.colour ?? Theme.rowColourAsDouble))
            let ev = EKEvent(eventStore: store)
            ev.startDate = record.timestamp
            ev.title = record.job?.jid.string
            var next: Int = index - 1

            // TODO: a bunch of work needs to happen here to plot records as blocks of time

            ev.endDate = records.indices.contains(next) ? records[next].timestamp : record.timestamp


            evRecords.append(ev)
        }
        
        return evRecords
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

    private func eventsForDay(_ calendar: EKCalendar) -> [EKEvent] {
        let now = Date()
        let (start, end) = DateHelper.startAndEndOf(now)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar])
        let events = store.events(matching: predicate)

        return events
    }

    private func inProgress(_ calendarName: String, block: Int? = nil) -> [EKEvent] {
        var eventsInProgress: [EKEvent] = []
        let now = Date()
        var (start, end) = DateHelper.startAndEndOf(now)

        if block != nil {
            start = DateHelper.dateForHour(block!) ?? start
            end = DateHelper.dateForHour(block! + 1) ?? end
        }

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

    private func persist() -> Void {
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }

    private func query(_ predicate: NSPredicate) -> [CalendarEvent] {
        lock.lock()

        var results: [CalendarEvent] = []
        let fetch: NSFetchRequest<CalendarEvent> = CalendarEvent.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \CalendarEvent.startDate, ascending: true)]
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
}
