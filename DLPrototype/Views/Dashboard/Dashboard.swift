//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Dashboard: View {
    static public let id: UUID = UUID()

    @State public var searching: Bool = false

    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FindDashboard(searching: $searching)
            FancyDivider()

            if !searching {
                Widgets()
                    .environmentObject(crm)
                    .environmentObject(ce)
            }
        }
        .font(Theme.font)
        .padding()
        .background(Theme.toolbarColour)
    }
}
