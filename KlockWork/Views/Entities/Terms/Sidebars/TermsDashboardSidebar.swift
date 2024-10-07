//
//  TermDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct TermsDashboardSidebar: View {
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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

extension TermsDashboardSidebar {
    private func createToolbar() -> Void {
        self.tabs = Home.standardSidebarWidgets
    }
}
