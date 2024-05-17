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
    @AppStorage("dashboard.widget.thisweek") public var showWidgetThisWeek: Bool = true
    @AppStorage("dashboard.widget.thismonth") public var showWidgetThisMonth: Bool = true
    @AppStorage("dashboard.widget.thisyear") public var showWidgetThisYear: Bool = true
    @AppStorage("dashboard.widget.intro") public var showWidgetIntro: Bool = true
    
    var body: some View {
        Form {
            Picker("Max number of days in history:", selection: $maxYearsPastInHistory) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("5").tag(5)
                Text("10").tag(10)
            }

            Section("Widgets") {
                Toggle("This week", isOn: $showWidgetThisWeek)
                Toggle("This month", isOn: $showWidgetThisMonth)
                Toggle("This year", isOn: $showWidgetThisYear)
                Toggle("Introduction to KlockWork", isOn: $showWidgetIntro)
            }
        }
        .padding(20)
    }
}
