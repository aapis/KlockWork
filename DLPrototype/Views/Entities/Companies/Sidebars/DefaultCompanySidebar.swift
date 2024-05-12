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
                FancyGenericToolbar(buttons: tabs, standalone: true, location: .sidebar, mode: .compact)
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
                helpText: "Companies & Projects",
                icon: "menucard",
                labelText: "Outline",
                contents: AnyView(OutlineWidget())
            )
        ]
    }
}
