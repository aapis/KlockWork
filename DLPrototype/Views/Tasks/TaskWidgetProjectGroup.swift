//
//  TaskWidgetProjectGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-09-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskWidgetProjectGroup: View {
    public var job: Job

    @State private var minimized: Bool = false

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                FancyButtonv2(
                    text: job.id_string(),
                    action: minimize,
                    icon: minimized ? "plus" : "minus",
                    fgColour: minimized ? (job.storedColour().isBright() ? .black : .white) : .white,
                    showLabel: false,
                    size: .link
                )
                Text("\(job.id_string())")

                Spacer()
                FancyButtonv2(
                    text: "See all tasks",
                    action: {},
                    icon: "checklist",
                    fgColour: job.storedColour().isBright() ? .black : .white,
                    showLabel: false,
                    size: .link,
                    redirect: AnyView(TaskDashboard(defaultSelectedJob: job)),
                    pageType: .tasks,
                    sidebar: AnyView(TaskDashboardSidebar())
                )

                FancyButtonv2(
                    text: "Go to project: \(job.project!.name!)",
                    action: {},
                    icon: "folder",
                    fgColour: job.storedColour().isBright() ? .black : .white,
                    showLabel: false,
                    size: .link,
                    redirect: AnyView(ProjectsDashboard()),
                    pageType: .projects,
                    sidebar: AnyView(ProjectsDashboardSidebar())
                )

                FancyButtonv2(
                    text: "Go to job: \(job.jid.string)",
                    action: {},
                    icon: "hammer",
                    fgColour: job.storedColour().isBright() ? .black : .white,
                    showLabel: false,
                    size: .link,
                    redirect: AnyView(JobDashboard(defaultSelectedJob: job)),
                    pageType: .jobs,
                    sidebar: AnyView(JobDashboardSidebar())
                )
            }

            if !minimized {
//                if let st = self.tasks[key] {
                ForEach(job.tasks!.allObjects as! [LogTask]) { task in
                    if task.completedDate == nil && task.cancelledDate == nil {
                        if nav.session.gif == .focus {
                            if let plan = nav.session.plan {
                                if plan.tasks!.contains(task) {
                                    TaskViewPlain(task: task)
                                }
                            }
                        } else {
                            TaskViewPlain(task: task)
                        }
                    }
                }
//                }
            }
        }
        .foregroundColor(job.storedColour().isBright() ? .black : .white)
        .padding(8)
        .background(job.storedColour())
        .border(Theme.base.opacity(0.5), width: 1)
    }
}

extension TaskWidgetProjectGroup {
    private func minimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
//        minimized = minimizeAll

    }
}
