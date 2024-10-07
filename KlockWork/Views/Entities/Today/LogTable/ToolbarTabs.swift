//
//  Toolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

// @TODO: delete this once LogTable is deprecated/replaced with LogTableRedux
struct ToolbarTabs: View {
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        HStack(spacing: 1) {
            ForEach(TodayViewTab.allCases, id: \.self) { tab in
                FancyTab(tab: tab)
            }
        }
    }
}
