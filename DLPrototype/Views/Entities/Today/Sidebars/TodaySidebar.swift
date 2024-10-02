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
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    @EnvironmentObject public var nav: Navigation

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

extension TodaySidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Find resources",
                icon: "globe.americas",
                labelText: "Resources",
                contents: AnyView(JobsWidgetRedux())
            )
        ]
    }
}
