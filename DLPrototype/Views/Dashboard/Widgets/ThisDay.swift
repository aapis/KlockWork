//
//  ThisDay.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct DayInHistory {
    public var year: Int
    public var date: Date
    public var count: Int
    public var highlight: Bool {
        return count == 0
    }
    private var formattedDate: String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: date)
    }
    
    public func linkLabel() -> String {
        if count == 1 {
            return "\(count) record on \(formattedDate)"
        } else if count > 0 {
            return "\(count) records on \(formattedDate)"
        }
        
        return "No records from \(formattedDate)"
    }
}

struct ThisDay: View {
    public let title: String = "Today"
    private let todaysDate: Date = Date()
    
    @State private var selectedDate: String = ""
    @State private var currentDate: Date = Date()
    @State private var todayInHistory: [DayInHistory] = []

    @Environment(\.managedObjectContext) var moc
    
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

            Divider()
            
            VStack(alignment: .leading) {
                ForEach(todayInHistory, id: \.year) { day in
                    FancyLink(
                        icon: "arrow.right",
                        showIcon: false,
                        label: day.linkLabel(),
                        showLabel: true,
                        fgColour: day.highlight ? Color.gray : Color.white,
                        destination: AnyView(Today(defaultSelectedDate: day.date)),
                        size: .small,
                        pageType: .today
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .border(Theme.darkBtnColour)
        .onAppear(perform: loadWidgetData)
        .onChange(of: currentDate) { _ in
            loadWidgetData()
        }
        .frame(height: 250)
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
}
