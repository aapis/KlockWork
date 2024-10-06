//
//  DashboardSettings.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct DashboardSettings: View {
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
    @AppStorage("dashboard.maxDaysUpcomingWork") public var maxDaysUpcomingWork: Double = 5
    @AppStorage("dashboard.widget.thisweek") public var showWidgetThisWeek: Bool = true
    @AppStorage("dashboard.widget.thismonth") public var showWidgetThisMonth: Bool = true
    @AppStorage("dashboard.widget.thisyear") public var showWidgetThisYear: Bool = true
    @AppStorage("dashboard.widget.intro") public var showWidgetIntro: Bool = true
    @AppStorage("dashboard.widget.upcomingWork") public var showWidgetUpcomingWork: Bool = true

    var body: some View {
        Form {
            Section("Widgets") {
                Toggle("This week", isOn: $showWidgetThisWeek)
                Toggle("This month", isOn: $showWidgetThisMonth)
                Toggle("This year", isOn: $showWidgetThisYear)
                Toggle("Introduction to KlockWork", isOn: $showWidgetIntro)
                Toggle("Upcoming Work", isOn: $showWidgetUpcomingWork)
            }

            if self.showWidgetUpcomingWork {
                Picker("Number of days to preview", selection: $maxDaysUpcomingWork) {
                    Text("1").tag(Double(1))
                    Text("2").tag(Double(2))
                    Text("3").tag(Double(3))
                    Text("5").tag(Double(5))
                    Text("10").tag(Double(10))
                }
            }

            Picker("Max number of days in history:", selection: $maxYearsPastInHistory) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("5").tag(5)
                Text("10").tag(10)
            }
        }
        .padding(20)
    }
}
