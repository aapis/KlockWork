//
//  ProjectRowPlain.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct ProjectRowPlain: View {
    public var project: Project
    public var icon: String = "arrow.right"

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Image(systemName: icon)
                    .padding(.trailing, 10)
                    .opacity(0.4)

                FancyButtonv2(
                    text: project.name!,
                    action: {},
                    showIcon: false,
                    size: .link,
                    redirect: AnyView(ProjectView(project: project)),
                    pageType: .projects,
                    sidebar: AnyView(ProjectsDashboardSidebar())
                )
            }
            .padding(5)
        }
    }
}
