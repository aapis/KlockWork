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
    public var location: WidgetLocation

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            project
            ZStack(alignment: .topLeading) {
                job.colour_from_stored()
                HStack(spacing: 0) {
                    if let jerb = nav.session.job {
                        if jerb == job {
                            FancyStar(background: jerb.colour_from_stored())
                                .padding(.leading, 10)
                                .help("Records you create will be associated with this job (#\(job.jid.string))")
                        }
                    }

                    SidebarItem(
                        data: job.jid.string,
                        help: "Set current job to \(job.jid.string)",
                        icon: "arrowshape.right",
                        orientation: .right,
                        action: action,
                        showBorder: false
                    )
                    .foregroundColor(job.colour != nil && job.colour_from_stored().isBright() ? .black : .white)
                }
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
