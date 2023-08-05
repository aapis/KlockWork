//
//  RecentProjects.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentProjects: View {
    public let title: String = "Recent Projects"

    @FetchRequest public var resource: FetchedResults<Project>

    public init() {
        _resource = CoreDataProjects.recentProjectsWidgetData()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "New Project",
                    action: {},
                    icon: "plus",
                    showLabel: false,
                    size: .small,
                    redirect: AnyView(ProjectCreate()),
                    pageType: .projects,
                    sidebar: AnyView(ProjectsDashboardSidebar())
                )
            }
            Divider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 1) {
                    ForEach(resource) { project in
                        ProjectRow(project: project)
                    }
                }
            }
        }
        .padding()
        .border(Theme.darkBtnColour)
        .frame(height: 250)
    }
}
