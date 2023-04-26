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
    
    var body: some View {
        Form {
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
