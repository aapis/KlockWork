//
//  TodaySettings.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-16.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct TodaySettings: View {
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    @EnvironmentObject public var nav: Navigation
    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    @AppStorage("today.viewMode") public var viewMode: Int = 0
    @AppStorage("today.numWeeks") public var numWeeks: Int = 2
    @AppStorage("today.recordGrouping") public var recordGrouping: Int = 0
    @AppStorage("today.calendar") public var calendar: Int = -1
    @AppStorage("today.calendar.hasAccess") public var hasAccess: Bool = false
    @AppStorage("today.startOfDay") public var startOfDay: Int = 9
    @AppStorage("today.endOfDay") public var endOfDay: Int = 18
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnExtendedTimestamp") public var showColumnExtendedTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
    @AppStorage("today.maxCharsPerGroup") public var maxCharsPerGroup: Int = 2000
    @AppStorage("today.colourizeExportableGroupedRecord") public var colourizeExportableGroupedRecord: Bool = false
    @State private var calendars: [CustomPickerItem] = []

    var body: some View {
        Form {
            Section("All tabs") {

                
                Picker("Default view mode", selection: $viewMode) {
                    Text("Full").tag(1)
                    Text("Plain").tag(2)
                }


                Section("Display columns") {
                    Toggle("Index", isOn: $showColumnIndex)
                    Toggle("Timestamp", isOn: $showColumnTimestamp)
                    Toggle("Extended timestamp", isOn: $showColumnExtendedTimestamp)
                    Toggle("Job ID", isOn: $showColumnJobId)
                    Divider()
                }

                Section("Grouped tab settings") {
                    Picker("Maximum number of characters per group", selection: $maxCharsPerGroup) {
                        Text("100").tag(100)
                        Text("1000").tag(1000)
                        Text("2000").tag(2000)
                        Text("3000").tag(3000)
                        Text("4000").tag(4000)
                    }

                    Toggle("Colourize grouped data records", isOn: $colourizeExportableGroupedRecord)
                }

            }

            Section("Calendar and Date Settings") {
                Picker("Start of your work day", selection: $startOfDay) {
                    ForEach(0..<12) { start in
                        Text("\(start) AM").tag(start)
                    }
                }

                Picker("End of your work day", selection: $endOfDay) {
                    ForEach(12..<24) { start in
                        if start == 12 {
                            Text("\(start) PM").tag(start)
                        } else {
                            Text("\(start - 12) PM").tag(start)
                        }
                    }
                }

                VStack(alignment: .trailing) {
                    if hasAccess && calendars.count > 0 {
                        Picker("Active calendar", selection: $calendar) {
                            ForEach(calendars, id: \.self) { item in
                                Text(item.title).tag(item.tag)
                            }
                        }
                    } else {
                        Button("Request access to calendar") {
                            if #available(macOS 14.0, *) {
                                ce.requestFullAccessToEvents({(granted, error) in
                                    hasAccess = granted
                                    onAppear()
                                })
                            } else {
//                                ce.requestAccess({(granted, error) in
//                                    hasAccess = granted
//                                    onAppear()
//                                })
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() -> Void {
        if #available(macOS 14.0, *) {
            ce.requestFullAccessToEvents({(granted, error) in
                if granted {
                    calendars = CoreDataCalendarEvent(moc: self.nav.moc).getCalendarsForPicker()
                } else {
                    print("[error][calendar] m14 No calendar access")
                    print("[error][calendar] \(error.debugDescription)")
                }
            })
        } else {
//            ce.requestAccess({(granted, error) in
//                if granted {
//                    calendars = CoreDataCalendarEvent(moc: moc).getCalendarsForPicker()
//                } else {
//                    print("[error][calendar] No calendar access")
//                    print("[error][calendar] \(error.debugDescription)")
//                }
//            })
        }
    }
}

struct TodaySettingsPreview: PreviewProvider {
    static var previews: some View {
        TodaySettings()
    }
}
