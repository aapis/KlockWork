//
//  DashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DashboardSidebar: View {
    @State private var tabs: [ToolbarButton] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                FancyGenericToolbar(buttons: tabs, standalone: true, location: .sidebar)
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: createToolbar)
    }
}

extension DashboardSidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Today in history",
                label: AnyView(
                    HStack {
                        Image(systemName: "calendar").padding(.leading)
                        Text("History")
                    }
                ),
                contents: AnyView(TodayInHistoryWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Companies & Projects",
                label: AnyView(
                    HStack {
                        Image(systemName: "menucard").padding(.leading)
                        Text("Outline")
                    }
                ),
                contents: AnyView(OutlineWidget())
            ),
        ]
    }
}
