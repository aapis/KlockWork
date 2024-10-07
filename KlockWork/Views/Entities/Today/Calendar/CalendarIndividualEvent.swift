//
//  CalendarIndividualEvent.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-18.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore
import EventKit

struct CalendarIndividualEvent: View {
    public var event: EKEvent
    public var currentHour: Int

    private var hourStart: Int = 0
    private var hourEnd: Int = 0
    private var startDateFormatted: String = ""
    private var endDateFormatted: String = ""

    public init(event: EKEvent, currentHour: Int) {
        self.event = event
        self.currentHour = currentHour
        self.hourStart = Calendar.autoupdatingCurrent.component(.hour, from: self.event.startDate!)
        self.hourEnd = Calendar.autoupdatingCurrent.component(.hour, from: self.event.endDate!)
        self.startDateFormatted = self.event.startDate.formatted(date: .omitted, time: .shortened)
        self.endDateFormatted = self.event.endDate.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        // Aligns events with the appropriate start time column
        if hourStart == currentHour {
            GridRow(alignment: .top) {
                Text("\(startDateFormatted)-\(endDateFormatted)\n\(event.title)")
                    .padding(5)
                    .background(Theme.rowStatusYellow)
                    .padding([.bottom, .top], 5)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}
