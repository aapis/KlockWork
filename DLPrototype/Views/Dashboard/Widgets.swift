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
    @AppStorage("dashboard.widget.history") public var showWidgetHistory: Bool = true
    @AppStorage("dashboard.widget.thisweek") public var showWidgetThisWeek: Bool = true
    @AppStorage("dashboard.widget.thismonth") public var showWidgetThisMonth: Bool = true
    @AppStorage("dashboard.widget.thisyear") public var showWidgetThisYear: Bool = true
    @AppStorage("dashboard.widget.favnotes") public var showWidgetFavNotes: Bool = true
    @AppStorage("dashboard.widget.recentProjects") public var showWidgetRecentProjects: Bool = true
    @AppStorage("dashboard.widget.recentJobs") public var showWidgetRecentJobs: Bool = true

    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                
                Grid(alignment: .top, horizontalSpacing: 5, verticalSpacing: 5) {
                    GridRow {
                        if showWidgetHistory {
                            ThisDay()
                                .environmentObject(crm)
                                .environmentObject(ce)
                        }

                        if showWidgetThisWeek {
                            ThisWeek()
                                .environmentObject(crm)
                                .environmentObject(ce)
                        }

                        if showWidgetThisMonth {
                            ThisMonth()
                                .environmentObject(crm)
                                .environmentObject(ce)
                        }
                    }
                    .frame(maxHeight: 250)
                    
                    GridRow(alignment: .top) {
                        if showWidgetThisYear {
                            ThisYear()
                                .environmentObject(crm)
                                .environmentObject(ce)
                        }

                        if showWidgetFavNotes {
                            Favourites()
                        }

                        if showWidgetRecentProjects {
                            RecentProjects()
                        }
                    }
                    .frame(maxHeight: 250)

                    GridRow(alignment: .top) {
                        if showWidgetRecentJobs {
                            RecentJobs()
                        }
                    }
                    .frame(maxHeight: 250)
                }
                
                Spacer()
            }
        }
    }
}
