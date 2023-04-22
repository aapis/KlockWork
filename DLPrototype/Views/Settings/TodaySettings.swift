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
    @AppStorage("today.relativeJobList") public var allowRelativeJobList: Bool = false
    @AppStorage("showSidebar") public var showSidebar: Bool = true
    @AppStorage("showTodaySearch") public var showSearch: Bool = true

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
        }
        .padding(20)
    }
}

struct TodaySettingsPreview: PreviewProvider {
    static var previews: some View {
        TodaySettings()
    }
}
