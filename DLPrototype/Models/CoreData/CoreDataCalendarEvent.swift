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
import CoreData

public enum CalendarEventType: String, CaseIterable {
    case inProgress = "In Progress"
    case upcoming = "Upcoming"
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
    
    public func save(events: [EKEvent], type: CalendarEventType) -> [CalendarEvent] {
        var calendarEvents: [CalendarEvent] = []

        for event in events {
            calendarEvents.append(self.save(event: event, type: type))
        }

        return calendarEvents
    }

    public func save(event: EKEvent, type: CalendarEventType) -> CalendarEvent {
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
            if #available(macOS 14.0, *) {
                requestFullAccessToEvents()
            } else {
                requestAccess()
            }
        case .authorized, .fullAccess, .writeOnly:
            events = callback(calendar)
            break
        case .restricted, .denied:
            break

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
            if #available(macOS 14.0, *) {
                requestFullAccessToEvents()
            } else {
                requestAccess()
            }
        case .authorized, .fullAccess, .writeOnly:
            events = callback(ekCalendar!)
            break
        case .restricted, .denied: break

        @unknown default:
            fatalError()
        }

        return events
    }

    public func eventsInProgress(_ calendarName: String) -> [EKEvent] {
        return find(calendar: calendarName) { calendar in
            let existingEvents = self.byType(.inProgress)
            var ekEvents = self.inProgress(calendar)

            for (index, ev) in ekEvents.enumerated() {
                if let title = ev.title {
                    for existingEv in existingEvents {
                        if let eTitle = existingEv.title {
                            if title == eTitle {
                                ekEvents.remove(at: index)
                            }
                        }
                    }
                }
            }

//            let _ = self.store(events: ekEvents, type: .inProgress)

            return ekEvents
        }
    }

    public func eventsUpcoming(_ calendarName: String) -> [EKEvent] {
        return find(calendar: calendarName) { calendar in
            let existingEvents = self.byType(.upcoming)
            var ekEvents = self.upcoming(calendar)

            for (index, ev) in ekEvents.enumerated() {
                if let title = ev.title {
                    for existingEv in existingEvents {
                        if let eTitle = existingEv.title {
                            if title == eTitle {
                                ekEvents.remove(at: index)
                            }
                        }
                    }
                }
            }

            return ekEvents
        }
    }

    public func events(_ calendarName: String) -> [EKEvent] {
        return self.findInCalendar(calendar: calendarName) { calendar in
            return self.eventsForDay(calendar)
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
        return store.calendars(for: .event).sorted(by: {$0.title <= $1.title})
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

    @available(macOS, deprecated: 13.4, obsoleted: 13.5, message: "EK API changed in macOS 14")
    public func requestAccess(_ callback: EKEventStoreRequestAccessCompletionHandler? = nil) -> Void {
        if callback != nil {
            store.requestAccess(to: EKEntityType.event, completion: callback!)
        } else {
            store.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
                if !accessGranted {
                    print("[warning] User denied/ignored calendar permission prompt")
                }
            }
        }
    }

    @available(macOS 14.0, *)
    public func requestFullAccessToEvents(_ callback: EKEventStoreRequestAccessCompletionHandler? = nil) -> Void {
        if callback != nil {
            store.requestFullAccessToEvents(completion: callback!)
        } else {
            store.requestFullAccessToEvents { (accessGranted, error) in
                if !accessGranted {
                    print("[warning] User denied/ignored calendar permission prompt")
                }
            }
        }
    }

    private func eventsForDay(_ calendar: EKCalendar) -> [EKEvent] {
        let now = Date()
        let (start, end) = DateHelper.startAndEndOf(now)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar])
        let events = store.events(matching: predicate)

        return events.filter {
            !$0.isAllDay && $0.status != .canceled && !$0.title.contains(try! Regex("Busy").ignoresCase())
        }
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
