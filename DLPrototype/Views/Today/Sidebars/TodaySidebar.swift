//
//  TodaySidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TodaySidebar: View {
    @State public var date: Date = Date()

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Spacer()
//                    FancyButtonv2(
//                        text: "Settings",
//                        action: {},
//                        icon: "gear",
//                        showLabel: false,
//                        type: .white
//                    )
//                    .frame(width: 30, height: 30)
                }
                JobPickerWidget()
                TasksWidget()
            }
            Spacer()
        }
        .padding()
    }
}

extension TodaySidebar {
    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: nav.session.date)
    }
}
