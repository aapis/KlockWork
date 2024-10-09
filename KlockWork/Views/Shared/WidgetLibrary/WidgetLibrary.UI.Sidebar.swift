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
            typealias Event = WidgetLibrary.UI.Individual.Event
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
                            Event(event: event)
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
