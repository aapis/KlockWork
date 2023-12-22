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

    @Published public var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    @Published public var view: AnyView? = AnyView(Dashboard())
    @Published public var parent: Page? = .dashboard
    @Published public var sidebar: AnyView? = AnyView(DashboardSidebar())
    @Published public var title: String? = ""
    @Published public var pageId: UUID? = UUID()
    @Published public var session: Session = Session()
    @Published public var planning: Planning = Planning(moc: PersistenceController.shared.container.viewContext)

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
        var search: Search = Search(moc: PersistenceController.shared.container.viewContext)
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

extension Navigation.Session {
    public struct Search {
        var id: UUID = UUID()
        var text: String? = nil
        var components: Set<SearchLanguage.Component> = []
        var moc: NSManagedObjectContext
        var hasResults: Bool = false
    }
}

extension Navigation.Session.Search {
    mutating func results() -> [SearchLanguage.Results.Result] {
        hasResults = true
        
        return SearchLanguage.Results(components: components, moc: moc).find()
    }
    
    mutating func reset() -> Void {
        components = []
        text = nil
        hasResults = false
    }
}

extension Navigation {
    public struct Planning {
        var id: UUID = UUID()
        var jobs: Set<Job> = []
        var tasks: Set<LogTask> = []
        var notes: Set<Note> = []
        var projects: Set<Project> = []
        var companies: Set<Company> = []
        var moc: NSManagedObjectContext

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

        mutating func empty(_ date: Date) -> Void {
            if let plan = CoreDataPlan(moc: moc).forDate(date).first {
                plan.jobs = []
                plan.tasks = []
                plan.notes = []
                plan.projects = []
                plan.companies = []
            } else {
                jobs = []
                tasks = []
                notes = []
                projects = []
                companies = []
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
            projects = []
            companies = []

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

                var sProjects: Set<Project> = []
                for o in pl.projects!.allObjects as! [Project] {sProjects.insert(o)}
                projects = sProjects

                var sCompanies: Set<Company> = []
                for o in pl.companies!.allObjects as! [Company] {sCompanies.insert(o)}
                companies = sCompanies
            }
        }

        private func create(for date: Date) -> Plan {
            let plan = Plan(context: moc)
            plan.id = id
            plan.created = date
            plan.jobs = NSSet(set: jobs)
            plan.tasks = NSSet(set: tasks)
            plan.notes = NSSet(set: notes)
            plan.projects = NSSet(set: projects)
            plan.companies = NSSet(set: companies)

            PersistenceController.shared.save()
            return plan
        }

        private func update(_ plan: Plan) -> Plan {
            plan.jobs = NSSet(set: jobs)
            plan.tasks = NSSet(set: tasks)
            plan.notes = NSSet(set: notes)
            plan.projects = NSSet(set: projects)
            plan.companies = NSSet(set: companies)

            PersistenceController.shared.save()
            return plan
        }
    }
}

extension Navigation.Planning {
    enum GlobalInterfaceFilter {
        case normal, focus
    }
}
