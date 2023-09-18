//
//  TaskGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskGroup: View {
    public let key: Project
    public var tasks: Dictionary<Project, [Job]>

    @State private var minimized: Bool = false
    @State private var jobs: [Job] = []

    @EnvironmentObject public var nav: Navigation

    @AppStorage("widget.tasks.minimizeAll") private var minimizeAll: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    if let job = nav.session.job {
                        if job == key {
                            FancyStar(background: Color.fromStored(key.colour ?? Theme.rowColourAsDouble))
                                .help("Records you create will be associated with this job (#\(job.jid.string))")
                        }
                    }

                    FancyButtonv2(
                        text: key.name!,
                        action: minimize,
                        icon: minimized ? "plus" : "minus",
                        fgColour: minimized ? (key.storedColour().isBright() ? .black : .white) : .white,
                        showIcon: false,
                        size: .link
                    )

                    Spacer()
                    FancyButtonv2(
                        text: key.name!,
                        action: minimize,
                        icon: minimized ? "plus" : "minus",
                        fgColour: minimized ? (key.storedColour().isBright() ? .black : .white) : .white,
                        showLabel: false,
                        size: .link
                    )
                }
                .padding(8)
                .background(minimized ? key.storedColour() : Theme.base.opacity(0.3))
//                .background(key.storedColour())
                .onAppear(perform: actionOnAppear)

                if !minimized {
                    if let items = key.jobs {
                        ForEach(items.allObjects as! [Job]) { item in
//                            if let jobTasks = item.tasks {
//                                var tasks: [LogTask] = jobTasks.allObjects as! [LogTask]

//                                if let plan = nav.session.plan {
//                                    print("DERPO nav.session.plan.tasks=\(nav.session.plan.tasks)")
////                                    if let planTasks = plan.tasks {
////                                        tasks = planTasks.allObjects as! [LogTask] //filter {$0.completedDate == nil && $0.cancelledDate == nil}
////                                    }
//                                }
//                                if tasks.filter({$0.completedDate == nil && $0.cancelledDate == nil}).count > 0 {
                                    HStack {
                                        Text("Tasks: \(tasks.count)")
                                        TaskWidgetProjectGroup(job: item)
                                    }
//                                }
//                            }
                        }
                    }
                }
            }
            .padding(.leading, 10)
            .border(width: 10, edges: [.leading], color: key.storedColour())
        }
        .background(key.storedColour())
    }
}

extension TaskGroup {
    private func minimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
        minimized = minimizeAll
    }
}
