//
//  Planning.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    private let maxItems: Int = 6
    private let title: String = "Planning"
    private let page: PageConfiguration.AppPage = .planning
    private let description: String = "Use the daily plan to organize your day. Feature plans allow you to define projects of any scope!"
    private let buttons: [ToolbarButton] = [
        ToolbarButton(
            id: 0,
            helpText: "What are you working on today?",
            label: AnyView(
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                    Text("Daily")
                }
            ),
            contents: AnyView(Planning.Today())
        ),
        ToolbarButton(
            id: 1,
            helpText: "Feature planning",
            label: AnyView(
                HStack {
                    Image(systemName: "list.bullet.below.rectangle")
                        .font(.title2)
                    Text("Feature")
                }
            ),
            contents: AnyView(Planning.Feature())
        )
    ]

    // @TODO: make this customizable
    static public let tooManyJobs: Int = 5
    static public let tooManyTasks: Int = 8
    static public let tooManyProjects: Int = 4

    @EnvironmentObject public var nav: Navigation

    @State private var jobs: [Job] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Title(text: title)
                Spacer()
            }

            Text(description)
                .padding(.bottom, 10)

            FancyGenericToolbar(buttons: buttons, standalone: true)
        }
        .padding()
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.jobs) { self.actionOnChangeJobs(nav.planning.jobs)}
    }
}

extension Planning {
    enum PlanningObjectType {
        case tasks, notes
    }

    private func actionOnAppear() -> Void {
        actionOnChangeJobs(nav.planning.jobs)
    }

    private func actionOnChangeJobs(_ newJobs: Set<Job>) -> Void {
        jobs = Array(newJobs).sorted(by: {$0.jid > $1.jid})
    }
}
