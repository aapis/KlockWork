//
//  RecentSearches.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct RecentSearches: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("dashboard.widget.recentSearches") public var showRecentSearches: Bool = true
    public let title: String = "Recent Searches"
    public var page: PageConfiguration.AppPage = .find
    @State private var forecast: [Forecast] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)", fgColour: .white)
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: self.actionOnCloseWidget,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true,
                    size: .tiny,
                    type: .clear
                )
            }
            .padding()
            .background(Theme.darkBtnColour)

            ForEach(self.forecast, id: \.id) { row in row }
        }
        .background(self.state.session.appPage.primaryColour)
//        .frame(height: 250)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension RecentSearches {
    /// Onload handler. Creates forecast
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }

    private func actionOnForecastTap() -> Void {

    }

    private func actionOnCloseWidget() -> Void {
        
    }
}
