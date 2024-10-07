//
//  TaskItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct TaskItem: View, Identifiable {
    @EnvironmentObject public var state: Navigation
    public var id: UUID = UUID()
    public let task: LogTask
    public var includeDueDate: Bool = false
    public var callback: (() -> Void)?
    @State private var isHighlighted: Bool = false
    private var rowBackground: TypedListRowBackground {
        TypedListRowBackground(colour: self.task.owner?.backgroundColor ?? Theme.rowColour, type: .tasks)
    }

    var body: some View {
        Button {
            self.state.session.task = self.task
            self.state.to(.taskDetail)
        } label: {
            Row
        }
        .id(self.id)
        .buttonStyle(.plain)
    }

    var Row: some View {
        ZStack(alignment: .topLeading) {
            (self.isHighlighted ? self.rowBackground.opacity(0.9) : self.rowBackground.opacity(1))

            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 0) {
                            Text(self.task.content ?? "")
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        .foregroundStyle((self.task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white)

                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                if let job = self.task.owner {
                                    if let project = job.project {
                                        if let company = project.company {
                                            Text(company.abbreviation ?? "XXX")
                                            Image(systemName: "chevron.right")
                                        }

                                        Text(project.abbreviation ?? "YYY")
                                        Image(systemName: "chevron.right")
                                    }

                                    Text(job.title ?? job.jid.string)
                                }
                            }

                            if let due = self.task.due {
                                HStack(alignment: .center) {
                                    Text("Due: \(due.formatted(date: self.includeDueDate ? .abbreviated : .omitted, time: .complete))")
                                }
                            }
                        }
                        .foregroundStyle((self.task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                        .font(Theme.fontCaption)
                    }
                    .padding(8)

                    Spacer()
                    if self.isHighlighted {
                        VStack(alignment: .trailing, spacing: 0) {
                            RowActionButton(callback: self.actionOnTaskCancel, icon: "calendar.badge.minus", helpText: "Cancel task", highlightedColour: .red)
                            RowActionButton(callback: self.actionOnTaskDelay, icon: "clock.fill", helpText: "Delay task 1 day", highlightedColour: .yellow)
                            RowActionButton(callback: self.actionOnTaskComplete, icon: "checkmark.circle.fill", helpText: "Task complete!", highlightedColour: .green)
                        }
                        .frame(width: 30)
                    }
                }
            }
        }
        .onChange(of: self.task) { self.callback?() }
        .useDefaultHover({ hover in self.isHighlighted = hover })
        .contextMenu {
            Menu("Go to"){
                Button {
                    self.state.session.job = self.task.owner
                    self.state.to(.tasks)
                } label: {
                    Text(PageConfiguration.EntityType.tasks.label)
                }

                Button {
                    self.state.session.job = self.task.owner
                    self.state.to(.notes)
                } label: {
                    Text(PageConfiguration.EntityType.notes.label)
                }

                if self.task.owner?.project != nil {
                    Button {
                        self.state.view = AnyView(ProjectView(project: self.task.owner!.project!))
                        self.state.parent = .projects
                        self.state.sidebar = AnyView(ProjectsDashboardSidebar())
                        // @TODO: uncomment once ProjectView is refactored so it doesn't require project on init
//                        self.state.session.project = entry.jobObject?.project
//                        self.state.to(.projects)
                    } label: {
                        Text(PageConfiguration.EntityType.projects.enSingular)
                    }
                }

                Button {
                    self.state.session.job = self.task.owner
                    self.state.to(.jobs)
                } label: {
                    Text(PageConfiguration.EntityType.jobs.enSingular)
                }
            }
            Button(action: self.actionInspect, label: {
                Text("Inspect")
            })
        }
    }
}

extension TaskItem {
    /// Inspect an entity
    /// - Returns: Void
    private func actionInspect() -> Void {
        self.state.session.search.inspectingEntity = self.task
        self.state.setInspector(AnyView(Inspector(entity: self.task)))
    }
    
    /// Cancel task and fire callback
    /// - Returns: Void
    private func actionOnTaskCancel() -> Void {
        CoreDataTasks(moc: self.state.moc).cancel(self.task)
        self.callback?()
    }

    /// Delay task and fire callback
    /// - Returns: Void
    private func actionOnTaskDelay() -> Void {
        CoreDataTasks(moc: self.state.moc).delay(self.task)
        self.callback?()
    }

    /// Delay task and fire callback
    /// - Returns: Void
    private func actionOnTaskComplete() -> Void {
        CoreDataTasks(moc: self.state.moc).complete(self.task)
        self.callback?()
    }
}
