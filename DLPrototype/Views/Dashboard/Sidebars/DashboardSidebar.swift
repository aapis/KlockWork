//
//  DashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DashboardSidebar: View {
    @State public var date: Date = Date()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                Title(text: "Dashboard")
                TodayInHistoryWidget()
                JobsWidget()
            }
            Spacer()
        }
        .padding()
    }
}
