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
                            if todaysDate.compare(currentDate).rawValue == 0 {
                                Image(systemName: "calendar")
                                    .help("That's today!")
                            }

                            FancyTextLink(
                                text: "\(selectedDate)",
                                transparent: true,
                                destination: AnyView(Today(defaultSelectedDate: currentDate)),
                                pageType: .today,
                                sidebar: AnyView(TodaySidebar())
                            )
                            .padding()
                            Spacer()
                        }
                    }

                    VStack(alignment: .trailing) {
                        FancyButton(text: "Next day", action: next, icon: "chevron.right", transparent: true, showLabel: false, size: .small)
                    }
                }
            }

            VStack(alignment: .leading) {
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
        .onAppear(perform: loadWidgetData)
        .onChange(of: currentDate) { _ in
            loadWidgetData()
        }
    }
}

extension TodayInHistoryWidget {
    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
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
    }

    private func next() -> Void {
        todayInHistory = []
        currentDate += 86400
    }

    private func loadWidgetData() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = NSLocale.current

        selectedDate = formatter.string(from: currentDate)

        Task {
            await findHistoricalDataForToday()
        }
    }

    private func actionTodayInHistory(_ day: DayInHistory) -> Void {
        nav.parent = .today
        nav.view = AnyView(Today(defaultSelectedDate: day.date))
        nav.sidebar = AnyView(TodaySidebar(date: day.date))
    }
}
