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

    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header()
            VStack(alignment: .leading, spacing: 0) {
                FindDashboard(searching: $searching)
                FancyDivider()

                if !searching {
                    Widgets()
                        .environmentObject(crm)
                        .environmentObject(ce)
                }
            }
            .font(Theme.font)
            .padding()
            .background(Theme.toolbarColour)
        }
    }
}

extension Dashboard {

}

extension Dashboard {
    struct Header: View {
        @State private var upcomingEvents: [EKEvent] = []
        @State private var calendarName: String = ""
        
        @EnvironmentObject public var nav: Navigation
        @EnvironmentObject public var ce: CoreDataCalendarEvent

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
//                        FancyDivider()

                        if calendar > -1 {
                            HStack {
                                Image(systemName: "calendar")
                                Text("You have \(upcomingEvents.count) meetings today")
                                    .font(Theme.font)
                            }
                            .padding(5)

                            if upcomingEvents.count <= 3 {
                                VStack(alignment: .leading) {
                                    ForEach(upcomingEvents, id: \.self) { event in
                                        HStack {
                                            Image(systemName: "arrow.right")
                                                .padding(.leading, 15)
                                            Text("\(event.title) at \(event.startTime())")
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
}
