//
//  JobRowJobPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct JobRowPicker: View {
    public var job: Job
    public var location: WidgetLocation

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if let jerb = nav.session.job {
                if jerb == job {
                    FancyStar(background: jerb.colour_from_stored())
                        .padding(.leading, 10)
                        .help("Records you create will be associated with this job (#\(job.jid.string))")
                }
            }

            SidebarItem(
                data: job.title ?? job.jid.string,
                help: "Set current job to \(job.title ?? job.jid.string)",
                icon: "arrowshape.right",
                orientation: .right,
                action: self.action,
                showBorder: false,
                showButton: false
            )
            .foregroundColor(job.colour != nil && job.colour_from_stored().isBright() ? .black : .white)
        }
        .background(job.colour_from_stored())
        .padding(.leading, 10)
        .border(width: 10, edges: [.leading], color: Color.fromStored(job.project?.colour ?? Theme.rowColourAsDouble))
    }
}

extension JobRowPicker {
    private func action() -> Void {
        switch location {
        case .sidebar, .header, .taskbar, .inspector:
            actionOpenJob()
        case .content:
            actionUpdatePlanningStore()
        }
    }

    private func actionOpenJob() -> Void {
        nav.setId()

        if let parent = nav.parent {
            if parent == .jobs {
                nav.session.setJob(job)
            } else if parent == .planning {
                actionUpdatePlanningStore()
            } else if parent == .terms {
                nav.session.setJob(job)
            } else {
                nav.session.setJob(job)
                nav.to(.today)
            }
        }
    }

    private func actionUpdatePlanningStore() -> Void {
        nav.planning.jobs.insert(job)
        nav.planning.projects.insert(job.project!)

        // projects are allowed to be unowned
        if let company = job.project!.company {
            nav.planning.companies.insert(company)
        }
    }
}
