//
//  ProjectsDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct ProjectsDashboard: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("general.columns") private var numColumns: Int = 3
    @AppStorage("widget.jobs.showPublished") private var allowAlive: Bool = true
    @State private var projects: [Project] = []
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .projects
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    title: self.eType.label
                )
                if self.projects.count > 0 {
                    FancyHelpText(
                        text: "Projects own jobs, which define what needs to be done.",
                        page: self.page
                    )
                    FancyDivider()

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: self.columns, alignment: .leading, spacing: 10) {
                            ForEach(self.projects, id: \.objectID) { project in
                                ProjectBlock(project: project)
                            }
                        }
                    }
                } else {
                    FancyHelpText(
                        text: "No companies found",
                        page: self.page
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.project) { self.actionOnAppear() }
        .onChange(of: self.allowAlive) { self.actionOnAppear() }
    }
}

extension ProjectsDashboard {
    /// Onload handler. Filters to current Project if one is selected
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.project {
            self.projects = [stored]
        } else {
            if self.allowAlive {
                self.projects = CoreDataProjects(moc: self.state.moc).alive()
            } else {
                self.projects = CoreDataProjects(moc: self.state.moc).indescriminate()
            }
        }
    }
}
