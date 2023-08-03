//
//  Toolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public enum Tab: CaseIterable {
    case chronologic, grouped, summarized, calendar
    
    var icon: String {
        switch self {
        case .chronologic:
            return "tray.2.fill"
        case .grouped:
            return "square.grid.3x1.fill.below.line.grid.1x2"
        case .summarized:
            return "star.circle.fill"
        case .calendar:
            return "calendar"
        }
    }
    
    var id: Int {
        switch self {
        case .chronologic:
            return 0
        case .grouped:
            return 1
        case .summarized:
            return 2
        case .calendar:
            return 3
        }
    }
    
    var help: String {
        switch self {
        case .chronologic:
            return "Chronologic"
        case .grouped:
            return "Grouped by job ID"
        case .summarized:
            return "Summarized"
        case .calendar:
            return "Today's events"
        }
    }
    
    var description: String {
        switch self {
        case .chronologic:
            return "Shows records in chronological order, sorted by timestamp"
        case .grouped:
            return "Groups records by job ID, sorted by timestamp"
        case .summarized:
            return "Shows only relevant records, sorted by timestamp"
        case .calendar:
            return "Events happening today"
        }
    }
}

struct ToolbarTabs: View {
    @Binding public var selectedTab: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(Tab.allCases, id: \.self) { tab in
                FancyTab(tab: tab, selected: $selectedTab)
            }
        }
    }
}
