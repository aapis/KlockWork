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

    var body: some View {
        Form {
            Picker("Max number of days", selection: $numPastDates) {
                Text("7").tag(7)
                Text("10").tag(10)
                Text("20").tag(20)
                Text("30").tag(30)
                Text("40").tag(40)
            }
        }
        .padding(20)
    }
}

struct TodaySettingsPreview: PreviewProvider {
    static var previews: some View {
        TodaySettings()
    }
}
