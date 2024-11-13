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
        enum CalendarViewMode {
            case days, months, years
        }

        struct WeekWidget: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.entitycalendar.calendarviewmode.index") private var mode: Int = 0
            @AppStorage("widgetlibrary.ui.entitycalendar.isWeekAtAGlanceMinimized") private var isWeekAtAGlanceMinimized: Bool = false
            @AppStorage("today.endOfDay") public var endOfDay: Int = 18
            public var start: Date?
            @State private var days: [UI.Blocks.Day] = []

            var body: some View {
                VStack {
                    HStack(alignment: .center) {
                        UI.ListLinkTitle(text: "Week at a Glance")
                        Spacer()
                        UI.Buttons.Minimize(isMinimized: $isWeekAtAGlanceMinimized)
                    }
                    .padding(8)
                    .background(self.isWeekAtAGlanceMinimized ? self.state.session.appPage.primaryColour : .clear)
                    .clipShape(.rect(cornerRadius: 5))
                    
                    if !self.isWeekAtAGlanceMinimized {
                        HStack(spacing: 16) {
                            ForEach(self.days, id: \.id) { day in day }
                        }
                        .frame(height: 100)
                    }
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
            }
        }

        // @TODO: build this widget
        // MARK: CalendarSelectorWidget
        struct CalendarSelectorWidget {

        }

        // MARK: BoundInlineSelector
        struct BoundInlineRangeSelector: View {
            @EnvironmentObject public var state: Navigation
            public var isRangeStart: Bool = true
            @State private var month: Int = 0
            @State private var day: Int = 1
            @State private var year: Int = 0
            @State private var yearString: String = ""

            var body: some View {
                HStack {
                    Selector(
                        mode: .months,
                        label: Text(Calendar.autoupdatingCurrent.monthSymbols[self.month]),
                        isStartRangeMember: self.isRangeStart,
                        value: $month
                    )
                    Selector(
                        mode: .days,
                        label: Text(String(self.day)),
                        isStartRangeMember: self.isRangeStart,
                        value: $day
                    )
                    Selector(
                        mode: .years,
                        label: Text(String(self.year)),
                        isStartRangeMember: self.isRangeStart,
                        value: $year
                    )
                }
                .bold(true)
                .font(.title)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.timeline.custom.rangeStart) { self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.custom.rangeEnd) { self.actionOnAppear() }
            }

            struct Selector: View {
                @EnvironmentObject private var state: Navigation
                @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
                public var mode: CalendarViewMode
                public var label: Text
                public var isStartRangeMember: Bool
                @Binding public var value: Int
                @State private var isHighlighted: Bool = false
                @State private var isPresented: Bool = false
                @State private var years: [MenuOption] = []
                @State private var days: [MenuOption] = []

                var body: some View {
                    VStack {
                        Button {
                            self.actionOnTap()
                        } label: {
                            self.label
                                .foregroundStyle(self.isHighlighted ? self.state.theme.tint : .white)
                            if self.isPresented {
                                Menu("Select") {
                                    switch self.mode {
                                    case .months:
                                        // @TODO: refactor to use loop and Calendar.current.monthSymbols
                                        Button("January") { self.actionOnChangeMonth() }
                                        Button("February") { self.actionOnChangeMonth(with: 1) }
                                        Button("March") { self.actionOnChangeMonth(with: 2) }
                                        Button("April") { self.actionOnChangeMonth(with: 3) }
                                        Button("May") { self.actionOnChangeMonth(with: 4) }
                                        Button("June") { self.actionOnChangeMonth(with: 5) }
                                        Button("July") { self.actionOnChangeMonth(with: 6) }
                                        Button("August") { self.actionOnChangeMonth(with: 7) }
                                        Button("September") { self.actionOnChangeMonth(with: 8) }
                                        Button("October") { self.actionOnChangeMonth(with: 9) }
                                        Button("November") { self.actionOnChangeMonth(with: 10) }
                                        Button("December") { self.actionOnChangeMonth(with: 11) }
                                    case .days:
                                        ForEach(self.days) { option in
                                            Button(String(option.value)) { option.callback(option.value) }
                                        }
                                    case .years:
                                        ForEach(self.years) { option in
                                            Button(String(option.value)) { option.callback(option.value) }
                                        }
                                    }
                                }
                                .foregroundStyle(.gray)
                                .onChange(of: self.value) { self.isPresented = false }
                            }
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({ hover in self.isHighlighted = hover})
                    }
                    .onAppear(perform: self.actionOnAppear)
                }

                struct MenuOption: Identifiable {
                    var id: UUID = UUID()
                    var value: Int
                    var callback: (Int?) -> Void
                }
            }
        }

        struct Widget: View {
            @EnvironmentObject private var state: Navigation
            @State private var month: String = "_DEFAULT_MONTH"
            @State private var date: Date = Date()
            @AppStorage("widgetlibrary.ui.entitycalendar.calendarviewmode.index") private var mode: Int = 0
            @AppStorage("widgetlibrary.ui.entitycalendar.isMinimized") private var isMinimized: Bool = false

            var body: some View {
                NavigationStack {
                    Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 0) {
                        MonthNav(date: $date)

                        if !self.isMinimized {
                            GridRow(alignment: .top) {
                                ZStack(alignment: .top) {
                                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                        .opacity(0.3)
                                        .blendMode(.softLight)
                                        .frame(height: 50)
                                    Divider()
                                    VStack(spacing: 0) {
                                        if self.mode == 0 {
                                            ListOfDays(month: $month)
                                        } else if self.mode == 1 {
                                            ListOfMonths()
                                        } else if self.mode == 2 {
                                            ListOfYears()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .frame(height: 330)
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

        internal struct ListOfDays: View {
            @EnvironmentObject private var state: Navigation
            @Binding public var month: String
            @State private var days: [Day] = []
            private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 1), count: 7) }
            private let weekdays: [DayOfWeek] = [
                DayOfWeek(symbol: "Sun"),
                DayOfWeek(symbol: "Mon"),
                DayOfWeek(symbol: "Tues"),
                DayOfWeek(symbol: "Wed"),
                DayOfWeek(symbol: "Thurs"),
                DayOfWeek(symbol: "Fri"),
                DayOfWeek(symbol: "Sat")
            ]

            var body: some View {
                GridRow(alignment: .top) {
                    ZStack(alignment: .topLeading) {
                        LazyVGrid(columns: self.columns, alignment: .center) {
                            ForEach(self.weekdays) {sym in
                                Text(sym.symbol)
                                    .foregroundStyle(sym.current ? self.state.theme.tint : .white)
                            }
                            .font(.caption)
                        }
                        .padding([.leading, .trailing, .top])
                        .padding(.bottom, 5)
                    }
                }
                GridRow(alignment: .top) {
                    LazyVGrid(columns: self.columns, alignment: .leading) {
                        ForEach(self.days) {view in view}
                    }
                }
                .padding()
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
            }
        }

        internal struct ListOfMonths: View {
            @EnvironmentObject private var state: Navigation
            private var months: [Month] = [
                Month(label: "January", index: 0),
                Month(label: "February", index: 1),
                Month(label: "March", index: 2),
                Month(label: "April", index: 3),
                Month(label: "May", index: 4),
                Month(label: "June", index: 5),
                Month(label: "July", index: 6),
                Month(label: "August", index: 7),
                Month(label: "September", index: 8),
                Month(label: "October", index: 9),
                Month(label: "November", index: 10),
                Month(label: "December", index: 11)
            ]
            private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 1), count: 2) }

            var body: some View {
                GridRow(alignment: .top) {
                    LazyVGrid(columns: self.columns, alignment: .leading) {
                        ForEach(self.months) {view in view}
                    }
                }
                .padding()
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
            }
        }

        internal struct ListOfYears: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
            @State private var years: [UI.EntityCalendar.Year] = []
            private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 1), count: 2) }

            var body: some View {
                GridRow(alignment: .top) {
                    LazyVGrid(columns: self.columns, alignment: .leading) {
                        ForEach(self.years) {view in view}
                    }
                }
                .padding()
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
            @State private var colourData: Set<Color> = []
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
                                        ForEach(Array(self.colourData), id: \.self) { colour in
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
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                }
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

        struct Month: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.entitycalendar.calendarviewmode.index") private var calendarViewMode: Int = 0
            var id: UUID = UUID()
            var label: String
            var index: Int
            @State private var isSelected: Bool = false
            @State private var bgColour: Color = .clear
            @State private var fgColour: Color = .white
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var colourData: Set<Color> = []

            var body: some View {
                Button {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/M/dd HH:mm"
                    let cYear = DateHelper.todayShort(self.state.session.date, format: "yyyy")

                    if let date = formatter.date(from: "\(cYear)/\(self.index + 1)/01 00:01") {
                        self.state.session.date = date
                    }

                    self.calendarViewMode = 0
                } label: {
                    ZStack {
                        self.bgColour.opacity(0.8)
                        ZStack {
                            // Jobs associated with tasks due on a given date provide
                            VStack(alignment: .center, spacing: 0) {
                                if self.colourData.count > 0 {
                                    ForEach(Array(self.colourData), id: \.self) { colour in
                                        Rectangle()
                                            .foregroundStyle(colour)
                                    }
                                }
                            }
                            RoundedRectangle(cornerRadius: 5)
                                .fill(!self.isSelected ? self.isHighlighted ? self.state.session.appPage.primaryColour.opacity(0.8) : self.state.session.appPage.primaryColour.opacity(1) : self.bgColour)
                                .padding(4) // width of job-colour-border thing
                            Text(self.label)
                                .bold(self.isSelected)
                        }
                    }
                }
                .useDefaultHover({ hover in self.isHighlighted = hover })
                .help("")
                .buttonStyle(.plain)
                .frame(height: 35)
                .foregroundColor(self.fgColour)
                .clipShape(.rect(cornerRadius: 6))
                .onAppear(perform: self.actionOnAppear)
            }
        }

        struct Year: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.entitycalendar.calendarviewmode.index") private var calendarViewMode: Int = 0
            var id: UUID = UUID()
            var label: String
            var date: Date
            var isSelected: Bool = false
            @State private var bgColour: Color = .clear
            @State private var fgColour: Color = .white
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var colourData: Set<Color> = []

            var body: some View {
                Button {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/M/dd HH:mm"
                    let selectedYear = DateHelper.todayShort(self.date, format: "yyyy")
                    let currentMonth = DateHelper.todayShort(self.state.session.date, format: "M")

                    if let date = formatter.date(from: "\(selectedYear)/\(currentMonth)/01 00:01") {
                        self.state.session.date = date
                    }
                    self.calendarViewMode = 0
                } label: {
                    ZStack {
                        self.bgColour.opacity(0.8)
                        ZStack {
                            // Jobs associated with tasks due on a given date provide
                            VStack(alignment: .center, spacing: 0) {
                                if self.colourData.count > 0 {
                                    ForEach(Array(self.colourData), id: \.self) { colour in
                                        Rectangle()
                                            .foregroundStyle(colour)
                                    }
                                }
                            }
                            RoundedRectangle(cornerRadius: 5)
                                .fill(!self.isSelected ? self.isHighlighted ? self.state.session.appPage.primaryColour.opacity(0.8) : self.state.session.appPage.primaryColour.opacity(1) : self.bgColour)
                                .padding(4) // width of job-colour-border thing
                            Text(self.label)
                                .bold(self.isSelected)
                        }
                    }
                }
                .useDefaultHover({ hover in self.isHighlighted = hover })
                .help("")
                .buttonStyle(.plain)
                .frame(height: 35)
                .foregroundColor(self.fgColour)
                .clipShape(.rect(cornerRadius: 6))
                .onAppear(perform: self.actionOnAppear)
            }
        }

        internal struct MonthNav: View {
            @EnvironmentObject private var state: Navigation
            @Binding public var date: Date
            @AppStorage("widgetlibrary.ui.entitycalendar.isMinimized") private var isMinimized: Bool = false
            @AppStorage("widgetlibrary.ui.entitycalendar.calendarviewmode.index") private var cvm: Int = 0

            var body: some View {
                GridRow {
                    HStack {
                        MonthNavButton(orientation: .leading, date: $date)
                        Spacer()
                        Button {
                            self.isMinimized.toggle()
                            self.cvm = 0
                        } label: {
                            Image(systemName: self.isMinimized ? "plus.square.fill" : "minus.square")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({_ in})
                        Button {
                            self.isMinimized = false
                            if self.cvm == 1 {
                                self.cvm = 0
                            } else {
                                self.cvm = 1
                            }
                        } label: {
                            ZStack(alignment: .leading) {
                                (self.cvm == 1 ? self.state.theme.tint.opacity(0.8) : .clear)
                                HStack(alignment: .center, spacing: 0) {
                                    Text(
                                        DateHelper.todayShort(
                                            self.state.session.date,
                                            format: "MMMM"
                                        )
                                    )
                                    .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundStyle(self.cvm == 1 ? Theme.base : .gray)
                                }
                                .padding([.leading, .trailing], 4)
                                .foregroundStyle(self.cvm == 1 ? Theme.base : .white)
                            }
                            .useDefaultHover({_ in})
                        }
                        .buttonStyle(.plain)
                        Button {
                            self.isMinimized = false
                            if self.cvm == 2 {
                                self.cvm = 0
                            } else {
                                self.cvm = 2
                            }
                        } label: {
                            ZStack(alignment: .leading) {
                                (self.cvm == 2 ? self.state.theme.tint.opacity(0.8) : .clear)
                                HStack(alignment: .center, spacing: 0) {
                                    Text(
                                        DateHelper.todayShort(
                                            self.state.session.date,
                                            format: "yyyy"
                                        )
                                    )
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundStyle(self.cvm == 2 ? Theme.base : .gray)
                                }
                                .padding([.leading, .trailing], 4)
                                .foregroundStyle(self.cvm == 2 ? Theme.base : .white)
                            }
                            .useDefaultHover({_ in})
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        MonthNavButton(orientation: .trailing, date: $date)
                    }
                }
                .frame(height: 32)
            }
        }

        internal struct MonthNavButton: View {
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
                            Image(systemName: self.orientation == .leading ? "chevron.left.chevron.left.dotted" : "chevron.right.dotted.chevron.right")
                                .foregroundStyle(self.isHighlighted ? self.state.session.appPage.primaryColour : .white)
                            Spacer()
                        }
                    }
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                }
                .buttonStyle(.plain)
                .help("\(self.orientation == .leading ? "Previous" : "Next") month")
                .frame(width: 32)
            }
        }
    }
}

extension WidgetLibrary.UI.EntityCalendar.BoundInlineRangeSelector {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        let components = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year], from: self.isRangeStart ? self.state.session.timeline.custom.rangeStart : self.state.session.timeline.custom.rangeEnd)
        self.month = (components.month ?? 1) - 1
        self.day = components.day ?? 1
        self.year = components.year ?? 0
    }
}

extension WidgetLibrary.UI.EntityCalendar.BoundInlineRangeSelector.Selector {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.years = []
        self.days = []

        if let cYear = Int(DateHelper.todayShort(self.state.session.date, format: "yyyy")) {
            for i in 0...self.maxYearsPastInHistory {
                self.years.append(
                    MenuOption(
                        value: cYear - i,
                        callback: self.actionOnChangeYear
                    )
                )
            }
        }


        var daysInMonth = 30
        if [1,2,3,5,7,10,12].contains(self.value) {
            daysInMonth = 31
        }

        for i in 0..<daysInMonth {
            self.days.append(
                MenuOption(
                    value: i + 1,
                    callback: self.actionOnChangeDay
                )
            )
        }
    }

    /// Fires when select menu is interacted with
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.isPresented.toggle()
    }

    /// Fires when selector value changes. Sets view state.
    /// - Returns: Void
    private func actionOnChangeMonth(with value: Int? = 0) -> Void {
        self.value = value!
        if self.isStartRangeMember {
            let sYear = DateHelper.todayShort(self.state.session.timeline.custom.rangeStart, format: "yyyy")
            if let date = DateHelper.date(from: "\(sYear)/\(String(value!))/01 00:01") {
                self.state.session.timeline.custom.rangeStart = date
            }
        } else {
            let sYear = DateHelper.todayShort(self.state.session.timeline.custom.rangeEnd, format: "yyyy")
            if let date = DateHelper.date(from: "\(sYear)/\(String(value!))/01 00:01") {
                self.state.session.timeline.custom.rangeEnd = date
            }
        }
    }

    /// Fires when selector value changes. Sets view state.
    /// - Returns: Void
    private func actionOnChangeDay(with value: Int? = 0) -> Void {
        self.value = value!
        if self.isStartRangeMember {
            let sYear = DateHelper.todayShort(self.state.session.timeline.custom.rangeStart, format: "yyyy")
            let sMonth = DateHelper.todayShort(self.state.session.timeline.custom.rangeStart, format: "M")
            if let date = DateHelper.date(from: "\(sYear)/\(sMonth)/\(String(value!)) 00:01") {
                self.state.session.timeline.custom.rangeStart = date
            }
        } else {
            let sYear = DateHelper.todayShort(self.state.session.timeline.custom.rangeEnd, format: "yyyy")
            let sMonth = DateHelper.todayShort(self.state.session.timeline.custom.rangeEnd, format: "M")
            if let date = DateHelper.date(from: "\(sYear)/\(sMonth)/\(String(value!)) 00:01") {
                self.state.session.timeline.custom.rangeEnd = date
            }
        }
    }

    /// Fires when selector value changes. Sets view state.
    /// - Returns: Void
    private func actionOnChangeYear(with value: Int? = 0) -> Void {
        self.value = value!
        if self.isStartRangeMember {
            let sMonth = DateHelper.todayShort(self.state.session.timeline.custom.rangeStart, format: "M")
            let sDay = DateHelper.todayShort(self.state.session.timeline.custom.rangeStart, format: "d")
            if let date = DateHelper.date(from: "\(String(value!))/\(sMonth)/\(sDay) 00:01") {
                self.state.session.timeline.custom.rangeStart = date
            }
        } else {
            let sMonth = DateHelper.todayShort(self.state.session.timeline.custom.rangeEnd, format: "M")
            let sDay = DateHelper.todayShort(self.state.session.timeline.custom.rangeEnd, format: "d")
            if let date = DateHelper.date(from: "\(String(value!))/\(sMonth)/\(sDay) 00:01") {
                self.state.session.timeline.custom.rangeEnd = date
            }
        }
    }
}

extension WidgetLibrary.UI.EntityCalendar.WeekWidget {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.days = []

        if let startDate = self.start {
            if let sod = self.state.session.date.startOfDay {
                if let eod = self.state.session.date.endOfDay {
                    for i in 0..<7 {
                        let date = startDate + Double((i - 1) * 86400)

                        self.days.append(
                            UI.Blocks.Day(
                                date: date,
                                dayNumber: i + 1,
                                isSelected: date >= sod && date < eod
                            )
                        )
                    }
                }
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

extension WidgetLibrary.UI.EntityCalendar.ListOfDays {
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

                // @TODO: add calendar events too
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

extension WidgetLibrary.UI.EntityCalendar.ListOfMonths {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }
}

extension WidgetLibrary.UI.EntityCalendar.ListOfYears {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.years = []
        self.createList()
    }

    /// Create the list of Year objects
    /// - Returns: Void
    private func createList() -> Void {
        let calendar = Calendar.autoupdatingCurrent
        let current = calendar.dateComponents([.year, .month, .day], from: Date())

        if current.isValidDate == false {
            for offset in 0...self.maxYearsPastInHistory {
                let offsetYear = ((offset * -1) + current.year!)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"

                if let date = formatter.date(from: "\(offsetYear)/01/01 00:01") {
                    self.years.append(
                        UI.EntityCalendar.Year(
                            label: String(offsetYear),
                            date: date,
                            isSelected: DateHelper.todayShort(self.state.session.date, format: "yyyy") == DateHelper.todayShort(date, format: "yyyy")
                        )
                    )
                }
            }
        }
    }

    /// Reset the view by regenerating all tiles
    /// - Returns: Void
    private func reset() -> Void {
        self.years = []
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
                    self.colourData.insert(job.backgroundColor)
                }
            }
        } else {
            let jobs = CoreDataTasks(moc: self.state.moc)
                .jobsForTasksDueToday(self.date)
                .sorted(by: {$0.created ?? Date() < $1.created ?? Date()})
            if !jobs.isEmpty {
                for job in jobs {
                    self.colourData.insert(job.backgroundColor)
                }
            } else {
                let records = CoreDataRecords(moc: self.state.moc).forDate(self.date)
                if !records.isEmpty {
                    for record in records {
                        if let colour = record.job?.backgroundColor {
                            self.colourData.insert(colour)
                        }
                    }
                }
            }
        }
    }
}

extension WidgetLibrary.UI.EntityCalendar.Month {
    /// Onload handler, determines tile back/foreground colours
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/dd HH:mm"
        let currentYear = DateHelper.todayShort(self.state.session.date, format: "yyyy")
        let currentMonth = DateHelper.todayShort(self.state.session.date, format: "M")
        if let date = formatter.date(from: "\(currentYear)/\(self.index + 1)/01 00:01") {
            self.isSelected = currentMonth == DateHelper.todayShort(date, format: "M")
        }

        self.bgColour = .clear
        self.fgColour = .white

        if self.isSelected {
            self.bgColour = self.state.theme.tint
            self.fgColour = Theme.base
        }
    }
}

extension WidgetLibrary.UI.EntityCalendar.Year {
    /// Onload handler, determines tile back/foreground colours
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = .clear
        self.fgColour = .white
        self.prepareColourData()

        if self.isSelected {
            self.bgColour = self.state.theme.tint
            self.fgColour = Theme.base
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
                    self.colourData.insert(job.backgroundColor)
                }
            }
        } else {
            let jobs = CoreDataTasks(moc: self.state.moc)
                .jobsForTasksDueToday(self.date)
                .sorted(by: {$0.created ?? Date() < $1.created ?? Date()})
            if !jobs.isEmpty {
                for job in jobs {
                    self.colourData.insert(job.backgroundColor)
                }
            }
        }
    }
}
