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
//
//                FancyButtonv2(
//                    text: "New Note",
//                    action: {},
//                    showLabel: true,
//                    size: .large,
//                    type: .white
//                )
                TodayInHistoryWidget()
            }
            Spacer()
        }
        .padding()
    }
}
