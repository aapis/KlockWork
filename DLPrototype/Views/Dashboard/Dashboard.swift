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
    
    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Title(text: "Welcome back!", image: "house")
                Spacer()
            }

            FancyDivider()
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
