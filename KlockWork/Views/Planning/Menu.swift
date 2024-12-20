//
//  Menu.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning {
    struct Menu: View {
        @EnvironmentObject public var nav: Navigation
        @State private var numTasks: Int = 0
        @State private var numJobs: Int = 0
        @State private var numNotes: Int = 0
        @State private var numProjects: Int = 0
        @State private var numCompanies: Int = 0
        public var page: PageConfiguration.AppPage = .planning

        var body: some View {
            VStack {
                HStack(spacing: 8) {
                    CountPills
                    Spacer()
                    if numJobs > 0 {
                        HStack(spacing: 5) {
                            FancyButtonv2(
                                text: "Share",
                                action: actionOnShare,
                                icon: "square.and.arrow.up",
                                showLabel: false,
                                size: .small,
                                type: .clear
                            )
                            .frame(width: 30)

                            FancyButtonv2(
                                text: "Start over",
                                action: actionResetPlan,
                                icon: "arrow.clockwise.circle.fill",
                                showLabel: false,
                                size: .small,
                                type: .clear
                            )
                            .frame(width: 30)
                        }
                        .frame(height: 30)
                    }
                }
                .padding(5)
            }
            .background(self.page.primaryColour)
            .clipShape(.rect(bottomLeadingRadius: self.nav.session.plan != nil ? 5 : 0, bottomTrailingRadius: self.nav.session.plan != nil ? 5 : 0))
            .onAppear(perform: actionOnAppear)
            .onChange(of: self.nav.planning.tasks) { self.actionOnChangeTasks() }
            .onChange(of: self.nav.planning.jobs) { self.actionOnChangeJobs() }
            .onChange(of: self.nav.planning.notes) { self.actionOnChangeNotes() }
            .onChange(of: self.nav.planning.companies) { self.actionOnChangeCompanies() }
            .onChange(of: self.nav.planning.projects) { self.actionOnChangeProjects() }
            .onChange(of: self.nav.session.date) { self.actionOnChangeDate() }
        }

        var CountPills: some View {
            HStack(spacing: 0) {
                TaskPill
                JobPill
                NotePill
                ProjectsPill
                CompanyPill
            }
            .frame(height: 30)
            .mask {
                Capsule()
            }
        }

        var TaskPill: some View {
            HStack {
                Text("\(numTasks)")
                    .foregroundColor(numTasks > Planning.tooManyTasks ? .black : .white)
                Image(systemName: "checklist")
                    .help(numTasks > Planning.tooManyTasks ? "This is probably too much work, consider removing some" : "\(numTasks) tasks selected")
                    .foregroundColor(numTasks > Planning.tooManyTasks ? .black : .white)
            }
            .padding(8)
            .background(numTasks > Planning.tooManyTasks ? .yellow : Theme.base.opacity(0.2))
        }

        var JobPill: some View {
            HStack {
                Text("\(numJobs)")
                    .foregroundColor(numJobs > Planning.tooManyJobs ? .black : .white)
                Image(systemName: "hammer")
                    .help(numJobs > Planning.tooManyJobs ? "This is probably too much work, consider removing some" : "\(numJobs) jobs selected")
                    .foregroundColor(numJobs > Planning.tooManyJobs ? .black : .white)
            }
            .padding(8)
            .background(numJobs > Planning.tooManyJobs ? .yellow : Theme.base.opacity(0.2))
        }

        var NotePill: some View {
            HStack {
                Text("\(numNotes)")
                Image(systemName: "note.text")
                    .help("\(numNotes) notes selected")
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }

        var ProjectsPill: some View {
            HStack {
                Text("\(numProjects)")
                    .foregroundColor(numProjects > Planning.tooManyProjects ? .black : .white)
                Image(systemName: "folder")
                    .help(numProjects > Planning.tooManyProjects ? "This is probably too much work, consider removing some jobs" : "\(numProjects) projects selected")
                    .foregroundColor(numProjects > Planning.tooManyProjects ? .black : .white)
            }
            .padding(8)
            .background(numProjects > Planning.tooManyProjects ? .yellow : Theme.base.opacity(0.2))
        }

        var CompanyPill: some View {
            HStack {
                Text("\(numCompanies)")
                Image(systemName: "building.2")
                    .help("\(numCompanies) companies selected")
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}

extension Planning.Menu {
    private func actionFinalizePlan() -> Void {
        let plan = nav.planning.finalize(nav.session.date)
        nav.session.plan = plan
    }

    private func actionResetPlan() -> Void {
        nav.planning = Navigation.PlanningState(moc: self.nav.moc)
        nav.session.plan = nil
        nav.session.gif = .normal
    }

    private func actionOnChangeJobs() -> Void {
        // Recalculate project and company counts when jobs change
        self.nav.planning.projects = []
        self.nav.planning.companies = []
        for job in self.nav.planning.jobs {
            if let project = job.project {
                self.nav.planning.projects.insert(project)

                if let company = project.company {
                    self.nav.planning.companies.insert(company)
                }
            }
        }

        actionOnAppear()
        actionFinalizePlan()
    }

    private func actionOnChangeTasks() -> Void {
        actionFinalizePlan()
        actionOnAppear()
    }

    private func actionOnChangeNotes() -> Void {
        actionFinalizePlan()
        actionOnAppear()
    }

    private func actionOnChangeCompanies() -> Void {
        actionFinalizePlan()
        actionOnAppear()
    }

    private func actionOnChangeProjects() -> Void {
        actionFinalizePlan()
        actionOnAppear()
    }

    private func actionOnAppear() -> Void {
        numTasks = nav.planning.tasks.count
        numJobs = nav.planning.jobs.count
        numNotes = nav.planning.notes.count
        numProjects = nav.planning.projects.count
        numCompanies = nav.planning.companies.count

        if numJobs == 0 {
            actionResetPlan()
        }
    }

    private func actionOnShare() -> Void {
        var dailyPlan = ""

        if let plan = nav.session.plan {
            if let items = plan.tasks {
                dailyPlan += "Tasks\n"
                for item in items.allObjects as! [LogTask] {
                    if let job = item.owner {
                        dailyPlan += " - \(job.id_int()):"
                    }

                    dailyPlan += " \(item.content!)\n"
                }
            }

            if let items = plan.jobs {
                dailyPlan += "Jobs\n"
                for item in items.allObjects as! [Job] {
                    dailyPlan += " - \(item.id_int())"

                    if let uri = item.uri {
                        dailyPlan += " (\(uri.absoluteString))\n"
                    } else {
                        dailyPlan += "\n"
                    }
                }
            }
        }

        ClipboardHelper.copy(dailyPlan)
    }
    
    /// Fires when you change date
    /// - Returns: Void
    private func actionOnChangeDate() -> Void {
        if let plan = CoreDataPlan(moc: nav.planning.moc).forDate(self.nav.session.date).first {
            nav.session.plan = plan
            nav.planning.load(nav.session.plan)
        } else {
            nav.planning.empty(nav.session.date)
        }
    }
}
extension Menu {
    // @TODO: use this instead!
    struct MenuItem: View {
        var count: Int
        var icon: String
        var description: String

        var body: some View {
            HStack {
                Text("\(count)")
                Image(systemName: icon)
                    .help("\(count) \(description)")
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}
