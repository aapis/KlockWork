//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct Dashboard: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("dashboard.showRecentSearchesAboveResults") private var showRecentSearchesAboveResults: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                FindDashboard(location: .content)
            }
            .padding()
            Spacer()
            if !self.showRecentSearchesAboveResults {
                UI.AppFooter(
                    view: AnyView(
                        UI.LinkList(location: .content, isSearching: false)
                    )
                )
            }
        }
        .background(
            ZStack {
                self.state.session.appPage.primaryColour.saturation(0.7)
                Theme.base.blendMode(.softLight).opacity(0.5)
            }
        )
    }
}
