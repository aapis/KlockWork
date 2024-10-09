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
                    if self.calendar > 0 {
                        ForEach(self.upcomingEvents.sorted(by: {$0.startDate < $1.startDate}), id: \.self) { event in
                            SingleEvent(event: event)
                        }
                    } else {
                        HStack(alignment: .center, spacing: 0) {
                            Text("No calendar selected. Choose one under Settings > Today > Active calendar.")
                            Spacer()
                        }
                        .padding()
                        .background(Theme.textBackground)
                        .foregroundStyle(Theme.lightWhite)
                    }
                }
                .foregroundStyle((self.state.session.job?.backgroundColor ?? .clear).isBright() ? Theme.lightBase : Theme.lightWhite)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.calendar) { self.actionOnChangeCalendar() }
                .id(updater.get("dashboard.header"))
            }
        }

        struct SingleEvent: View {
            @EnvironmentObject public var state: Navigation
            public let event: EKEvent
            @State private var hasEventPassed: Bool = false

            var body: some View {
                SidebarItem(
                    data: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                    help: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                    icon: "chevron.right",
                    orientation: .right,
                    action: {},
                    showBorder: false,
                    showButton: false
                )
                .background(self.hasEventPassed ? Theme.lightWhite : .orange)
                .foregroundStyle(self.hasEventPassed ? Theme.lightBase : Theme.base)
                .onAppear(perform: self.actionOnAppear)
            }
        }
    }
}

extension WidgetLibrary.UI.Sidebar.SingleEvent {
    /// Onload handler. Determines if event has passed or not
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.hasEventPassed = event.startDate < Date()
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
