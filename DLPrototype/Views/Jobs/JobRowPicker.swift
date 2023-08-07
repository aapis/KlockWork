//
//  JobRowJobPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobRowPicker: View {
    public var job: Job

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
                    action: actionOpenJob
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

extension JobRowPicker {
    private func actionOpenJob() -> Void {
        nav.reset()
        nav.setId()
        nav.setParent(.today)
        nav.session.job = job
        nav.setView(AnyView(Today()))
        nav.setSidebar(AnyView(TodaySidebar()))
    }
}
