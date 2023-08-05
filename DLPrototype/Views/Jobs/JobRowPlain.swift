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

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
            SidebarItem(
                data: job.jid.string,
                help: "Edit job \(job.jid.string)",
                icon: "arrow.right",
                orientation: .right,
                action: actionOpenJob
            )
        }
    }
//    var body: some View {
//        HStack(spacing: 1) {
//            project
//
//            ZStack(alignment: .leading) {
//                HStack {
//                    Button {
//                        nav.view = AnyView(JobDashboard(defaultSelectedJob: job))
//                        nav.parent = .jobs
//                        nav.sidebar = AnyView(JobDashboardSidebar())
//                    } label: {
//                        Text(job.jid.string)
//                            .foregroundColor(.white)
//                            .padding([.leading, .trailing], 10)
//                            .useDefaultHover({_ in})
//                            .help("Edit job")
//                    }
//                    .buttonStyle(.borderless)
//                    .underline()
//                    if job.uri != nil {
//                        Spacer()
//                        Link(destination: job.uri!, label: {
//                            Image(systemName: "link")
//                                .foregroundColor(.white)
//                                .useDefaultHover({_ in})
//                                .help("Visit job URL on the web")
//                        })
//                        .padding([.trailing], 5)
//                    }
//                }
//                .padding()
//            }
//        }
//    }

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
    private func actionOpenJob() -> Void {
        nav.view = AnyView(JobDashboard(defaultSelectedJob: job))
        nav.parent = .jobs
        nav.sidebar = AnyView(JobDashboardSidebar())
    }
}
