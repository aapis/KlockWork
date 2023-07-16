//
//  Widgets.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct WidgetLoading: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
    }
}

struct Widgets: View {
    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Welcome back!", image: "house")
                    Spacer()
                }
                
                FancyDivider()
                
                Grid(alignment: .top, horizontalSpacing: 5, verticalSpacing: 5) {
                    GridRow {
                        ThisDay()
                            .environmentObject(crm)
                            .environmentObject(ce)
                        ThisWeek()
                            .environmentObject(crm)
                            .environmentObject(ce)
                        ThisMonth()
                            .environmentObject(crm)
                            .environmentObject(ce)
                    }
                    .frame(maxHeight: 250)
                    
                    GridRow(alignment: .top) {
                        ThisYear()
                            .environmentObject(crm)
                            .environmentObject(ce)
                        Favourites()
                        RecentProjects()
                    }
                    .frame(maxHeight: 250)

                    GridRow(alignment: .top) {
                        RecentJobs()
                    }
                    .frame(maxHeight: 250)
                }
                
                Spacer()
            }
            .font(Theme.font)
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}
