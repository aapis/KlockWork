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
    public var selectedDate: Date
    public var records: [LogRecord]

    @State private var calendarItems: [EKEvent] = []
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

            ScrollView {
                HStack(spacing: 1) {
                    ForEach(startOfDay..<(endOfDay - 1), id: \.self) { currentHour in
                        ZStack {
                            (currentBlock == currentHour ? Theme.footerColour : Color.clear)

                            Grid(alignment: .topLeading) {
                                GridRow {
                                    if currentHour > 12 {
                                        Text(String(currentHour - 12) + " PM")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    } else if currentHour == 12 {
                                        Text(String(currentHour) + " PM")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    } else {
                                        Text(String(currentHour) + " AM")
                                            .font(Theme.fontCaption)
                                            .padding(5)
                                    }
                                }

                                GridRow {
                                    Divider()
                                }

                                ForEach(calendarItems, id: \.self) { chip in
                                    CalendarIndividualEvent(event: chip, currentHour: currentHour, type: .records)
                                }

                                Spacer()
                            }
                        }
//                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear(perform: createEventChips)
        .background(Theme.darkBtnColour)
    }

    private func updateChips() -> Void {
        ce.truncate()
        currentBlock = Calendar.current.component(.hour, from: selectedDate)
        currentDate = selectedDate.formatted(date: .abbreviated, time: .omitted)
        calendarItems = []

        let chosenCalendar = ce.selectedCalendar()

        calendarItems = (
            ce.eventsInProgress(chosenCalendar!, at: currentBlock) +
            ce.eventsUpcoming(chosenCalendar!) +
            ce.plotRecords(records)
        )
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

    private func eventsThisBlock(event: EKEvent) throws -> Bool {
        return true
    }
}

struct CalendarTodayPreview: PreviewProvider {
    static public var date: Date = Date()
    static public var records: [LogRecord] = []

    init(date: Date, records: [LogRecord]) {
        for _ in 1..<10 {
            let entity = LogRecord(context: PersistenceController.preview.container.viewContext)
            entity.message = "testing"
            entity.timestamp = Date()
            entity.id = UUID()

            CalendarTodayPreview.records.append(entity)
        }
    }
    
    static var previews: some View {
        CalendarToday(selectedDate: date, records: records)
            .environmentObject(CoreDataCalendarEvent(moc: PersistenceController.preview.container.viewContext))
    }
}
