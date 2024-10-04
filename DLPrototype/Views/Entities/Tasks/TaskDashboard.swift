//
//  TaskDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskDashboard: View {
    @EnvironmentObject public var state: Navigation
    public var defaultSelectedJob: Job?
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .tasks

    @State private var selectedJob: Int = 0
    @State private var jobId: String = ""
    @State private var job: Job?

    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    Title(text: eType.label, imageAsImage: eType.icon)
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: {/*self.state.to(.taskDetail)*/}, // @TODO: uncomment once TaskDetail/Dashboard is rebuilt
                        icon: "plus",
                        showLabel: false
                    )
                }
                create

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
        .id(updater.get("task.dashboard"))
    }

    @ViewBuilder
    var create: some View {
        FancyDivider()

        if self.state.session.job == nil {
            FancyHelpText(
                text: "No terms found for the selected job. Choose a job from the sidebar to get started.",
                page: self.page
            )
        } else {
            JobPickerUsing(onChange: change, jobId: $jobId)
                .onAppear(perform: actionOnAppear)
                .onChange(of: selectedJob) {
                    actionOnAppear()
                }

            TaskListView(job: self.state.session.job!)
        }
    }
    
    private func actionOnAppear() -> Void {
        if let sJob = self.state.session.job {
            self.job = sJob
            self.jobId = sJob.jid.string
        }

        if defaultSelectedJob != nil {
            job = defaultSelectedJob
        } else if selectedJob > 0 {
            job = CoreDataJob(moc: self.state.moc).byId(Double(selectedJob))
        }
        
        if job != nil {
            jobId = job!.jid.string
        }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        selectedJob = selected

        actionOnAppear()
    }
}
