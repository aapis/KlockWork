//
//  PeopleDashboadSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-03.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct PeopleDashboardSidebar: View {
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FancyGenericToolbar(
                buttons: tabs,
                standalone: true,
                location: .sidebar,
                mode: .compact
            )
        }
        .onAppear(perform: createToolbar)
    }
}

extension PeopleDashboardSidebar {
    private func createToolbar() -> Void {
        self.tabs = Home.standardSidebarWidgets
    }
}
