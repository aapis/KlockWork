//
//  JobPlanningGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Group: View {
        var job: Job
        var jobs: [Job]

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    FancyButtonv2(
                        text: "Job #\(job.jid.string)",
                        icon: "hammer",
                        fgColour: colour.isBright() ? .black : .white,
                        showIcon: false,
                        size: .link,
                        type: .clear,
                        redirect: AnyView(JobDashboard(defaultSelectedJob: job)),
                        pageType: .notes,
                        sidebar: AnyView(JobDashboardSidebar())
                    )

                    Spacer()
                    Button {
                        nav.planning.jobs.remove(job)

                        if nav.planning.jobs.count == 0 {
                            nav.planning.reset(nav.session.date)
                            nav.session.plan = nil
                            nav.session.gif = .normal
                        } else {
                            let plan = nav.planning.finalize(nav.session.date)
                            nav.session.plan = plan
                        }
                    } label: {
                        Image(systemName: highlighted ? "clear.fill" : "clear")
                            .foregroundColor(colour.isBright() ? .black : .white)
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({inside in highlighted = inside})
                }
                .padding()
                .background(colour)

                Planning.Row(job: job, index: jobs.firstIndex(of: job), type: .tasks)
                Planning.Row(job: job, index: jobs.firstIndex(of: job), type: .notes)
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Group {
    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)
    }
}
