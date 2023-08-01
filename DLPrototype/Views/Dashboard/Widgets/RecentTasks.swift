//
//  RecentTasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentTasks: View {
    public let title: String = "Incomplete Tasks"

    @FetchRequest public var resource: FetchedResults<LogTask>

    public init() {
        _resource = CoreDataTasks.recentTasksWidgetData()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "New Task",
                    action: {},
                    icon: "plus",
                    showLabel: false,
                    size: .small,
                    redirect: AnyView(
                        TaskDashboard()
                    ),
                    pageType: .tasks
                )
            }
            Divider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 1) {
                    ForEach(resource) { task in
                        TaskView(task: task, showActions: false)
                    }
                }
            }
        }
        .padding()
        .border(Theme.darkBtnColour)
        .frame(height: 250)
    }
}
