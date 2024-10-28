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
    @EnvironmentObject public var nav: Navigation
    public let title: String = "Today In History"
    @State private var todayInHistory: [DayInHistory] = []
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UI.Sidebar.Title(text: self.title)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.todayInHistory, id: \.year) { day in day }
            }
        }
        .onAppear(perform: self.loadWidgetData)
        .onChange(of: self.nav.session.date) { self.loadWidgetData() }
    }
}

extension TodayInHistoryWidget {
    /// Find historical data for the currently selected date
    /// - Returns: Void
    private func findHistoricalDataForToday() async -> Void {
        let calendar = Calendar.autoupdatingCurrent
        let current = calendar.dateComponents([.year, .month, .day], from: self.nav.session.date)
        todayInHistory = []

        if current.isValidDate == false {
            for offset in 0...maxYearsPastInHistory {
                let offsetYear = ((offset * -1) + current.year!)
                let components = DateComponents(year: offsetYear, month: current.month!, day: current.day!)
                let day = calendar.date(from: components)
                let numRecordsForDay = CoreDataRecords(moc: self.nav.moc).countForDate(day)

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
