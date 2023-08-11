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
                Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                HStack {
                    if let jerb = nav.session.job {
                        if jerb == job {
                            FancyStar(background: Color.fromStored(jerb.colour ?? Theme.rowColourAsDouble))
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
                        showBorder: false,
                        showButton: nav.session.job != job
                    )
                    .foregroundColor(job.colour != nil && Color.fromStored(job.colour!).isBright() ? .black : .white)
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
        case .sidebar, .header, .taskbar:
            actionOpenJob()
        case .content:
            actionUpdatePlanningStore()
        }
    }

    private func actionOpenJob() -> Void {
        nav.reset()
        nav.setId()
        nav.setParent(.today)
        nav.session.job = job
        nav.setView(AnyView(Today()))
        nav.setSidebar(AnyView(TodaySidebar()))
    }

    private func actionUpdatePlanningStore() -> Void {
        nav.session.planning.jobs.insert(job)
    }
}
