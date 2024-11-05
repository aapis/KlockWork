//
//  DayInHistory.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct DayInHistory: View {
    @EnvironmentObject public var state: Navigation
    public var year: Int
    public var date: Date
    public var count: Int
    public var highlight: Bool {
        return count == 0
    }
    public var isToday: Bool {
        return DateHelper.todayShort(format: "yyyy") == String(self.year)
    }

    var body: some View {
        SidebarItem(
            data: self.linkLabel(),
            help: self.linkLabel(),
            icon: "chevron.right",
            orientation: .right,
            action: {
                self.state.session.date = self.date
                self.state.to(.today)
            },
            showBorder: false,
            showButton: false,
            contextMenu: AnyView(
                VStack {
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
            )
        )
        .background(self.isToday ? .yellow.opacity(0.5) : self.highlight ? Theme.base.opacity(0.3) : Theme.cPurple)
        .foregroundStyle(self.highlight ? Theme.lightWhite : .white)
    }
}

extension DayInHistory {
    /// Determines the correct text to display for each day block
    /// - Returns: String
    public func linkLabel() -> String {
        if self.isToday {
            return "\(self.count) \(self.count == 1 ? "record" : "records") today"
        } else {
            if self.count > 0 {
                return "\(self.count) \(self.count == 1 ? "record" : "records") from \(self.year)"
            }
        }

        return "No records from \(self.year)"
    }
}
