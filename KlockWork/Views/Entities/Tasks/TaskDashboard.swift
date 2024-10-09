//
//  TaskDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct TaskDashboard: View {
    typealias Widget = WidgetLibrary.UI.Buttons
    @EnvironmentObject public var state: Navigation
    public var defaultSelectedJob: Job?
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .tasks
    @State private var job: Job?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    buttons: AnyView(
                        Widget.ResetUserChoices()
                    ),
                    title: self.eType.label
                )

                if self.state.session.job == nil {
                    FancyHelpText(
                        text: "No tasks found. Choose a job from the sidebar to get started.",
                        page: self.page
                    )
                } else {
                    TaskListView(job: self.state.session.job!)
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
    }
}

extension TaskDashboard {
    /// Onload handler. Sets job
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let sJob = self.state.session.job {
            self.job = sJob
        }

        if defaultSelectedJob != nil {
            self.job = self.defaultSelectedJob
        }
    }

    /// Fires when you tap the Create button
    /// - Returns: Void
    private func actionOnTapCreate() -> Void {
        self.state.to(.taskDetail)
    }
}
