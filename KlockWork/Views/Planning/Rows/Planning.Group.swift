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
                    FancyButtonv2(
                        text: "\(self.job.title ?? self.job.jid.string)",
                        action: {
                            self.nav.session.job = self.job
                            self.nav.to(.jobs)
                        },
                        fgColour: colour.isBright() ? Theme.base : .white,
                        showIcon: false,
                        size: .link,
                        type: .clear,
                        font: .headline
                    )
                    Button {
                        if !self.nav.planning.jobs.contains(self.job) {
                            self.nav.planning.jobs.insert(self.job)
                        } else {
                            self.nav.planning.jobs.remove(self.job)
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
                            HStack {
                                Text("Suggested")
                                Image(systemName: highlighted ? "plus.square.fill" : "plus.square.dashed")
                                    .font(.title)
                            }
                            .foregroundColor(colour.isBright() ? Theme.base : .white)
                        } else {
                            Image(systemName: highlighted ? "clear.fill" : "clear")
                                .foregroundColor(colour.isBright() ? Theme.base : .white)
                                .font(.title)
                        }
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({inside in highlighted = inside})
                }
                .padding(8)
                .background(self.colour)
                .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))
                Planning.Row(job: job, index: jobs.firstIndex(of: job), type: .tasks)
                Planning.Row(job: job, index: jobs.firstIndex(of: job), type: .notes)
            }
            .clipShape(.rect(bottomLeadingRadius: 5, bottomTrailingRadius: 5))
            .onAppear(perform: self.actionOnAppear)
            .contextMenu {
                Button("Remove", action: {self.nav.planning.jobs.remove(self.job)})
            }
        }
    }
}

extension Planning.Group {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.colour = self.job.backgroundColor
    }
}
