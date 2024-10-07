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
    @EnvironmentObject public var nav: Navigation
    public let title: String = "Today In History"
    @State private var selectedDate: String = ""
    @State private var currentDate: Date = Date()
    @State private var todayInHistory: [DayInHistory] = []
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                HStack(alignment: .center, spacing: 0) {
                    Text(self.title)
                        .padding(6)
                        .background(Theme.textBackground)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .padding(8)
            }
            Divider()

            VStack(alignment: .leading, spacing: 1) {
                ForEach(todayInHistory, id: \.year) { day in
                    SidebarItem(
                        data: day.linkLabel(),
                        help: day.linkLabel(),
                        icon: "chevron.right",
                        orientation: .right,
                        action: {actionTodayInHistory(day)},
                        showBorder: false,
                        showButton: false
                    )
                    .font(.title3)
                    .background(day.highlight ? Color.white.opacity(0.5) : .yellow.opacity(0.8))
                    .foregroundStyle(Theme.base.opacity(day.highlight ? 0.4 : 1))
                }
            }
            Divider()
        }
        .background(Theme.base.opacity(0.2))
        .onAppear(perform: loadWidgetData)
        .onChange(of: nav.session.date) {
            loadWidgetData()
        }
    }
}

extension TodayInHistoryWidget {
    private func findHistoricalDataForToday() async -> Void {
        let calendar = Calendar.autoupdatingCurrent
        let current = calendar.dateComponents([.year, .month, .day], from: currentDate)
        todayInHistory = []

        if current.isValidDate == false {
            for offset in 0...maxYearsPastInHistory {
                let offsetYear = ((offset * -1) + current.year!)
                let components = DateComponents(year: offsetYear, month: current.month!, day: current.day!)
                let day = calendar.date(from: components)
                let numRecordsForDay = CoreDataRecords(moc: self.nav.moc).countForDate(day)

                todayInHistory.append(DayInHistory(year: offsetYear, date: day ?? Date(), count: numRecordsForDay))
            }
        }
    }

    private func loadWidgetData() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = NSLocale.current
        currentDate = nav.session.date
        selectedDate = formatter.string(from: currentDate)

        Task {
            await findHistoricalDataForToday()
        }
    }

    private func actionTodayInHistory(_ day: DayInHistory) -> Void {
        nav.session.date = day.date
        nav.parent = .today
        nav.view = AnyView(Today(defaultSelectedDate: day.date).environmentObject(nav))
        nav.sidebar = AnyView(TodaySidebar(date: day.date))
        nav.pageId = UUID()
    }
}
