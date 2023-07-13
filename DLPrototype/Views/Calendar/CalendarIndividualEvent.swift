//
//  CalendarIndividualEvent.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-18.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

struct CalendarIndividualEvent: View {
    public var event: EKEvent
    public var currentHour: Int
    public var type: CalendarEventType

    private var hourStart: Int = 0
    private var hourEnd: Int = 0
    private var startDateFormatted: String = ""
    private var endDateFormatted: String = ""

    public init(event: EKEvent, currentHour: Int, type: CalendarEventType) {
        self.event = event
        self.currentHour = currentHour
        self.type = type
        self.hourStart = Calendar.autoupdatingCurrent.component(.hour, from: self.event.startDate!)
        self.hourEnd = Calendar.autoupdatingCurrent.component(.hour, from: self.event.endDate!)
        self.startDateFormatted = self.event.startDate.formatted(date: .omitted, time: .shortened)
        self.endDateFormatted = self.event.endDate.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        // Aligns events with the appropriate start time column
        if hourStart == currentHour {
            GridRow(alignment: .top) {
                ZStack(alignment: .topLeading) {
                    Group {
                        type.colour
                    }

                    Group {
                        Text("\(startDateFormatted)-\(endDateFormatted)\n\(event.title)")
                            .foregroundColor(type.colour.isBright() ? Color.black : Color.white)
                    }
                }
//                .background(type.colour)
//                .frame(minWidth: 0, maxWidth: .infinity)
            }
//            .padding(5)
//            .background(type.colour)
//            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }

    private func content() -> String {
        return ""
    }
}
