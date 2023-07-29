//
//  RecentJobs.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentJobs: View {
    public let title: String = "Recent Jobs"

    @FetchRequest public var resource: FetchedResults<Job>

    public init() {
        _resource = CoreDataJob.recentJobsWidgetData()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "New Job",
                    action: {},
                    icon: "plus",
                    showLabel: false,
                    size: .small,
                    redirect: AnyView(
                        JobCreate()
                    ),
                    pageType: .jobs
                )
            }
            Divider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 1) {
                    ForEach(resource) { job in
                        JobRow(job: job, colour: Color.fromStored(job.colour ?? Theme.rowColourAsDouble))
                    }
                }
            }
        }
        .padding()
        .border(Theme.darkBtnColour)
        .frame(height: 250)
    }
}
