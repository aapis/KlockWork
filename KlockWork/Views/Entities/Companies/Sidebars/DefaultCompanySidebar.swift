//
//  DefaultCompanySidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct DefaultCompanySidebar: View {
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FancyGenericToolbar(buttons: tabs, standalone: true, location: .sidebar, mode: .compact)
        }
        .onAppear(perform: createToolbar)
    }
}

extension DefaultCompanySidebar {
    private func createToolbar() -> Void {
        self.tabs = Home.standardSidebarWidgets
    }
}
