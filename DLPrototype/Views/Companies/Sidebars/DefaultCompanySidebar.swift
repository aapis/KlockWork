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
        ]
    }
}
