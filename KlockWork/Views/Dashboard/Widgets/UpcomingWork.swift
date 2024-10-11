//
//  NextThreeDays.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-06.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct UpcomingWork: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("dashboard.maxDaysUpcomingWork") public var maxDaysUpcomingWork: Double = 5
    @AppStorage("dashboard.widget.upcomingWork") public var showWidgetUpcomingWork: Bool = true
    public let title: String = "Upcoming Work"
    public var page: PageConfiguration.AppPage = .find
    @State private var forecast: [Forecast] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)", fgColour: .white)
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: self.actionOnCloseWidget,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true,
                    size: .tiny,
                    type: .clear
                )
            }
            .padding()
            .background(Theme.darkBtnColour)

            ForEach(self.forecast, id: \.id) { row in row }
        }
        .background(self.state.session.appPage.primaryColour)
//        .frame(height: 250)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.maxDaysUpcomingWork) { self.actionOnAppear() }
    }
}

extension UpcomingWork {
    /// Onload handler. Creates forecast
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.forecast = []
        let dates = Date()..<DateHelper.daysAhead(self.maxDaysUpcomingWork)
        let hrs24: TimeInterval = 60*60*24

        for date in stride(from: Date(), to: dates.upperBound, by: hrs24) {
            self.forecast.append(
                Forecast(
                    date: DateHelper.startOfDay(date),
                    callback: self.actionOnForecastTap,
                    type: .row,
                    page: self.page
                )
            )
        }
    }

    private func actionOnForecastTap() -> Void {
        self.state.to(.planning)
    }

    private func actionOnCloseWidget() -> Void {
        self.showWidgetUpcomingWork.toggle()
    }
}
