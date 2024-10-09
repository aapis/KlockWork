//
//  WidgetLibrary.UI.Sidebar.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

extension WidgetLibrary.UI {
    struct Sidebar {
        struct EventsWidget: View {
            @EnvironmentObject public var state: Navigation
            @EnvironmentObject public var updater: ViewUpdater
            @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
            @AppStorage("today.calendar") public var calendar: Int = -1
            @State private var upcomingEvents: [EKEvent] = []
            @State private var calendarName: String = ""

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(self.upcomingEvents.sorted(by: {$0.startDate < $1.startDate}), id: \.self) { event in
                        SidebarItem(
                            data: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                            help: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                            icon: "chevron.right",
                            orientation: .right,
                            action: {},
                            showBorder: false,
                            showButton: false
                        )
//                        HStack {
//                            let hasPassed = event.startDate >= Date()
//                            Image(systemName: hasPassed ? "arrow.right" : "checkmark")
//                                .padding(.leading, 10)
//                            HStack {
//                                Text("\(event.startTime()) - \(event.endTime()):")
//                                Text(event.title)
//                            }
//                                .foregroundColor(hasPassed ? .white : .gray)
//                                .multilineTextAlignment(.leading)
//                        }
                    }
                }
                .foregroundStyle((self.state.session.job?.backgroundColor ?? .clear).isBright() ? Theme.lightBase : Theme.lightWhite)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.calendar) { self.actionOnChangeCalendar() }
                .id(updater.get("dashboard.header"))
            }
        }
    }
}

extension WidgetLibrary.UI.Sidebar.EventsWidget {
    /// Onload handler. Sets calendar name and upcoming events when fired.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let chosenCalendar = ce.selectedCalendar() {
            self.calendarName = chosenCalendar
            self.upcomingEvents = ce.events(chosenCalendar)
        }
    }
    
    /// Fires when calendar changes to update the view with new events
    /// - Returns: Void
    private func actionOnChangeCalendar() -> Void {
        let calendars = CoreDataCalendarEvent(moc: self.state.moc).getCalendarsForPicker()
        let calendarChanged = calendars.first(where: ({$0.tag == self.calendar})) != nil
        if calendarChanged {
            updater.updateOne("dashboard.header")
        }
    }
}
