//
//  TodayInHistoryWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct TodayInHistoryWidget: View {
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var state: Navigation
    public let title: String = "History"
    public var period: UI.Explore.Visualization.Timeline.TimelineTab = .day
    public var format: String = "MMMM dd"
    @State private var todayInHistory: [DayInHistory] = []
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UI.Sidebar.Title(text: self.title)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.todayInHistory, id: \.year) { day in day }
            }
            UI.Sidebar.Title(text: "Interactions")
            UI.InteractionsInRange(
                period: self.period,
                start: self.state.session.date.startOfDay,
                end: self.state.session.date.endOfDay,
                format: self.format,
                showWidgetTitle: false,
                location: .fullSizeSidebar
            )
            .padding(8)
        }
        .onAppear(perform: self.loadWidgetData)
        .onChange(of: self.state.session.date) { self.loadWidgetData() }
    }
}

extension TodayInHistoryWidget {
    /// Find historical data for the currently selected date
    /// - Returns: Void
    private func findHistoricalDataForToday() async -> Void {
        let calendar = Calendar.autoupdatingCurrent
        let current = calendar.dateComponents([.year, .month, .day], from: self.state.session.date)
        todayInHistory = []

        if current.isValidDate == false {
            for offset in 0...maxYearsPastInHistory {
                let offsetYear = ((offset * -1) + current.year!)
                let components = DateComponents(year: offsetYear, month: current.month!, day: current.day!)
                let day = calendar.date(from: components)
                let numRecordsForDay = CoreDataRecords(moc: self.state.moc).countForDate(day)

                todayInHistory.append(
                    DayInHistory(year: offsetYear, date: day ?? Date(), count: numRecordsForDay)
                )
            }
        }
    }
    
    /// Calls findHistoricalDataForToday asynchronously
    /// - Returns: Void
    private func loadWidgetData() -> Void {
        Task {
            await findHistoricalDataForToday()
        }
    }
}
