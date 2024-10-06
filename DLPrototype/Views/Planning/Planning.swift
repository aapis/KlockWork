//
//  Planning.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    @EnvironmentObject public var nav: Navigation
    private let maxItems: Int = 6
    private let title: String = "Planning"
    private let page: PageConfiguration.AppPage = .planning
    private let description: String = "Use the daily plan to organize your day. Feature plans allow you to define projects of any scope!"
    private let buttons: [ToolbarButton] = [
        ToolbarButton(
            id: 0,
            helpText: "What are you working on today?",
            icon: "calendar",
            labelText: "Daily",
            contents: AnyView(Planning.Today())
        ),
//        ToolbarButton(
//            id: 1,
//            helpText: "Feature planning",
//            icon: "list.bullet.below.rectangle",
//            labelText: "Feature",
//            contents: AnyView(Planning.Feature())
//        )
        ToolbarButton(
            id: 1,
            helpText: "Upcoming",
            icon: "hourglass",
            labelText: "Upcoming",
            contents: AnyView(Planning.Upcoming())
        ),
        ToolbarButton(
            id: 2,
            helpText: "Overdue",
            icon: "alarm",
            labelText: "Overdue",
            contents: AnyView(Planning.Overdue())
        )
    ]

    // @TODO: make this customizable
    static public let tooManyJobs: Int = 5
    static public let tooManyTasks: Int = 8
    static public let tooManyProjects: Int = 4
    @State private var jobs: [Job] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Title(text: title)
                Spacer()
            }

            Text(description)
                .padding(.bottom, 10)

            FancyGenericToolbar(buttons: buttons, standalone: true, mode: .compact, page: self.page)
        }
        .padding()
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.jobs) { self.actionOnChangeJobs()}
    }
}

extension Planning {
    enum PlanningObjectType {
        case tasks, notes
    }

    private func actionOnAppear() -> Void {
        actionOnChangeJobs()
    }

    private func actionOnChangeJobs() -> Void {
        jobs = Array(nav.planning.jobs).sorted(by: {$0.jid > $1.jid})
    }
}
