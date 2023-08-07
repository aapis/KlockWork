//
//  DateSelectorWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DateSelectorWidget: View {
    @Binding public var isDatePickerPresented: Bool

    @State private var days: [IdentifiableDay] = []

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var nav: Navigation

    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                FancyButtonv2(
                    text: formattedDate(),
                    action: actionOpenSelector,
                    fgColour: .black,
                    showLabel: true,
                    showIcon: false,
                    size: .titleLink,
                    type: .titleLink
                )
                .padding()

                Spacer()
                SecondaryOpenButton
            }
            .background(.white)
            .frame(height: 78)
            .border(width: 3, edges: [.bottom], color: Color.lightGray())

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
                            }
                        }
                    }
                }
                .background(.white)
            }
        }
        .onAppear(perform: actionOnAppear)
    }

    @ViewBuilder private var SecondaryOpenButton: some View {
        Button {
            actionOpenSelector()
        } label: {
            ZStack {
                Color.lightGray()
                VStack(alignment: .center) {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(Theme.fontSubTitle)
                        .foregroundColor(.black)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 50)
    }
}

extension DateSelectorWidget {
    struct DateSelectorRow: View {
        public var day: IdentifiableDay
        public var callback: ((IdentifiableDay) -> Void)?
        public var current: Bool = false
        public var active: Bool = false

        @State private var highlighted: Bool = false

        var body: some View {
            VStack(spacing: 0) {
                Button {
                    if let cb = callback {
                        cb(day)
                    }
                } label: {
                    DefaultRow
                }
                .font(Theme.fontTitle)
                .buttonStyle(.plain)
                .useDefaultHover({ inside in highlighted = inside})
                .background(active ? Theme.secondary : highlighted ?  Color.lightGray() : .clear)
            }
        }

        private var DefaultRow: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    TodayIndicator
                    Text(formatDate())
                    Spacer()
                    RecordCountBadge
                }
                .foregroundColor(.black)
                .padding()

                FancyDivider(height: 3)
                    .background(Color.lightGray())
            }
        }

        private var RecordCountBadge: some View {
            ZStack {
                (highlighted ? active ? Color.white.opacity(0.5) : Theme.secondary : Color.lightGray())
                Text(String(day.recordCount))
                    .help("\(day.recordCount) records")
                    .font(.body)
            }
            .mask {
                Circle()
            }
            .frame(width: 30, height: 30)
        }

        @ViewBuilder var TodayIndicator: some View {
            (
                current ?
                Image(systemName: "calendar")
                    .padding([.trailing])
                    .foregroundColor(.black)
                    .help("That's today!")
                : nil
            )
        }
    }
}

extension DateSelectorWidget {
    private func actionOnAppear() -> Void {
        // TODO: add dateFormat: "EEEEEE - yyyy-MM-dd"
        days = DateHelper.dateObjectsBeforeToday(numPastDates, moc: moc)
    }

    private func actionOpenSelector() -> Void {
        withAnimation(.spring(), {
            isDatePickerPresented.toggle()
        })
    }

    private func actionOnChangeDate(_ day: IdentifiableDay) -> Void {
        if let selectedDate = day.date {
            nav.session.date = selectedDate
        }

        actionOpenSelector()
    }

    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
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
}

extension DateSelectorWidget.DateSelectorRow {
    private func formatDate() -> String {
        if let date = day.date {
            let df = DateFormatter()
            df.dateFormat = "MMMM d"
            return df.string(from: date)
        }

        return day.string
    }
}
