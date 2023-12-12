//
//  DefaultPlanningSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-24.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DefaultPlanningSidebar: View {
    @State public var date: Date = Date()

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                AllJobsPickerWidget(location: .content)
            }
            Spacer()
        }
        .padding()
    }
}

extension TodaySidebar {
    // TODO: use one of the date helpers instead!
    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: nav.session.date)
    }
}
