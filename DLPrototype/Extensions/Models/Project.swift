//
//  Project.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-09-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Project {
    func storedColour() -> Color {
        if let colour = self.colour {
            return Color.fromStored(colour)
        }

        return Color.clear
    }

    func hasTasks(focus: Navigation.Planning.GlobalInterfaceFilter, using plan: Plan? = nil) -> Bool {
        // TODO: replace the loops here with a subquery (if CD does those?)
        let predicate = NSPredicate(
            format: "tasks.@count > 0"
        )
        var filteredJobs: Set<Job> = []

        if let jerbs = jobs {
            filteredJobs = jerbs.filtered(using: predicate) as! Set<Job>

            if let plan = plan {
                for job in plan.jobs!.allObjects as! [Job] {
                    if focus == .focus && filteredJobs.contains(job) {
                        filteredJobs.remove(job)
                    }
                }
            }

//            for job in filteredJobs {
//                if let tasks = job.tasks {
//                    var taskList: [LogTask] = []
//                    if focus == .focus {
//                        if let savedPlan = plan {
//                            taskList = savedPlan.tasks?.allObjects as! [LogTask]
//                        } else {
//                            taskList = tasks.allObjects as! [LogTask]
//                        }
//                    } else {
//                        taskList = tasks.allObjects as! [LogTask]
//                    }
//
//                    for task in taskList {
//                        if task.completedDate != nil && task.cancelledDate != nil {
//                            filteredJobs.remove(job)
//                        }
//                    }
//                }
//            }

//            for job in filteredJobs {
//                if filteredJobs.contains(job) {
//                    if job.project!.hasTasks(focus: focus, using: plan) {
//                        filteredJobs.remove(job)
//                    }
//                }
//            }
        }

        return filteredJobs.count > 0
    }
}
