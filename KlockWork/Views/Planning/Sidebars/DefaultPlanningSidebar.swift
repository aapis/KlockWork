//
//  DefaultPlanningSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-24.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct DefaultPlanningSidebar: View {
    @EnvironmentObject public var nav: Navigation
    @State public var date: Date = Date()
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

extension DefaultPlanningSidebar {
    private func createToolbar() -> Void {
        self.tabs = Home.standardSidebarWidgets
    }
}
