//
//  Navigation.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public class Navigation: Identifiable, ObservableObject {
    public var id: UUID = UUID()

    @Published public var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    @Published public var view: AnyView? = AnyView(Dashboard())
    @Published public var parent: Navigation.Page? = .dashboard
    @Published public var sidebar: AnyView? = AnyView(DashboardSidebar())
    @Published public var title: String? = ""
    @Published public var pageId: UUID? = UUID()
    @Published public var session: Session = Session()
    @Published public var planning: Planning = Planning(moc: PersistenceController.shared.container.viewContext)
    @Published public var score: Score = Score(moc: PersistenceController.shared.container.viewContext)

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

    public func setParent(_ newParent: Navigation.Page) -> Void {
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
        var moc: NSManagedObjectContext
    }
}

extension Navigation.Planning {
    enum GlobalInterfaceFilter {
        case normal, focus
    }

    func taskCount() -> Int {
        var count = 0
        let _ = jobs.map({count += $0.tasks?.count ?? 0})
        return count
    }

    func finalize(_ date: Date) -> Plan {
        if let existingPlan = CoreDataPlan(moc: moc).forDate(date).first {
            return update(existingPlan)
        }

        return create(for: date)
    }

    func reset(_ date: Date) -> Void {
        if let plan = CoreDataPlan(moc: moc).forDate(date).first {
            moc.delete(plan)
        }

        PersistenceController.shared.save()
    }

    func export() -> Void {
        var dailyPlan = ""

        dailyPlan += "Tasks\n"
        for item in tasks {
            if let job = item.owner {
                dailyPlan += " - \(job.id_int()):"
            }

            dailyPlan += " \(item.content!)\n"
        }

        dailyPlan += "Jobs\n"
        for item in jobs {
            dailyPlan += " - \(item.id_int())"

            if let uri = item.uri {
                dailyPlan += " (\(uri.absoluteString))\n"
            } else {
                dailyPlan += "\n"
            }
        }

        ClipboardHelper.copy(dailyPlan)
    }

    mutating func empty(_ date: Date) -> Void {
        if let plan = CoreDataPlan(moc: moc).forDate(date).first {
            plan.jobs = []
            plan.tasks = []
            plan.notes = []
        } else {
            jobs = []
            tasks = []
            notes = []
        }

        PersistenceController.shared.save()
    }

    mutating func clean() -> Void {
        let plans = CoreDataPlan(moc: moc).all()

        if plans.count > 0 {
            for plan in plans {
                moc.delete(plan)
            }
        }

        jobs = []
        tasks = []
        notes = []

        PersistenceController.shared.save()
    }

    mutating func load(_ plan: Plan?) -> Void {
        if let pl = plan {
            id = pl.id!

            var sJobs: Set<Job> = []
            for o in pl.jobs!.allObjects as! [Job] {sJobs.insert(o)}
            jobs = sJobs

            var sTasks: Set<LogTask> = []
            for o in pl.tasks!.allObjects as! [LogTask] {sTasks.insert(o)}
            tasks = sTasks

            var sNotes: Set<Note> = []
            for o in pl.notes!.allObjects as! [Note] {sNotes.insert(o)}
            notes = sNotes
        }
    }

    private func create(for date: Date) -> Plan {
        let plan = Plan(context: moc)
        plan.id = id
        plan.created = date
        plan.jobs = NSSet(set: jobs)
        plan.tasks = NSSet(set: tasks)
        plan.notes = NSSet(set: notes)

        PersistenceController.shared.save()
        return plan
    }

    private func update(_ plan: Plan) -> Plan {
        plan.jobs = NSSet(set: jobs)
        plan.tasks = NSSet(set: tasks)
        plan.notes = NSSet(set: notes)

        PersistenceController.shared.save()
        return plan
    }
}

extension Navigation {
    public struct Score {
        var moc: NSManagedObjectContext
        var value: Int = 0
        var book: RuleBook = RuleBook()
        var rules: [RuleBook.Rule] = []

        mutating func calculate() -> Void {
            for rule in rules {
                value += rule.evaluate()
            }
        }
    }
}

extension Navigation.Score {
    struct RuleBook {
        var rules: [Rule] = [
            Rule(description: "+ 1: More than 1 job", action: .increment)
        ]
    }
}

extension Navigation.Score.RuleBook {
    struct Rule: Identifiable {
        var id: UUID = UUID()
        var description: String = ""
        var action: Action = .inert
        var amount: Int = 1
        var condition: Bool = false

        func evaluate() -> Int {
            if condition {
                //change = data.apply(action)

                return amount
            }

            return 0
        }
    }
}

extension Navigation.Score.RuleBook.Rule {
    public enum Action {
        case increment, decrement, inert
    }
}
