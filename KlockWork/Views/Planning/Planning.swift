//
//  Planning.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct Planning: View {
    @EnvironmentObject public var nav: Navigation
    private let maxItems: Int = 6
    private let title: String = "Planning"
    private let page: PageConfiguration.AppPage = .planning
    private let eType: PageConfiguration.EntityType = .BruceWillis
    private let description: String = "Use the daily plan to organize your day, Upcoming to find out what's next, and Overdue to see what you've missed."
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
            helpText: "Incomplete tasks",
            icon: "hourglass",
            labelText: "Upcoming",
            contents: AnyView(Planning.Upcoming())
        ),
        ToolbarButton(
            id: 2,
            helpText: "Overdue tasks",
            icon: "alarm",
            labelText: "Overdue",
            contents: AnyView(Planning.Overdue())
        ),
        ToolbarButton(
            id: 3,
            helpText: "Tasks that have no due date",
            icon: "exclamationmark.triangle",
            labelText: "No Due Date",
            contents: AnyView(Planning.NoDueDate())
        )
    ]

    // @TODO: make this customizable
    static public let tooManyJobs: Int = 5
    static public let tooManyTasks: Int = 8
    static public let tooManyProjects: Int = 4
    @State private var jobs: [Job] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UniversalHeader.Widget(
                type: self.eType,
                title: "Planning",
                additionalDetails: AnyView(
                    WidgetLibrary.UI.Meetings()
                )
            )
            FancyHelpText(text: self.description, page: self.page)
            FancyDivider()
            FancyGenericToolbar(
                buttons: self.buttons,
                standalone: true,
                mode: .compact,
                page: self.page
            )
        }
        .padding()
        .background(self.PageBackground)
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.jobs) { self.actionOnChangeJobs()}
    }

    @ViewBuilder private var PageBackground: some View {
        if [.classic].contains(self.nav.theme.style) {
            ZStack {
                self.nav.session.appPage.primaryColour.saturation(0.7)
                Theme.base.blendMode(.softLight).opacity(0.5)
            }
        }
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
