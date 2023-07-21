//
//  CalendarToday.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-16.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

struct CalendarToday: View {
    @State private var inProgress: [EKEvent] = []
    @State private var upcoming: [EKEvent] = []
    @State private var currentBlock: Int = 0
    @State private var currentDate: String = ""
    @State private var timer: Timer? = nil

    @AppStorage("today.startOfDay") public var startOfDay: Int = 9
    @AppStorage("today.endOfDay") public var endOfDay: Int = 18

    @EnvironmentObject public var ce: CoreDataCalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Events for \(currentDate)")
                    .font(Theme.font)
                    .padding(5)
                Spacer()
            }
            .frame(height: 40)
            .background(Theme.headerColour)

            ScrollView(showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(startOfDay..<(endOfDay - 1), id: \.self) { time in
                        ZStack {
                            (currentBlock == time ? Theme.footerColour : Color.clear)

                            Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                                GridRow {
                                    if time > 12 {
                                        Text(String(time - 12) + " PM")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    } else if time == 12 {
                                        Text(String(time) + " PM")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    } else {
                                        Text(String(time) + " AM")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    }
                                }
                                GridRow {
                                    Divider()
                                }

                                if inProgress.count > 0 {
                                    GridRow(alignment: .top) {
                                        Text("In Progress")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    }
                                    GridRow {
                                        Divider()
                                    }

                                    ForEach(inProgress, id: \.self) { chip in
                                        CalendarIndividualEvent(event: chip, currentHour: time)
                                    }
                                }

                                if upcoming.count > 0 {
                                    FancyDivider()
                                    GridRow(alignment: .top) {
                                        Text("Upcoming")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    }
                                    GridRow {
                                        Divider()
                                    }
                                    ForEach(upcoming, id: \.self) { chip in
                                        CalendarIndividualEvent(event: chip, currentHour: time)
                                    }
                                }

                                if inProgress.count == 0 && upcoming.count == 0 {
                                    GridRow {
                                        Text("No events")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    }
                                }

                                Spacer()
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 10, maxWidth: .infinity, minHeight: 10, maxHeight: 200)
            
            Spacer()
        }
        .onAppear(perform: createEventChips)
        .background(Theme.darkBtnColour)
    }

    private func updateChips() -> Void {
        ce.truncate()
        currentBlock = Calendar.current.component(.hour, from: Date())
        currentDate = Date().formatted(date: .abbreviated, time: .omitted)
        inProgress = []
        upcoming = []

        let chosenCalendar = ce.selectedCalendar()

        inProgress = ce.eventsInProgress(chosenCalendar!)
        upcoming = ce.eventsUpcoming(chosenCalendar!)
    }

    private func createEventChips() -> Void {
        timer?.invalidate()
        // runs onAppear
        updateChips()
        // runs on interval
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            updateChips()

            print("[debug.timer] Today().CalendarToday.createEventChips run")
        }
    }
}

struct CalendarTodayPreview: PreviewProvider {
    static var previews: some View {
        CalendarToday()
            .environmentObject(CoreDataCalendarEvent(moc: PersistenceController.preview.container.viewContext))
    }
}
