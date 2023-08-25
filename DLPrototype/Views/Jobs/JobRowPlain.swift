//
//  JobRowPlain.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobRowPlain: View {
    public var job: Job
    public var location: WidgetLocation = .sidebar

    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            project
            ZStack(alignment: .topLeading) {
                Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                SidebarItem(
                    data: job.jid.string,
                    help: "Edit job \(job.jid.string)",
                    icon: "arrowshape.right",
                    orientation: .right,
                    action: action
                )
            }
        }
    }

    @ViewBuilder var project: some View {
        Group {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if job.project != nil {
                        Color.fromStored(job.project!.colour ?? Theme.rowColourAsDouble)
                    } else {
                        Theme.rowColour
                    }
                }
            }
        }
        .frame(width: 5)
    }
}

extension JobRowPlain {
    private func action() -> Void {
        switch location {
        case .sidebar, .header, .taskbar:
            actionOpenJob()
        case .content:
            actionUpdatePlanningStore()
        }
    }

    private func actionOpenJob() -> Void {
        nav.reset()
        nav.setId()
        nav.setParent(.jobs)
        nav.session.setJob(job)
        nav.setView(AnyView(JobDashboard(defaultSelectedJob: job)))
        nav.setSidebar(AnyView(JobDashboardSidebar()))
    }

    private func actionUpdatePlanningStore() -> Void {
        nav.session.planning.jobs.insert(job)
    }
}
