//
//  DefaultCompanySidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DefaultCompanySidebar: View {
    @State private var tabs: [ToolbarButton] = []
    @State private var searching: Bool = false

    @EnvironmentObject public var nav: Navigation

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

extension DefaultCompanySidebar {
    private func createToolbar() -> Void {
        tabs = [
            ToolbarButton(
                id: 0,
                helpText: "Data outline",
                label: AnyView(
                    HStack {
                        Image(systemName: "menucard").padding(.leading)
                        Text("Outline")
                    }
                ),
                contents: AnyView(OutlineWidget())
            ),
            ToolbarButton(
                id: 1,
                helpText: "Search",
                label: AnyView(
                    HStack {
                        Image(systemName: "magnifyingglass").padding(.leading)
                        Text("Search")
                    }
                ),
                contents: AnyView(
                    VStack(alignment: .leading) {
                        FindDashboard(searching: $searching, location: .sidebar)
                    }
                    .padding(8)
                    .background(Theme.base.opacity(0.2))
                )
            )
        ]
    }
}
