//
//  JobDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDashboard: View {
    var defaultSelectedJob: Job?

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    if defaultSelectedJob == nil {
                        Title(text: "Find or create a new job")
                    }
                    Spacer()
                    FancyButtonv2(
                        text: "New job",
                        action: {},
                        icon: "plus",
                        showLabel: false,
                        redirect: AnyView(JobCreate()),
                        pageType: .jobs,
                        sidebar: AnyView(JobDashboardSidebar())
                    )
                }

                if let jerb = defaultSelectedJob {
                    JobView(job: jerb).environmentObject(jm)
                }
                else {
                    Text("Perform a search using the sidebar widget or create a new job using the \"New Job\" (or +) button.")
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: defaultSelectedJob, perform: actionOnChange)
        .id(updater.get("job.dashboard"))
    }
}

extension JobDashboard {
    private func actionOnAppear() -> Void {

    }

    private func actionOnChange(job: Job?) -> Void {

    }
}
