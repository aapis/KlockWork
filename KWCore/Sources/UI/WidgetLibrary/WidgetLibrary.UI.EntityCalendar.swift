//
//  EntityCalendar.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    public struct EntityCalendar {
        struct Widget: View {
            @EnvironmentObject private var state: Navigation
            @State public var month: String = "_DEFAULT_MONTH"
            @State private var date: Date = Date()
            @AppStorage("widgetlibrary.ui.entitycalendar.isMinimized") private var isMinimized: Bool = false
            public var weekdays: [DayOfWeek] = [
                DayOfWeek(symbol: "Sun"),
                DayOfWeek(symbol: "Mon"),
                DayOfWeek(symbol: "Tues"),
                DayOfWeek(symbol: "Wed"),
                DayOfWeek(symbol: "Thurs"),
                DayOfWeek(symbol: "Fri"),
                DayOfWeek(symbol: "Sat")
            ]
            public var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
            }

            var body: some View {
                NavigationStack {
                    VStack {
                        Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 0) {
                            MonthNav(date: $date)

                            if !self.isMinimized {
                                // Day of week
                                GridRow {
                                    ZStack(alignment: .bottomLeading) {
                                        LazyVGrid(columns: self.columns, alignment: .center) {
                                            ForEach(weekdays) {sym in
                                                Text(sym.symbol)
                                                    .foregroundStyle(sym.current ? self.state.theme.tint : .white)
                                            }
                                            .font(.caption)
                                        }
                                        .padding([.leading, .trailing, .top])
                                        .padding(.bottom, 5)
                                    }
                                }
                                .background(Theme.textBackground)

                                ZStack(alignment: .top) {
                                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                        .opacity(0.3)
                                        .blendMode(.softLight)
                                        .frame(height: 50)
                                    Divider()
                                    // List of days representing 1 month
                                    Month(month: $month)
                                        .padding(.top, 5)
                                }
                            }
                        }
                    }
                    .background(Theme.textBackground)
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.date) { self.actionChangeDate()}
#if os(iOS)
                    .navigationTitle("Activity Calendar")
                    .scrollDismissesKeyboard(.immediately)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                self.state.date = DateHelper.startOfDay()
                                self.date = self.state.date
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                        }
                    }
#endif
                }
            }
        }

        struct Month: View {
            @EnvironmentObject private var state: Navigation
            @Binding public var month: String
            @State private var days: [Day] = []
            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
            }

            var body: some View {
                GridRow {
                    LazyVGrid(columns: self.columns, alignment: .leading) {
                        ForEach(self.days) {view in view}
                    }
                }
                .padding([.leading, .trailing, .bottom])
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
            }
        }

        /// An individual calendar day "tile"
        struct Day: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            public let id: UUID = UUID()
            public var date: Date
            public var dayNumber: Int = 0
            public var isSelected: Bool = false
            public var isWeekend: Bool = false
            @State private var bgColour: Color = .clear
            @State private var fgColour: Color = .white
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var colourData: [Color] = []
            private let gridSize: CGFloat = 35
            private var isToday: Bool {Calendar.autoupdatingCurrent.isDateInToday(self.date)}

            var body: some View {
                Button {
                    self.state.session.date = DateHelper.startOfDay(self.date)
                    isPresented.toggle()
                } label: {
                    ZStack {
                        // Soooo sorry
                        (self.isHighlighted ? self.dayNumber > 0 ? Theme.rowColour : .clear : self.dayNumber > 0 ? self.bgColour.opacity(0.8) : .clear)
                        if self.dayNumber > 0 {
                            ZStack {
                                // Jobs associated with tasks due on a given date provide
                                VStack(alignment: .center, spacing: 0) {
                                    if self.colourData.count > 0 {
                                        ForEach(self.colourData, id: \.self) { colour in
                                            Rectangle()
                                                .foregroundStyle(colour)
                                        }
                                    }
                                }
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(!self.isToday && !self.isSelected ? self.isHighlighted ? self.state.session.appPage.primaryColour.opacity(0.8) : self.state.session.appPage.primaryColour.opacity(1) : self.bgColour)
                                    .padding(4) // width of job-colour-border thing
                                Text(String(self.dayNumber))
                                    .bold(self.isToday || self.isSelected)
                            }
                        }
                    }
                }
                .useDefaultHover({ hover in self.isHighlighted = hover })
                .help("\(self.colourData.count) Tasks due on \(self.state.session.date.formatted(date: .abbreviated, time: .omitted))")
                .buttonStyle(.plain)
                .frame(width: self.gridSize, height: self.gridSize)
                .foregroundColor(self.fgColour)
                .clipShape(.rect(cornerRadius: 6))
                .onAppear(perform: self.actionOnAppear)
                .contextMenu {
                    Button {
                        self.state.session.date = self.date
                        self.state.to(.timeline)
                    } label: {
                        Text("Show Timeline...")
                    }
                    Button {
                        self.state.session.date = self.date
                        self.state.to(.today)
                    } label: {
                        Text("Show Today...")
                    }
                }
            }
        }

        struct MonthNav: View {
            @EnvironmentObject private var state: Navigation
            @Binding public var date: Date
            @AppStorage("widgetlibrary.ui.entitycalendar.isMinimized") private var isMinimized: Bool = false

            var body: some View {
                GridRow {
                    HStack {
                        MonthNavButton(orientation: .leading, date: $date)
                        Spacer()
                        Button {
                            self.isMinimized.toggle()
                        } label: {
                            HStack {
                                Image(systemName: self.isMinimized ? "plus.square.fill" : "minus.square")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title3)
                                Text(
                                    DateHelper.todayShort(
                                        self.state.session.date,
                                        format: self.isMinimized ? "MMMM dd yyyy" : "MMMM yyyy"
                                    )
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({_ in})
                        Spacer()
                        MonthNavButton(orientation: .trailing, date: $date)
                    }
                }
                .frame(height: 32)
            }
        }

        struct MonthNavButton: View {
            @EnvironmentObject private var state: Navigation
            public var orientation: UnitPoint
            @Binding public var date: Date
            @State private var previousMonth: String = ""
            @State private var nextMonth: String = ""
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    ZStack {
                        self.isHighlighted ? self.state.theme.tint.opacity(0.8) : Theme.textBackground
                        HStack {
                            Spacer()
                            Image(systemName: self.orientation == .leading ? "chevron.left" : "chevron.right")
                                .foregroundStyle(self.isHighlighted ? self.state.session.appPage.primaryColour : .white)
                            Spacer()
                        }
                    }
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                }
                .buttonStyle(.plain)
                .frame(width: 32)
            }
        }
    }
}

extension WidgetLibrary.UI.EntityCalendar.Widget {
    /// Get month string from date
    /// - Returns: Void
    private func actionChangeDate() -> Void {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: self.date)
        self.state.session.date = DateHelper.startOfDay(self.date)
    }

    /// Onload handler. Used by DatePicker, should be AppState.date by default
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.date = self.state.session.date
    }
}

extension WidgetLibrary.UI.EntityCalendar.MonthNavButton {
    /// Navigate between months by tapping on the button
    /// @TODO: shared functionality with ActivityCalendar.actionOnSwipe, refactor!
    /// - Returns: Void
    private func actionOnTap() -> Void {
        let oneMonthMs: Double = 2592000

        if self.orientation == .leading {
            self.date = self.state.session.date - oneMonthMs
        } else {
            self.date = self.state.session.date + oneMonthMs
        }
    }
}

extension WidgetLibrary.UI.EntityCalendar.Month {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.days = []
        self.createDays()
    }
    
    /// Create calendar day objects
    /// - Returns: Void
    private func createDays() -> Void {
        let calendar = Calendar.autoupdatingCurrent
        if let interval = calendar.dateInterval(of: .month, for: self.state.session.date) {
            let numDaysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end)
            let adComponents = calendar.dateComponents([.day, .month, .year], from: self.state.session.date)

            if numDaysInMonth.day != nil {
                self.createBlankDays()

                // Append the real Day objects
                for idx in 1...numDaysInMonth.day! {
                    if let dayComponent = adComponents.day {
                        let month = adComponents.month
                        let components = DateComponents(year: adComponents.year, month: adComponents.month, day: idx)
                        if let date = calendar.date(from: components) {
                            let selectorComponents = calendar.dateComponents([.weekday, .month], from: date)

                            if selectorComponents.weekday != nil && selectorComponents.month != nil {
                                self.days.append(
                                    WidgetLibrary.UI.EntityCalendar.Day(
                                        date: date,
                                        dayNumber: idx,
                                        isSelected: dayComponent == idx && selectorComponents.month == month,
                                        isWeekend: selectorComponents.weekday == 1 || selectorComponents.weekday! == 7
                                    )
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Create blank spaces for calendar
    /// - Returns: Void
    private func createBlankDays() -> Void {
        let firstDayComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.weekday],
            from: DateHelper.datesAtStartAndEndOfMonth(for: self.state.session.date)!.0
        )

        if let ordinal = firstDayComponents.weekday {
            if (ordinal - 2) > 0 {
                for _ in 0...(ordinal - 2) { // @TODO: not sure why this is -2, should be -1?
                    self.days.append(
                        WidgetLibrary.UI.EntityCalendar.Day(
                            date: Date(),
                            dayNumber: 0
                        )
                    )
                }
            }
        }
    }

    /// Reset the view by regenerating all tiles
    /// - Returns: Void
    private func reset() -> Void {
        self.days = []
        self.actionOnAppear()
    }
}

extension WidgetLibrary.UI.EntityCalendar.Day {
    /// Onload handler, determines tile back/foreground colours
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = .clear
        self.fgColour = .white
        self.prepareColourData()

        if self.isToday && self.isSelected || self.isSelected {
            self.bgColour = self.state.theme.tint
            self.fgColour = Theme.base
        } else if self.isToday {
            self.bgColour = .blue
            self.fgColour = .white
        } else if self.date < Date() {
            self.fgColour = .gray
        }
    }
    
    /// Called in onload handler. Determines colour values for calendar Day border
    /// - Returns: Void
    private func prepareColourData() -> Void {
        self.colourData = []

        if let plan = CoreDataPlan(moc: self.state.moc).forDate(self.date).first {
            if let jobs = plan.jobs?.allObjects as? [Job] {
                for job in jobs.sorted(by: {$0.created ?? Date() < $1.created ?? Date()}) {
                    self.colourData.append(job.backgroundColor)
                }
            }
        } else {
            let jobs = CoreDataTasks(moc: self.state.moc)
                .jobsForTasksDueToday(self.date)
                .sorted(by: {$0.created ?? Date() < $1.created ?? Date()})
            for job in jobs {
                self.colourData.append(job.backgroundColor)
            }
        }
    }
}