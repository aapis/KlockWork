//
//  TodaySettings.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-16.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TodaySettings: View {
    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    @AppStorage("today.viewMode") public var viewMode: Int = 0
    @AppStorage("today.numWeeks") public var numWeeks: Int = 2
    @AppStorage("today.recordGrouping") public var recordGrouping: Int = 0
    @AppStorage("today.relativeJobList") public var allowRelativeJobList: Bool = false
    @AppStorage("showSidebar") public var showSidebar: Bool = true
    @AppStorage("showTodaySearch") public var showSearch: Bool = true
    @AppStorage("today.ltd.tasks.all") public var showAllJobsInDetailsPane: Bool = false
    @AppStorage("today.calendar") public var calendar: Int = -1
    @AppStorage("today.startOfDay") public var startOfDay: Int = 9
    @AppStorage("today.endOfDay") public var endOfDay: Int = 18
    @AppStorage("today.defaultTableSortOrder") private var defaultTableSortOrder: String = "DESC"
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
    @AppStorage("today.showColumnActions") public var showColumnActions: Bool = false
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
    
    @State private var calendars: [CustomPickerItem] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        Form {
            Picker("Max number of days", selection: $numPastDates) {
                Text("7").tag(7)
                Text("10").tag(10)
                Text("20").tag(20)
                Text("30").tag(30)
                Text("40").tag(40)
            }
            
            Picker("Default view mode", selection: $viewMode) {
                Text("Full").tag(1)
                Text("Plain").tag(2)
            }

            Picker("Default sort direction:", selection: $defaultTableSortOrder) {
                Text("DESC").tag("DESC")
                Text("ASC").tag("ASC")
            }
            
            Group {
                Toggle("Dynamic job pickers", isOn: $allowRelativeJobList)
                
                if allowRelativeJobList {
                    Picker("How many weeks", selection: $numWeeks) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("6").tag(6)
                        Text("8").tag(8)
                    }
                }
            }
            
            Toggle("Show sidebar", isOn: $showSidebar)
            Toggle("Show search on Today", isOn: $showSearch)
            Toggle("Include all incomplete tasks in details pane", isOn: $showAllJobsInDetailsPane)
            
            Group {
                Picker("Records grouped by", selection: $recordGrouping) {
                    Text("Chronologic").tag(0)
                    Text("Grouped").tag(1)
                    Text("Summarized").tag(2)
                }
                Divider()
            }

            Section("Display columns") {
                Toggle("Index", isOn: $showColumnIndex)
                Toggle("Timestamp", isOn: $showColumnTimestamp)
                Toggle("Job ID", isOn: $showColumnJobId)
                Toggle("Actions (EXPERIMENTAL)", isOn: $showColumnActions).disabled(!showExperimentalFeatures) // TODO: future feature
                Divider()
            }

            Section("Calendar and Date Settings") {
                Picker("Start of your work day", selection: $startOfDay) {
                    ForEach(3..<12) { start in
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

                Picker("Active calendar", selection: $calendar) {
                    ForEach(calendars, id: \.self) { item in
                        Text(item.title).tag(item.tag)
                    }
                }
            }
        }
        .padding(20)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() -> Void {
        calendars = CoreDataCalendarEvent(moc: moc).getCalendarsForPicker()
    }
}

struct TodaySettingsPreview: PreviewProvider {
    static var previews: some View {
        TodaySettings()
    }
}
