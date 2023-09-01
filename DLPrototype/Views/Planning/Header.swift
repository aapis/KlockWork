//
//  Header.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Header: View {
        var job: Job
        var index: Int?
        var type: PlanningObjectType

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false
        @State private var numChildren: Int = 0

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    if type == .tasks {
                        Image(systemName: "\(numChildren).circle")
                            .font(.title)
                            .foregroundColor(colour.isBright() ? .black : .white)
                        Text("Incomplete tasks associated with job \(job.jid.string)")
                            .foregroundColor(colour.isBright() ? .black : .white)
                    } else if type == .notes {
                        Image(systemName: "\(numChildren).circle")
                            .font(.title)
                            .foregroundColor(colour.isBright() ? .black : .white)
                        Text("Notes associated with job \(job.jid.string)")
                            .foregroundColor(colour.isBright() ? .black : .white)
                    }

                    Spacer()
                    if numChildren > 0 {
                        if type == .tasks {
                            FancyButtonv2(
                                text: "Add a task to this job",
                                icon: "plus",
                                fgColour: colour.isBright() ? .black : .white,
                                showLabel: false,
                                size: .link,
                                type: .clear,
                                redirect: AnyView(TaskDashboard(defaultSelectedJob: job)),
                                pageType: .tasks,
                                sidebar: AnyView(TaskDashboardSidebar())
                            )
                        } else if type == .notes {
                            FancyButtonv2(
                                text: "Add a note to this job",
                                icon: "plus",
                                fgColour: colour.isBright() ? .black : .white,
                                showLabel: false,
                                size: .link,
                                type: .clear,
                                redirect: AnyView(NoteDashboard()),
                                pageType: .notes,
                                sidebar: AnyView(NoteDashboardSidebar())
                            )
                        }
                    }
                }
                .padding(10)
            }
            .onAppear(perform: actionOnAppear)
            .background(colour)
        }
    }
}

extension Planning.Header {
    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)

        if type == .tasks {
            if let tasks = job.tasks {
                numChildren = tasks.filtered(using: NSPredicate(format: "completedDate == nil && cancelledDate == nil")).count
            }
        } else if type == .notes {
            if let notes = job.mNotes {
                numChildren = notes.filtered(using: NSPredicate(format: "alive == true")).count
            }
        }
    }
}
