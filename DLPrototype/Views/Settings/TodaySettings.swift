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
