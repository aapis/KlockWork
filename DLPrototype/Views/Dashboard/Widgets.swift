//
//  Widgets.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct WidgetLoading: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
    }
}

struct Widgets: View {
    @AppStorage("dashboard.widget.thisweek") public var showWidgetThisWeek: Bool = true
    @AppStorage("dashboard.widget.thismonth") public var showWidgetThisMonth: Bool = true
    @AppStorage("dashboard.widget.thisyear") public var showWidgetThisYear: Bool = true
    @AppStorage("dashboard.widget.intro") public var showWidgetIntro: Bool = true

    private var columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 100)), count: 3)

    var body: some View {
        VStack(alignment: .leading) {
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
                }

                Spacer()
            }
        }
    }
}
