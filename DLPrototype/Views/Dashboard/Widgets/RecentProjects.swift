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
            FancySubTitle(text: "\(title)")
            Divider()

            ScrollView {
                VStack(spacing: 1) {
                    ForEach(resource) { project in
                        ProjectRow(project: project)
                    }
                }
            }
        }
        .padding()
        .border(Theme.darkBtnColour)
    }
}
