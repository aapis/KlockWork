//
//  TaskForecast.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskForecast: View {
    @EnvironmentObject private var state: Navigation
    @Environment(\.colorScheme) var colourScheme

    public var callback: (() -> Void)? = nil
    public var daysToShow: Double = 14
    public var page: PageConfiguration.AppPage = .today
    @State private var forecast: [Forecast] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.forecast, id: \.id) { row in row }
                }
            }
            .background(Theme.base.opacity(0.6))
        }
        .onAppear(perform: self.actionOnAppear)
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.forecast = []
        let dates = Date()..<DateHelper.daysAhead(self.daysToShow)
        let hrs24: TimeInterval = 60*60*24

        for date in stride(from: dates.lowerBound, to: dates.upperBound, by: hrs24) {
            self.forecast.append(
                Forecast(date: DateHelper.startOfDay(date), callback: self.callback, page: self.page)
            )
        }
    }
}

struct Forecast: View, Identifiable {
    @EnvironmentObject private var state: Navigation
    @Environment(\.colorScheme) var colourScheme
    @AppStorage("CreateEntitiesWidget.isCreateStackShowing") private var isCreateStackShowing: Bool = false
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    var id: UUID = UUID()
    var date: Date
    public var callback: (() -> Void)? = nil
    public var isForecastMember: Bool = true
    public let page: PageConfiguration.AppPage?
    @State public var itemsDue: Int = 0
    @State private var dateStrip: String = ""
    @State private var dateStripMonth: String = ""
    @State private var dateStripDay: String = ""
    @State private var isSelected: Bool = false
    @State private var isUpcomingTaskListPresented: Bool = false
    @State private var isHighlighted: Bool = false
    @FetchRequest private var upcomingTasks: FetchedResults<LogTask>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.isForecastMember {
                VStack(alignment: .center, spacing: 1) {
                    Text(self.dateStrip)
                        .multilineTextAlignment(.leading)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(self.isSelected ? .yellow : .white)
                        .opacity(self.itemsDue == 0 ? 0.4 : 1)

                    Button {
                        self.state.session.date = DateHelper.startOfDay(self.date)

                        if self.isSelected {
                            if let cb = self.callback { cb() }
                        }
                    } label: {
                        ZStack {
                            VStack(alignment: .center, spacing: 0) {
                                if self.upcomingTasks.count > 0 {
                                    ForEach(self.upcomingTasks, id: \.objectID) { task in
                                        Rectangle()
                                            .foregroundStyle(task.owner?.backgroundColor ?? Theme.rowColour)
                                    }
                                } else {
                                    Color.green
                                }
                            }
                            .mask(Circle().frame(width: 35))

                            (self.isHighlighted ? Color.white : Theme.base)
                                .mask(Circle().frame(width: 25))

                            Text(String(self.itemsDue))
                                .multilineTextAlignment(.leading)
                                .font(.system(.headline, design: .monospaced))
                                .bold()
                                .foregroundStyle(self.itemsDue == 0 ? .gray : self.isHighlighted ? Theme.base : .white)
                        }
                        .frame(width: 50, height: 50)
                        .useDefaultHover({ hover in self.isHighlighted = hover })
                    }
                    .buttonStyle(.plain)
                    .opacity(self.itemsDue == 0 ? 0.4 : 1)
                }
            } else {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 8) {
                        Button {
                            // @TODO: works but looks funny, fix
//                            self.isUpcomingTaskListPresented.toggle()
                            self.isCreateStackShowing = false
                            self.isSearchStackShowing = false
                            self.isUpcomingTaskStackShowing.toggle()
//                            self.state.to(.planning)

                            if self.isSelected {
                                if let cb = self.callback { cb() }
                            }
                        } label: {
                            ZStack {
                                VStack(alignment: .center, spacing: 0) {
                                    if self.upcomingTasks.count > 0 {
                                        ForEach(self.upcomingTasks, id: \.objectID) { task in
                                            Rectangle()
                                                .foregroundStyle(task.owner?.backgroundColor ?? Theme.rowColour)
                                        }
                                    } else {
                                        Color.green
                                    }
                                }
                                .mask(Circle().frame(width: 40))

                                (self.isHighlighted ? Color.white : Theme.base)
                                    .mask(Circle().frame(width: 29))

                                Text(String(self.itemsDue))
                                    .multilineTextAlignment(.leading)
                                    .font(.system(.headline, design: .monospaced))
                                    .bold()
                                    .foregroundStyle(self.itemsDue == 0 ? .gray : self.isHighlighted ? Theme.base : .white)
                            }
                            .useDefaultHover({ hover in self.isHighlighted = hover })
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 40)
                    .padding(.top, 4)

                    Text("Tasks")
                        .padding(.top, 6)
                        .opacity(0.4)
                }
                .frame(width: 40)
            }
        }
        .padding(8)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.date) {
            self.actionOnAppear()
        }
        // @TODO: works but messes with window, fix for macOS
//        .sheet(isPresented: $isUpcomingTaskListPresented) {
//            NavigationStack {
//                Planning.Upcoming()
//                    .presentationBackground(self.page?.primaryColour ?? Theme.cOrange)
//                    .scrollContentBackground(.hidden)
//            }
//        }
    }

    init(date: Date, callback: (() -> Void)? = nil, isForecastMember: Bool = true, page: PageConfiguration.AppPage) {
        self.date = date
        self.callback = callback
        self.isForecastMember = isForecastMember
        self.page = page

        _upcomingTasks = CoreDataTasks.fetchDue(on: date)
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.itemsDue = self.upcomingTasks.count

        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        df.timeZone = TimeZone.autoupdatingCurrent
        df.locale = NSLocale.current

        self.dateStrip = df.string(from: self.date)
        let fSelected = df.string(from: self.state.session.date)
        self.isSelected = self.dateStrip == fSelected
    }
}
