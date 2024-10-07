//
//  DateSelectorWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

// @TODO: https://developer.apple.com/documentation/swiftui/datepickerstyle/field use this somehow
struct DateSelectorWidget: View {
    @State private var days: [IdentifiableDay] = []
    @State private var highlighted: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var nav: Navigation
    @EnvironmentObject private var updater: ViewUpdater

    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        self.actionOpenSelector()
                    } label: {
                        ZStack {
                            !areSameDate(nav.session.date, Date()) ? Theme.base :
                            (isDatePickerPresented ? Theme.secondary : Color.lightGray())
                            HStack(alignment: .center) {
                                Image(systemName: self.isDatePickerPresented ? "chevron.up.chevron.down" : "calendar")
                                Text(self.formattedDate())
                            }
                            .padding(8)
                        }
                        .clipShape(.capsule(style: .continuous))
                        .foregroundColor(!areSameDate(nav.session.date, Date()) ? .gray : Theme.base)
                        .font(Theme.fontSubTitle)
                        .padding(.top, 10)
                        .frame(width: 210)
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({ inside in highlighted = inside})
                }

                Spacer()
                HStack(alignment: .center) {
                    FancyButtonv2(
                        text: "Previous day",
                        action: actionPreviousDay,
                        icon: "chevron.left",
                        fgColour: .black,
                        showLabel: false,
                        size: .titleLink,
                        type: .titleLink
                    )

                    FancyButtonv2(
                        text: "Next day",
                        action: actionNextDay,
                        icon: "chevron.right",
                        fgColour: .black,
                        showLabel: false,
                        size: .titleLink,
                        type: .titleLink
                    )
                }
                .frame(height: 20)
                .padding(.leading)
                .padding(.top, 15)
            }
            .padding(10)
            .background(areSameDate(nav.session.date, Date()) ? .yellow.opacity(0.8) : .white.opacity(0.4))
            .frame(height: 40)

            if isDatePickerPresented {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(days) { day in
                                DateSelectorRow(
                                    day: day,
                                    callback: actionOnChangeDate,
                                    current: isCurrentDay(day),
                                    active: isActive(day)
                                )
                                .environmentObject(nav)
                            }
                        }
                    }

                    ResetDateButton(isDatePickerPresented: $isDatePickerPresented)
                }
                .background(.white)
                .padding(.top, 13)
            }
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension DateSelectorWidget {
    struct DateSelectorRow: View {
        public var day: IdentifiableDay
        public var callback: ((IdentifiableDay) -> Void)?
        public var current: Bool = false
        public var active: Bool = false

        @State private var highlighted: Bool = false
        @State private var isWeekend: Bool = false

        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(spacing: 0) {
                Button {
                    if let cb = callback {
                        cb(day)
                    }
                } label: {
                    if !isWeekend {
                        DefaultRow
                    } else {
                        DefaultRow
                            .opacity(0.4)
                    }
                }
                .onAppear(perform: actionOnAppear)
                .font(Theme.fontSubTitle)
                .buttonStyle(.plain)
                .useDefaultHover({ inside in highlighted = inside})
            }
        }

        private var DefaultRow: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    Text(formatDate())
                    Spacer()
                    RecordCountBadge
                }
                .padding()
                .background(active ? Theme.secondary : highlighted ?  Color.lightGray() : .clear)
                .foregroundColor(.black)

                FancyDivider(height: 3)
                    .background(Color.lightGray())
            }
        }

        private var RecordCountBadge: some View {
            ZStack(alignment: .center) {
                if current {
                    Color.yellow
                } else {
                    (highlighted ? (active ? Color.white.opacity(0.5) : Theme.secondary) : Color.lightGray())
                }
                Text(String(day.recordCount))
                    .help("\(day.recordCount) records")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.55))
            }
            .clipShape(.capsule(style: .continuous))
            .frame(width: 30)
        }
    }
    
    struct ResetDateButton: View {
        @Binding public var isDatePickerPresented: Bool
        
        private let date: Date = Date()
        
        @State private var highlighted: Bool = false
        
        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            HStack(alignment: .top) {
                Button {
                    nav.session.date = date
                    isDatePickerPresented.toggle()
                } label: {
                    Text("Reset to today")
                        .help(date.formatted(date: .abbreviated, time: .omitted).description)
                        .foregroundColor(.black)
                        .font(Theme.fontTitle)
                        .padding()
                        .underline(highlighted)
                }
                .buttonStyle(.plain)
                .useDefaultHover({ inside in highlighted = inside})
                Spacer()
            }
            .background(Color.lightGray())
        }
    }
}

extension DateSelectorWidget {
    private func actionOnAppear() -> Void {
        days = DateHelper.dateObjectsBeforeToday(numPastDates, moc: moc)

        // Auto-advance date to tomorrow when the clock strikes midnight
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { timer in
            let components = Calendar.autoupdatingCurrent.dateComponents([.hour], from: Date())

            if let hour = components.hour {
                if hour == 24 {
                    nav.session.date += 86400
                }
            }
        }
    }

    private func actionOpenSelector() -> Void {
        isDatePickerPresented.toggle()
    }

    private func actionOnChangeDate(_ day: IdentifiableDay) -> Void {
        if let selectedDate = day.date {
            nav.session.date = selectedDate
            nav.session.idate = day
        }

        actionOpenSelector()
    }

    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df.string(from: nav.session.date)
    }

    private func isCurrentDay(_ day: IdentifiableDay) -> Bool {
        let currentDay = Date.now.timeIntervalSince1970
        if let date = day.date  {
            let rowDay = date.timeIntervalSince1970
            let window = (currentDay - 86400, currentDay + 84600)

            return rowDay > window.0 && rowDay <= window.1
        }

        return false
    }

    private func isActive(_ day: IdentifiableDay) -> Bool {
        if let date = day.date  {
            return areSameDate(date, nav.session.date)
        }

        return false
    }

    private func areSameDate(_ lhs: Date, _ rhs: Date) -> Bool {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        let fmtDate = df.string(from: lhs)
        let fmtSessionDate = df.string(from: rhs)

        return fmtDate == fmtSessionDate
    }

    private func actionPreviousDay() -> Void {
        nav.session.date -= 86400
    }

    private func actionNextDay() -> Void {
        nav.session.date += 86400
    }
}

extension DateSelectorWidget.DateSelectorRow {
    private func actionOnAppear() -> Void {
        if let date = day.date {
            let df = DateFormatter()
            df.dateFormat = "EE"
            let fmt = df.string(from: date)

            isWeekend = ["Sat", "Sun"].contains(fmt)
        }
    }

    private func formatDate() -> String {
        if let date = day.date {
            let df = DateFormatter()
            df.dateFormat = "EE MMMM d"
            return df.string(from: date)
        }

        return day.string
    }
}

extension DateSelectorWidget.ResetDateButton {
    
}

struct DateSelectorReduxWidget: View {
    var body: some View {
        Button {
            
        } label: {
            ZStack(alignment: .bottom) {
                LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                    .opacity(0.4)
                    .blendMode(.softLight)
                    .frame(height: 20)

                HStack(alignment: .center) {
                    Image(systemName: "calendar")
                    Text("September 30, 2024")
                    Spacer()
                }
                .padding()
            }
//            .frame(height: 24)
        }

        .buttonStyle(.plain)
    }
}
