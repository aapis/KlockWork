//
//  ToolbarButtons.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct ToolbarButtons: View {
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var nav: Navigation
    @AppStorage("settings.accessibility.showSelectorLabels") private var showSelectorLabels: Bool = true
    public var records: [LogRecord]
    public var timelineActivities: [UI.GenericTimelineActivity]
    public var tab: TodayViewTab = .chronologic
    @State private var datePickerItems: [CustomPickerItem] = []
    @State private var pickerSelection: Int = 0
    @State private var highlighted: Bool = false

    init(records: [LogRecord], tab: TodayViewTab = .chronologic) {
        self.records = records
        self.tab = tab
        self.timelineActivities = []
    }

    init(timelineActivities: [UI.GenericTimelineActivity], tab: TodayViewTab = .chronologic) {
        self.timelineActivities = timelineActivities
        self.tab = tab
        self.records = []
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            self.nav.session.appPage.primaryColour
            LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                .opacity(0.3)
                .blendMode(.softLight)
                .frame(height: 20)
            HStack(alignment: .center) {
                if self.tab == .chronologic {
                    // @TODO: find a better way to exclude this button from activity feeds, this feels hacky
                    if self.nav.parent == .today {
                        UI.ViewModeSelector()
                    }
                    UI.SortSelector()
                    UI.Pagination.Widget()
                } else if self.tab == .grouped {
                    Text(self.tab.title)
                        .padding(6)
                        .background(Theme.textBackground)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .help(self.tab.help)
                }
                Spacer()
                UI.Buttons.ExportToCSV(
                    records: self.records,
                    timelineActivities: self.timelineActivities,
                    tab: "\(self.tab)"
                )
                if self.tab == .chronologic {
                    UI.Buttons.CopyRecordsToClipboard(records: self.records)
                }
            }
            .padding(8)
        }
    }

    private func change(selected: Int, sender: String?) -> Void {
        let item = datePickerItems[selected].title
        
        pickerSelection = selected
        nav.session.date = DateHelper.date(item) ?? Date()
    }
    
    private func toggleSearch() -> Void {
        nav.session.toolbar.showSearch.toggle()
    }

    private func viewAsPlain() -> Void {
        nav.session.toolbar.mode = .plain
    }
    
    private func toStringList(_ items: [Entry]) -> String {
        var out = ""
        
        for item in items {
            out += item.toString() + "\n"
        }
        
        return out
    }
}
