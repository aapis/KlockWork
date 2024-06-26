//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import EventKit

struct Dashboard: View {
    static public let id: UUID = UUID()

    @State public var searching: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    
    @FocusState private var primaryTextFieldInFocus: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header()
                .environmentObject(updater)

            VStack(alignment: .leading, spacing: 0) {
                FindDashboard(searching: $searching, location: .content)
                FancyDivider()

                if !searching {
                    Widgets()
                }
            }
            .font(Theme.font)
            .padding()
            .focused($primaryTextFieldInFocus)
            .background(Theme.toolbarColour)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.primaryTextFieldInFocus = true
                }
                
                isSearchStackShowing = false
            }
        }
    }
}

extension Dashboard {
    struct Header: View {
        @State private var upcomingEvents: [EKEvent] = []
        @State private var calendarName: String = ""

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation
        @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
        @EnvironmentObject public var updater: ViewUpdater

        @AppStorage("today.calendar") public var calendar: Int = -1

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.indigo
                    Color.black.opacity(0.8)
                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                        .opacity(0.6)
                        .blendMode(.softLight)

                    VStack(alignment: .leading) {
                        Title(text: "Welcome back!")

                        if calendar > -1 {
                            HStack {
                                Image(systemName: "calendar")

                                if upcomingEvents.count == 0 || upcomingEvents.count > 1 {
                                    Text("\(upcomingEvents.count) meetings today")
                                        .font(Theme.font)
                                } else {
                                    Text("\(upcomingEvents.count) meeting today")
                                        .font(Theme.font)
                                }
                            }
                            .padding(5)

                            if upcomingEvents.count <= 3 {
                                VStack(alignment: .leading) {
                                    ForEach(upcomingEvents, id: \.self) { event in
                                        HStack {
                                            let hasPassed = event.startDate >= Date()
                                            Image(systemName: hasPassed ? "arrow.right" : "checkmark")
                                                .padding(.leading, 15)
                                            Text("\(event.title) at \(event.startTime())")
                                                .foregroundColor(hasPassed ? .white : .gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: 150)
            .onAppear(perform: actionOnAppear)
            .onChange(of: calendar, perform: actionOnChangeCalendar)
            .id(updater.get("dashboard.header"))
        }
    }
}

extension Dashboard.Header {
    private func actionOnAppear() -> Void {
        if let chosenCalendar = ce.selectedCalendar() {
            calendarName = chosenCalendar
            upcomingEvents = ce.events(chosenCalendar)
        }
    }

    private func actionOnChangeCalendar(calendar: Int) -> Void {
        let calendars = CoreDataCalendarEvent(moc: moc).getCalendarsForPicker()
        let calendarChanged = calendars.first(where: ({$0.tag == calendar})) != nil
        if calendarChanged {
            updater.updateOne("dashboard.header")
        }
    }
}
