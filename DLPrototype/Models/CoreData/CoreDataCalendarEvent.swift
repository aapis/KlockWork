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


public class CoreDataCalendarEvent: ObservableObject {
    public var moc: NSManagedObjectContext?

    private let lock = NSLock()
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }

    public func all() -> [CalendarEvent] {
        return query(NSPredicate(format: "eid > 0"))
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

    public func truncate() -> Void {
        for cevent in all() {
            delete(cevent)
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
