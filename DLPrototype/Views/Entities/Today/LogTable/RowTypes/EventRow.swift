//
//  EventRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

struct EventRow: View, Identifiable {
    public var id = UUID()
    public var event: EKEvent

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(event.startDate!.formatted(date: .omitted, time: .shortened))
                Text("-")
                Text(event.endDate!.formatted(date: .omitted, time: .shortened))
                Text(event.title)
            }
            .padding(10)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}
