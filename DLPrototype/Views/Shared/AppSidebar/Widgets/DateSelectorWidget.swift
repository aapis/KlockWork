//
//  DateSelectorWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DateSelectorRow: View {
    public var day: IdentifiableDay
    public var callback: ((IdentifiableDay) -> Void)?

    @State private var highlighted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                if let cb = callback {
                    cb(day)
                }
            } label: {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .listRowSeparatorLeading, spacing: 0) {
                            ZStack {
                                Theme.secondary
                            }
                        }
                        .frame(width: 20)

                        Text(day.string)
                            .foregroundColor(.black)
                            .padding()
                        Spacer()
                    }
                }
            }

            .font(Theme.fontTitle)
            .buttonStyle(.plain)
            .useDefaultHover({ inside in highlighted = inside})
            .background(highlighted ? .black.opacity(0.2) : .clear)
        }
    }
}

struct DateSelectorWidget: View {
    @Binding public var isDatePickerPresented: Bool

    @State private var days: [IdentifiableDay] = []

    @EnvironmentObject private var nav: Navigation

    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                SecondaryOpenButton

                FancyButtonv2(
                    text: formattedDate(),
                    action: actionOpenSelector,
                    fgColour: .black,
                    showLabel: true,
                    showIcon: false,
                    size: .titleLink,
                    type: .titleLink
                )
                Spacer()
            }
            .background(.white)
            .frame(height: 75)

            if isDatePickerPresented {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(days) { day in
                                DateSelectorRow(day: day, callback: actionOnChangeDate)
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
                if isDatePickerPresented {
                    Theme.secondary
                } else {
                    Theme.tabActiveColour
                    VStack {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .padding([.bottom], 5)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 20)
    }
}

extension DateSelectorWidget {
    private func actionOnAppear() -> Void {
        // TODO: add dateFormat: "EEEEEE - yyyy-MM-dd"
        days = DateHelper.dateObjectsBeforeToday(numPastDates)
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
}
