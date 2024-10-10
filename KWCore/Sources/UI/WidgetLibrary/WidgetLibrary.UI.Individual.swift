//
//  WidgetLibrary.UI.Individual.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

extension WidgetLibrary.UI {
    struct Individual {
        struct Event: View {
            @EnvironmentObject public var state: Navigation
            public let event: EKEvent
            @State private var hasEventPassed: Bool = false

            var body: some View {
                SidebarItem(
                    data: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                    help: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                    icon: "chevron.right",
                    orientation: .right,
                    action: {self.state.session.search.inspectingEvent = self.event},
                    showBorder: false,
                    showButton: false
                )
                .background(self.hasEventPassed ? Theme.lightWhite : Color(event.calendar.color))
                .foregroundStyle(self.hasEventPassed ? Theme.lightBase : Theme.base)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.search.inspectingEvent) {
                    if let event = self.state.session.search.inspectingEvent {
                        self.state.setInspector(AnyView(Inspector(event: event)))
                    } else {
                        self.state.setInspector()
                    }
                }
            }
        }
    }
}

extension WidgetLibrary.UI.Individual.Event {
    /// Onload handler. Determines if event has passed or not
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.hasEventPassed = event.startDate < Date()
    }
}
