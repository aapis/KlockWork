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
    @State private var calendarStripVisible: Bool = true
    @State private var currentDate: String = ""

    @AppStorage("today.startOfDay") public var startOfDay: Int = 9
    @AppStorage("today.endOfDay") public var endOfDay: Int = 18

    @EnvironmentObject public var ce: CoreDataCalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack {
                Text("Events for \(currentDate)")
                    .font(Theme.fontCaption)
                    .padding(5)

                Spacer()
                FancyButton(text: calendarStripVisible ? "Hide Calendar" : "Show Calendar", action: showHide, icon: calendarStripVisible ? "arrowtriangle.up" : "arrowtriangle.down", showLabel: false)
            }
            .background(Theme.toolbarColour)

            if calendarStripVisible {
                ScrollView {
                    HStack(spacing: 0) {
                        ForEach(startOfDay..<endOfDay, id: \.self) { time in
                            ZStack {
                                (currentBlock == time ? Theme.footerColour : Theme.darkBtnColour)

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
                                            if let title = chip.title {
                                                let sd = chip.startDate.formatted(date: .omitted, time: .shortened)
                                                let ed = chip.endDate.formatted(date: .omitted, time: .shortened)
                                                let twelveHrTime = time - 12
                                                // Aligns events with the appropriate start time column
                                                if sd.starts(with: "\(time)") || sd.starts(with: "\(twelveHrTime)") {
                                                    GridRow(alignment: .top) {
                                                        Text("\(sd)-\(ed)\n\(title)")
                                                            .padding(5)
                                                            .background(Theme.rowStatusGreen)
                                                            .padding([.bottom, .top], 5)
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                }
                                            }
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
                                            if let title = chip.title {
                                                let sd = chip.startDate.formatted(date: .omitted, time: .shortened)
                                                let ed = chip.endDate.formatted(date: .omitted, time: .shortened)
                                                let twelveHrTime = time - 12
                                                // Aligns events with the appropriate start time column
                                                // TODO: change to loop that iterates over each houly time slot instead of this startswith shit
                                                if sd.starts(with: "\(time)") || sd.starts(with: "\(twelveHrTime)") {
                                                    GridRow(alignment: .top) {
                                                        Text("\(sd)-\(ed)\n\(title)")
                                                            .padding(5)
                                                            .background(Theme.rowStatusYellow)
                                                            .padding([.bottom, .top], 5)
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                }
                                            }
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
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
            }
        }
        .onAppear(perform: createEventChips)
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
        // runs onAppear
        updateChips()
        // runs on interval
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            updateChips()

            print("[debug.timer] Today().CalendarToday.createEventChips run")
        }
    }

    private func showHide() -> Void {
        withAnimation {
            calendarStripVisible.toggle()
        }
    }
}

struct CalendarTodayPreview: PreviewProvider {
    static var previews: some View {
        CalendarToday()
            .environmentObject(CoreDataCalendarEvent(moc: PersistenceController.preview.container.viewContext))
    }
}
