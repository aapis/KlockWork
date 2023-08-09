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
    }

    private var Buttons: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Theme.base.opacity(0.5)
                FancyButtonv2(
                    text: "New record",
                    icon: "doc.badge.plus",
                    showLabel: false,
                    size: .small,
                    type: nav.parent == .today ? .secondary : .standard,
                    redirect: AnyView(Today()),
                    pageType: .today,
                    sidebar: AnyView(TodaySidebar())
                )
                .mask(Circle())
            }
            .mask(Circle())
            .frame(width: 46, height: 46)

           ZStack {
               Theme.base.opacity(0.5)
               FancyButtonv2(
                   text: "New note",
                   icon: "note.text.badge.plus",
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
            .frame(width: 46, height: 46)

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
             .frame(width: 46, height: 46)

            ZStack {
                Theme.base.opacity(0.5)
                FancyButtonv2(
                    text: "New Project",
                    icon: "folder.badge.plus",
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
             .frame(width: 46, height: 46)

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
             .frame(width: 46, height: 46)
        }
        .padding(5)
    }
}

extension CreateEntitiesWidget {

}

