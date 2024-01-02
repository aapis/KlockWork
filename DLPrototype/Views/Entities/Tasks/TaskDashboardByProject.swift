//
//  TaskDashboardByProject.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-17.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskDashboardByProject: View {
    public var project: Project

    @FetchRequest private var tasks: FetchedResults<LogTask>

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Title(text: "Tasks", image: "checklist")
                FancySubTitle(text: "Project: \(project.name!)")
                JobList(project: project)
                FancyDivider()

                VStack {
                    if tasks.count > 0 {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(tasks) { task in
                                    TaskView(task: task, showJobId: true, showCreated: true, showUpdated: true, showCompleted: true, colourizeRow: true)
                                }
                            }
                        }
                    } else {
                        Notice(copy: "This project doesn't have any tasks associated with it yet.")
                    }
                }
            }
            .padding()
            Spacer()
        }
        .background(Theme.toolbarColour)
        .font(Theme.font)
    }
}

extension TaskDashboardByProject {
    init(project: Project) {
        self.project = project

        let pRequest: NSFetchRequest<LogTask> = LogTask.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \LogTask.owner, ascending: true),
        ]
        pRequest.predicate = NSPredicate(format: "completedDate = nil && cancelledDate = nil && owner.project = %@", project)

        _tasks = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
}

extension TaskDashboardByProject {
    struct Notice: View {
        public var copy: String = ""

        var body: some View {
            VStack {
                HStack {
                    Text(copy).padding(15)
                    Spacer()
                }
            }
            .background(Theme.cOrange)
            FancyDivider()
        }
    }

    struct JobList: View {
        public var project: Project

        @FetchRequest private var jobs: FetchedResults<Job>

        var body: some View {
            HStack(spacing: 1) {
                Text("Owned Jobs")
                    .padding()
                    .background(Theme.rowColour)

                ForEach(jobs, id: \.self) { job in
                    FancyTextLink(text: String(job.id_int()), destination: AnyView(JobDashboard(defaultSelectedJob: job)), fgColour: job.fgColour(), pageType: .jobs, sidebar: AnyView(JobDashboardSidebar()))
                        .padding()
                        .background(job.colour_from_stored())
                }
            }
        }
    }
}

extension TaskDashboardByProject.JobList {
    init(project: Project) {
        self.project = project

        let pRequest: NSFetchRequest<Job> = Job.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Job.jid, ascending: true),
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && project = %@", self.project)

        _jobs = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
}
