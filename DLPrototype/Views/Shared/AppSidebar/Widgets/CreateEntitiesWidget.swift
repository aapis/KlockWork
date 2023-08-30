//
//  CreateEntitiesWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CreateEntitiesWidget: View {
    @Binding public var isDatePickerPresented: Bool

    @State private var followingPlan: Bool = false
    @State private var gif: Navigation.Planning.GlobalInterfaceFilter = .normal
    @State private var doesPlanExist: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if isDatePickerPresented {
                ZStack {
                    Buttons
                    Color.black.opacity(0.7)
                }
                .frame(height: 55)

            } else {
                FancyDivider()
                Buttons
            }
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.tasks, perform: actionOnChangeOfTasks)
        .onChange(of: nav.planning.jobs, perform: actionOnChangeOfJobs)
        .onChange(of: nav.planning.notes, perform: actionOnChangeOfNotes)
    }

    private var Buttons: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                ZStack {
                    Theme.base.opacity(0.5)
                    if doesPlanExist {
                        FancyButtonv2(
                            text: gif == .focus ? "Disable planning focus" : "Enable global filter to only show you the things you need to see",
                            action: actionOnChangeFocus,
                            icon: gif == .focus ? "moon.fill" : "moon",
                            showLabel: false,
                            size: .small,
                            type: .tsWhite // TODO: don't use star!
                        )
                        .mask(Circle())
                    } else {
                        FancyButtonv2(
                            text: "You need to create a plan first, click here!",
                            icon: "moon.zzz",
                            showLabel: false,
                            size: .small,
                            type: nav.parent == .planning ? .secondary : .standard,
                            redirect: AnyView(Planning()),
                            pageType: .planning,
                            sidebar: AnyView(DefaultPlanningSidebar())
                        )
                        .mask(Circle())
                    }
                }
                .mask(Circle())
            }
            .frame(width: 46, height: 46)

            ZStack {
                ZStack {
                    Theme.base.opacity(0.5)
                    FancyButtonv2(
                        text: "New note",
                        icon: "note.text",
                        showLabel: false,
                        size: .small,
                        type: nav.parent == .notes ? .secondary : .standard,
                        redirect: AnyView(NoteCreate()),
                        pageType: .today,
                        sidebar: AnyView(NoteDashboardSidebar())
                    )
                    .mask(Circle())
                }
                .mask(Circle())
                Image(systemName: "plus.circle.fill")
                    .position(x: 38, y: 38)
            }
            .frame(width: 46, height: 46)

            ZStack {
                ZStack {
                    Theme.base.opacity(0.5)
                    FancyButtonv2(
                        text: "New Task",
                        icon: "checklist.unchecked",
                        showLabel: false,
                        size: .small,
                        type: nav.parent == .tasks ? .secondary : .standard,
                        redirect: AnyView(TaskDashboard()),
                        pageType: .tasks,
                        sidebar: AnyView(TaskDashboardSidebar())
                    )
                    .mask(Circle())
                }
                .mask(Circle())
                Image(systemName: "plus.circle.fill")
                    .position(x: 38, y: 38)
            }
            .frame(width: 46, height: 46)

            ZStack {
                ZStack {
                    Theme.base.opacity(0.5)
                    FancyButtonv2(
                        text: "New Project",
                        icon: "folder",
                        showLabel: false,
                        size: .small,
                        type: nav.parent == .projects ? .secondary : .standard,
                        redirect: AnyView(ProjectCreate()),
                        pageType: .projects,
                        sidebar: AnyView(ProjectsDashboardSidebar())
                    )
                    .mask(Circle())
                 }
                 .mask(Circle())
                Image(systemName: "plus.circle.fill")
                    .position(x: 38, y: 38)
            }
            .frame(width: 46, height: 46)

            ZStack {
                ZStack {
                    Theme.base.opacity(0.5)
                    FancyButtonv2(
                        text: "New Job",
                        icon: "hammer",
                        showLabel: false,
                        size: .small,
                        type: nav.parent == .jobs ? .secondary : .standard,
                        redirect: AnyView(JobCreate()),
                        pageType: .jobs,
                        sidebar: AnyView(JobDashboardSidebar())
                    )
                    .mask(Circle())
                }
                .mask(Circle())
                Image(systemName: "plus.circle.fill")
                    .position(x: 38, y: 38)
            }
            .frame(width: 46, height: 46)
        }
        .padding(5)
    }
}

extension CreateEntitiesWidget {
    private func actionOnChangeFocus() -> Void {
        if gif == .normal {
            nav.session.gif = .focus
        } else {
            nav.session.gif = .normal
        }
    }

    private func actionOnAppear() -> Void {
        gif = nav.session.gif

        findPlan()
    }

    private func actionOnChangeOfTasks(_ items: Set<LogTask>) -> Void {
        if (items.count + nav.planning.jobs.count + nav.planning.notes.count) == 0 {
            nav.planning = Navigation.Planning(moc: nav.planning.moc)
        }

        findPlan()
    }

    private func actionOnChangeOfJobs(_ items: Set<Job>) -> Void {
        if (items.count + nav.planning.tasks.count + nav.planning.notes.count) == 0 {
            nav.planning = Navigation.Planning(moc: nav.planning.moc)
        }

        findPlan()
    }

    private func actionOnChangeOfNotes(_ items: Set<Note>) -> Void {
        if (items.count + nav.planning.jobs.count + nav.planning.tasks.count) == 0 {
            nav.planning = Navigation.Planning(moc: nav.planning.moc)
        }

        findPlan()
    }

    private func findPlan() -> Void {
        let plans = CoreDataPlan(moc: moc).forToday()
        if plans.count > 0 {
            if let plan = plans.first {
                doesPlanExist = !plan.isEmpty()
            }
        }
    }
}
