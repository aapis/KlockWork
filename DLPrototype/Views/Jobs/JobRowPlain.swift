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
    @EnvironmentObject public var jm: CoreDataJob

    var body: some View {
        HStack(spacing: 1) {
            project

            ZStack(alignment: .leading) {
                Color.clear

                HStack {
                    Button {
                        nav.view = AnyView(JobDashboard(defaultSelectedJob: job.jid))
                        nav.parent = .jobs
                        nav.sidebar = AnyView(JobDashboardSidebar())
                    } label: {
                        Text(job.jid.string)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 10)
                            .useDefaultHover({_ in})
                            .help("Edit job")
                    }
                    .buttonStyle(.borderless)
                    .underline()

                    if job.uri != nil {
                        Spacer()
                        Link(destination: job.uri!, label: {
                            Image(systemName: "link")
                                .foregroundColor(.white)
                                .useDefaultHover({_ in})
                                .help("Visit job URL on the web")
                        })
                        .padding([.trailing], 5)
                    }
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
