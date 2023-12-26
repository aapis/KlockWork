//
//  TodayInHistoryWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TodayInHistoryWidget: View {
    public let title: String = "Recent Jobs"
    private let todaysDate: Date = Date()

    @State private var minimized: Bool = false
    @State private var selectedDate: String = ""
    @State private var currentDate: Date = Date()
    @State private var todayInHistory: [DayInHistory] = []

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        FancyButton(text: "Previous day", action: prev, icon: "chevron.left", transparent: true, showLabel: false, size: .small)
                    }

                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            FancyTextLink(
                                text: "\(selectedDate)",
                                transparent: true,
                                destination: AnyView(Today(defaultSelectedDate: currentDate).environmentObject(nav)),
                                pageType: .today,
                                sidebar: AnyView(TodaySidebar())
                            )
                            Spacer()
                        }
                    }

                    VStack(alignment: .trailing) {
                        FancyButton(text: "Next day", action: next, icon: "chevron.right", transparent: true, showLabel: false, size: .small)
                    }
                }
                .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(todayInHistory, id: \.year) { day in
                        SidebarItem(
                            data: day.linkLabel(),
                            help: day.linkLabel(),
                            icon: "arrowshape.right",
                            orientation: .right,
                            action: {actionTodayInHistory(day)}
                        )
                        .foregroundColor(day.highlight ? Color.black.opacity(0.6) : Color.white)
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: loadWidgetData)
        .onChange(of: nav.session.date) { _ in
            loadWidgetData()
        }
    }
}

extension TodayInHistoryWidget {
    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func findHistoricalDataForToday() async -> Void {
        let calendar = Calendar.autoupdatingCurrent
        let current = calendar.dateComponents([.year, .month, .day], from: currentDate)
        todayInHistory = []

        if current.isValidDate == false {
            for offset in 0...maxYearsPastInHistory {
                let offsetYear = ((offset * -1) + current.year!)
                let components = DateComponents(year: offsetYear, month: current.month!, day: current.day!)
                let day = calendar.date(from: components)
                let numRecordsForDay = CoreDataRecords(moc: moc).countForDate(day)

                todayInHistory.append(DayInHistory(year: offsetYear, date: day ?? Date(), count: numRecordsForDay))
            }
        }
    }

    private func prev() -> Void {
        todayInHistory = []
        currentDate -= 86400
        nav.session.date = currentDate
    }

    private func next() -> Void {
        todayInHistory = []
        currentDate += 86400
        nav.session.date = currentDate
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
