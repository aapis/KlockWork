//
//  Navigation.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum Page {
    case dashboard, today, notes, tasks, projects, jobs, companies, planning

    var ViewUpdaterKey: String {
        switch self {
        case .dashboard:
            return "dashboard"
        case .today:
            return "today.dashboard"
        case .tasks:
            return "task.dashboard"
        case .notes:
            return "note.dashboard"
        case .projects:
            return "project.dashboard"
        case .jobs:
            return "job.dashboard"
        case .companies:
            return "companies.dashboard"
        case .planning:
            return "planning.dashboard"
        }
    }

    var colour: Color {
        switch self {
        case .dashboard:
            return .blue
        case .today:
            return .blue
        case .tasks:
            return .blue
        case .notes:
            return .blue
        case .projects:
            return .blue
        case .jobs:
            return .blue
        case .companies:
            return .blue
        case .planning:
            return .blue
        }
    }

    var defaultTitle: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .today:
            return "Today"
        case .tasks:
            return "Tasks"
        case .notes:
            return "Notes"
        case .projects:
            return "Projects"
        case .jobs:
            return "Jobs"
        case .companies:
            return "Companies"
        case .planning:
            return "Planning"
        }
    }
}

public enum PageGroup: Hashable {
    case views, entities
}

public class Navigation: Identifiable, ObservableObject {
    public var id: UUID = UUID()

//    @Published public var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    @Published public var view: AnyView? = AnyView(Dashboard())
    @Published public var parent: Page? = .dashboard
    @Published public var sidebar: AnyView? = AnyView(DashboardSidebar())
    @Published public var title: String? = ""
    @Published public var pageId: UUID? = UUID()
    @Published public var session: Session = Session()
    @Published public var planning: Planning = Planning()

    public func pageTitle() -> String {
        if title!.isEmpty {
            return parent?.defaultTitle ?? ""
        }

        return title! + " - " + parent!.defaultTitle
    }

    public func setView(_ newView: AnyView) -> Void {
        view = nil
        view = newView
    }

    public func setParent(_ newParent: Page) -> Void {
        parent = nil
        parent = newParent
    }

    public func setSidebar(_ newView: AnyView) -> Void {
        sidebar = nil
        sidebar = newView
    }

    public func setTitle(_ newTitle: String) -> Void {
        title = nil
        title = newTitle
    }

    public func setId() -> Void {
        pageId = nil
        pageId = UUID()
    }

    public func reset() -> Void {
        parent = .dashboard
        view = nil
        sidebar = nil
        setId()
        session = Session()
    }
}

extension Navigation {
    public struct Session {
        var job: Job?
        var project: Project?
        var note: Note?
        var plan: Plan?
        var date: Date = Date()
        var idate: IdentifiableDay = IdentifiableDay()
        var gif: Planning.GlobalInterfaceFilter = .normal
    }
}

extension Navigation.Session {
    mutating func setJob(_ job: Job?) -> Void {
        if job != nil {
            self.job = job
        } else {
            self.job = nil
        }
    }
}

extension Navigation {
    public struct Planning {
        var id: UUID = UUID()
        var jobs: Set<Job> = []
        var tasks: Set<LogTask> = []
        var notes: Set<Note> = []
        var finalized: Date? = nil

        func taskCount() -> Int {
            var count = 0
            let _ = jobs.map({count += $0.tasks?.count ?? 0})
            return count
        }

        mutating func finalize() -> Plan {
            finalized = Date()

            let plan = Plan(context: PersistenceController.shared.container.viewContext)
            plan.id = id
            plan.created = finalized
            plan.jobs = NSSet(set: jobs)
            plan.tasks = NSSet(set: tasks)
            plan.notes = NSSet(set: notes)

            PersistenceController.shared.save()
            id = UUID()

            return plan
        }

        mutating func reset() -> Void {
            let moc = PersistenceController.shared.container.viewContext
            let plans = CoreDataPlan(moc: moc).forToday()

            finalized = nil
            jobs = []
            tasks = []
            notes = []

            if plans.count > 0 {
                for plan in plans {
                    moc.delete(plan)
                }
            }

            PersistenceController.shared.save()

            id = UUID()
        }
    }
}

extension Navigation.Planning {
    enum GlobalInterfaceFilter {
        case normal, focus
    }
}
