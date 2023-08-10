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
                Toggle("Show this week", isOn: $showWidgetThisWeek)
                Toggle("Show this month", isOn: $showWidgetThisMonth)
                Toggle("Show this year", isOn: $showWidgetThisYear)
            }
        }
        .padding(20)
    }
}
