//
//  JobPlanningGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

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
//                    FancyButtonv2(
//                        text: "\(self.job.title ?? self.job.jid.string)",
//                        action: {self.nav.to(.jobs)},
//                        icon: "hammer",
//                        fgColour: colour.isBright() ? Theme.base : .white,
//                        showIcon: false,
//                        size: .link,
//                        type: .clear
//                    )
                    Button {
                        self.nav.session.job = self.job
                        self.nav.to(.jobs)
                    } label: {
                        HStack {
                            Text("\(self.job.title ?? self.job.jid.string)")
                            Spacer()
                        }
                        .foregroundStyle(self.colour.isBright() ? Theme.base : .white)
                        .useDefaultHover({_ in})
                    }
                    .buttonStyle(.plain)

                    Button {
                        if !self.nav.planning.jobs.contains(self.job) {
                            self.nav.planning.jobs.insert(self.job)
                        } else {
                            self.nav.planning.jobs.remove(job)
                        }

                        if nav.planning.jobs.count == 0 {
                            nav.planning.reset(nav.session.date)
                            nav.session.plan = nil
                            nav.session.gif = .normal
                        } else {
                            let plan = nav.planning.finalize(nav.session.date)
                            nav.session.plan = plan
                        }
                    } label: {
                        if !self.nav.planning.jobs.contains(self.job) {
                            Image(systemName: highlighted ? "plus.square.fill" : "plus.square.dashed")
                                .foregroundColor(colour.isBright() ? Theme.base : .white)
                                .font(.title)
                        } else {
                            Image(systemName: highlighted ? "clear.fill" : "clear")
                                .foregroundColor(colour.isBright() ? Theme.base : .white)
                                .font(.title)
                        }
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
        self.colour = self.job.backgroundColor
    }
}
