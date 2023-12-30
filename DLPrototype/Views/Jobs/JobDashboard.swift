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

    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)

    @Environment(\.managedObjectContext) var moc
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

                About()

                if let jerb = defaultSelectedJob {
                    JobView(job: jerb).environmentObject(jm)
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

extension JobDashboard {
    struct About: View {
        private let copy: String = "Perform a search using the sidebar widget or create a new job using the \"New Job\" (or +) button."

        var body: some View {
            VStack {
                HStack {
                    Text(copy).padding(15)
                    Spacer()
                }
            }
            .background(Theme.cOrange)
        }
    }
}
