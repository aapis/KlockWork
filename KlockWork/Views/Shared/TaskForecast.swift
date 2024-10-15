//
//  TaskForecast.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

enum ForecastUIType {
    case button, row, member
}

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
    @AppStorage("notifications.interval") private var notificationInterval: Int = 0
    public var id: UUID = UUID()
    public var date: Date
    public var callback: (() -> Void)? = nil
    public var isForecastMember: Bool = true
    public var type: ForecastUIType = .member
    public let page: PageConfiguration.AppPage?
    @State public var itemsDue: Int = 0
    @State private var dateStrip: String = ""
    @State private var isSelected: Bool = false
    @State private var isUpcomingTaskListPresented: Bool = false
    @State private var isHighlighted: Bool = false
    @FetchRequest private var upcomingTasks: FetchedResults<LogTask>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch self.type {
            case .member:
                ForecastTypeMember(date: self.date, callback: self.callback, upcomingTasks: _upcomingTasks)
                    .padding(8)
            case .button:
                ForecastTypeButton(date: self.date, callback: self.callback, upcomingTasks: _upcomingTasks)
            case .row:
                ForecastTypeRow(date: self.date, callback: self.callback, upcomingTasks: _upcomingTasks)
                    .padding(8)
            }
        }
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.date) {
            NotificationHelper.clean()
            self.actionOnAppear()
        }
    }

    init(date: Date, callback: (() -> Void)? = nil, type: ForecastUIType = .member, page: PageConfiguration.AppPage) {
        self.date = date
        self.callback = callback
        self.type = type
        self.page = page

        _upcomingTasks = CoreDataTasks.fetchDue(on: date)
    }

    struct ForecastTypeMember: View {
        @EnvironmentObject private var state: Navigation
        public var date: Date
        public var callback: (() -> Void)? = nil
        @FetchRequest public var upcomingTasks: FetchedResults<LogTask>
        @State public var itemsDue: Int = 0
        @State private var dateStrip: String = ""
        @State private var dateStripMonth: String = ""
        @State private var dateStripDay: String = ""
        @State private var isSelected: Bool = false
        @State private var isUpcomingTaskListPresented: Bool = false
        @State private var isHighlighted: Bool = false

        var body: some View {
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
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.date) {
                self.actionOnAppear()
            }
        }
    }

    struct ForecastTypeButton: View {
        @EnvironmentObject private var state: Navigation
        @AppStorage("CreateEntitiesWidget.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
        public var date: Date
        public var callback: (() -> Void)? = nil
        @FetchRequest public var upcomingTasks: FetchedResults<LogTask>
        @State public var itemsDue: Int = 0
        @State private var dateStrip: String = ""
        @State private var dateStripMonth: String = ""
        @State private var dateStripDay: String = ""
        @State private var isSelected: Bool = false
        @State private var isUpcomingTaskListPresented: Bool = false
        @State private var isHighlighted: Bool = false

        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        self.isCreateStackShowing = false
                        self.isSearchStackShowing = false
                        self.isUpcomingTaskStackShowing.toggle()

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
                            .mask(Circle().frame(width: 44))

                            (self.isHighlighted ? Color.white : Theme.base)
                                .mask(Circle().frame(width: 30))

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
                }

                Text("Tasks")
                    .opacity(0.4)
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.date) {
                self.actionOnAppear()
            }
        }
    }

    struct ForecastTypeRow: View {
        @EnvironmentObject private var state: Navigation
        @AppStorage("CreateEntitiesWidget.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
        public var date: Date
        public var callback: (() -> Void)? = nil
        @FetchRequest public var upcomingTasks: FetchedResults<LogTask>
        @State public var itemsDue: Int = 0
        @State private var dateStrip: String = ""
        @State private var dateStripMonth: String = ""
        @State private var dateStripDay: String = ""
        @State private var isSelected: Bool = false
        @State private var isUpcomingTaskListPresented: Bool = false
        @State private var isHighlighted: Bool = false

        var body: some View {
            Button {
                self.isCreateStackShowing = false
                self.isSearchStackShowing = false
                self.isUpcomingTaskStackShowing.toggle()

                if let cb = self.callback { cb() }
            } label: {
                HStack(alignment: .center) {
                    // Button
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
                    .frame(width: 40)

                    // Date string
                    Text(self.dateStrip)
                        .underline(self.isHighlighted)

                    // Rating
                    // @TODO: implement rating here when assessmentfactor stuff has been implemented from iOS
                }
                .useDefaultHover({ hover in self.isHighlighted = hover })
                .frame(height: 40)
            }
            .buttonStyle(.plain)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.date) {
                self.actionOnAppear()
            }
        }
    }
}

extension Forecast {
    /// Onload handler
    /// - Returns: Void
    public func actionOnAppear() -> Void {
        for task in self.upcomingTasks {
            if task.hasScheduledNotification {
                NotificationHelper.createInterval(interval: self.notificationInterval, task: task)
            }
        }
    }
}

extension Forecast.ForecastTypeMember {
    /// Onload handler
    /// - Returns: Void
    public func actionOnAppear() -> Void {
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

extension Forecast.ForecastTypeButton {
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

extension Forecast.ForecastTypeRow {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.itemsDue = self.upcomingTasks.count

        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        df.timeZone = TimeZone.autoupdatingCurrent
        df.locale = NSLocale.current

        self.dateStrip = df.string(from: self.date)
        let fSelected = df.string(from: self.state.session.date)
        self.isSelected = self.dateStrip == fSelected
    }
}
