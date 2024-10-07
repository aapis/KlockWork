//
//  Tab.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-24.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

public enum TodayViewTab: CaseIterable {
    case chronologic, grouped, summarized, calendar
    
    var icon: String {
        switch self {
        case .chronologic:
            return "tray.fill"
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
            return "Sorted by time, ascending"
        case .grouped:
            return "Grouped by job ID"
        case .summarized:
            return "Summarized results"
        case .calendar:
            return "Today's events"
        }
    }
    
    var title: String {
        switch self {
        case .chronologic: return "Chronologic"
        case .grouped: return "Grouped"
        case .summarized: return "Summarized"
        case .calendar: return "Events"
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
    
    var view: AnyView {
        switch self {
        case .chronologic:
            return AnyView(Today.LogTable.TabContent.Chronologic())
        case .grouped:
            return AnyView(Today.LogTable.TabContent.Grouped())
        case .summarized:
            return AnyView(Today.LogTable.TabContent.Summarized())
        case .calendar:
            return AnyView(Today.LogTable.TabContent.Calendar())
        }
    }
    
    var button: ToolbarButton {
        ToolbarButton(
            id: self.id,
            helpText: self.help,
            icon: self.icon,
            labelText: self.title,
            contents: self.view
        )
    }
}
