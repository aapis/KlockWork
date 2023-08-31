//
//  ProjectsDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectsDashboard: View {
    @EnvironmentObject public var updater: ViewUpdater
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) public var projects: FetchedResults<Project>
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                create
                search

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .id(updater.get("project.dashboard"))
    }
    
    @ViewBuilder
    var create: some View {
        HStack {
            Title(text: "\(projects.count) Projects")
            Spacer()
            FancyButtonv2(
                text: "New project",
                action: {},
                icon: "plus",
                showLabel: false,
                redirect: AnyView(ProjectCreate()),
                pageType: .projects,
                sidebar: AnyView(ProjectsDashboardSidebar())
            )
        }
    }
    
    @ViewBuilder
    var search: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            HStack(spacing: 0) {
                GridRow {
                    Group {
                        ZStack(alignment: .leading) {
                            Theme.headerColour
                            Text("Name")
                                .padding()
                        }
                    }

                    Group {
                        ZStack(alignment: .leading) {
                            Theme.headerColour
                            Text("# Jobs")
                                .padding()
                        }
                    }
                    .frame(width: 100)
                }
            }
            .frame(height: 46)

            projectsView
        }
        .font(Theme.font)
        .id(updater.get("project.dashboard"))
    }
    
    @ViewBuilder
    var projectsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(projects) { project in
                    ProjectRow(project: project)
                }
            }
        }
    }
}
