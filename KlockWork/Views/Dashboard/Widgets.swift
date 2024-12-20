//
//  Widgets.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct Widgets: View {
    typealias UI = WidgetLibrary.UI
    @AppStorage("dashboard.widget.thisweek") public var showWidgetThisWeek: Bool = true
    @AppStorage("dashboard.widget.thismonth") public var showWidgetThisMonth: Bool = true
    @AppStorage("dashboard.widget.thisyear") public var showWidgetThisYear: Bool = true
    @AppStorage("dashboard.widget.intro") public var showWidgetIntro: Bool = true
    @AppStorage("dashboard.widget.upcomingWork") public var showWidgetUpcomingWork: Bool = true
    @AppStorage("dashboard.widget.recentSearches") public var showRecentSearches: Bool = true

    private var columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 100)), count: 3)

    var body: some View {
        VStack(alignment: .leading) {
            UI.ListLinkTitle(text: "Widgets")
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .leading) {
                    if showWidgetThisWeek {
                        ThisWeek()
                    }

                    if showWidgetThisMonth {
                        ThisMonth()
                    }

                    if showWidgetThisYear {
                        ThisYear()
                    }
                    
                    if showWidgetIntro {
                        IntroToKlockWork()
                    }

                    if showWidgetUpcomingWork {
                        UpcomingWork()
                    }

                    if showRecentSearches {
                        RecentSearches.Widget()
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Theme.textBackground)
        .clipShape(.rect(cornerRadius: 5))
    }
}
