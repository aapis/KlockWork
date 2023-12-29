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
    @Published public var inspector: AnyView? = nil
    @Published public var title: String? = ""
    @Published public var pageId: UUID? = UUID()
    @Published public var session: Session = Session()
    @Published public var planning: PlanningState = PlanningState(moc: PersistenceController.shared.container.viewContext)
    @Published public var saved: Bool = false
    @Published public var state: State = State()
    @Published public var history: History = History()

    public func pageTitle() -> String {
        if title!.isEmpty {
            return parent?.defaultTitle ?? ""
        }

        return title! + " - " + parent!.defaultTitle
    }

    public func setView(_ newView: AnyView) -> Void {
//        view = AnyView(WidgetLoading())
//        state.on(.complete, { _ in
            view = newView
//        })
//        if state.phase == .complete {
//            
//        } else {
//            
//        }
    }

    public func setParent(_ newParent: Page) -> Void {
        parent = nil
        parent = newParent
    }

    public func setSidebar(_ newView: AnyView?) -> Void {
        if let view = newView {
            sidebar = view
        }
    }

    public func setTitle(_ newTitle: String) -> Void {
        title = nil
        title = newTitle
    }

    public func setId() -> Void {
        pageId = nil
        pageId = UUID()
    }
    
    public func setInspector(_ newInspector: AnyView? = nil) -> Void {
        inspector = nil
        inspector = newInspector
    }

    public func save() -> Void {
        self.saved = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.saved = false
        }
    }
    
    // @TODO: this doesn't really work yet
    public func to(_ page: Page) -> Void {
        let hp = self.history.get(page: page)

        self.setId()
        self.setView(hp.view)
        self.setParent(page)
        self.setSidebar(hp.sidebar)
        self.setTitle(hp.title)

        self.history.push(hp: hp)
    }

    public func reset() -> Void {
        parent = .dashboard
        view = nil
        sidebar = nil
        setId()
        inspector = nil
        session = Session()
        state = State()
        history = History()
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
        var gif: PlanningState.GlobalInterfaceFilter = .normal
        var search: Search = Search(moc: PersistenceController.shared.container.viewContext)
        var toolbar: Toolbar = Toolbar()
    }
    
    public struct State {
        private var phase: Phase = .ready
        private var hierarchy: [Phase] = [.ready, .transitioning, .complete]

        mutating func advance() -> Phase {
            if let index = hierarchy.firstIndex(of: self.phase) {
//                let x = hierarchy.indices
                print("DERPO advance.phase.index=\(index)")
                if hierarchy.indices.count <= index {
                    var hIndex = hierarchy.indices[index]
                    hIndex += 1
                    self.phase = hierarchy[hIndex]
//                    let next = Int(hIndex += 1)
                } else {
                    self.phase = .ready
                }
            }
            
            return .error
        }
        
        mutating func on(_ phase: Phase, _ callback: (_ phase: Phase) -> Void) -> Void {
            if phase == self.phase {
                let nextPhase = advance()
                callback(nextPhase)
                let _ = advance()
            }
        }
        
        mutating func set(_ phase: Phase) -> Void {
            self.phase = phase
        }
        
        mutating func get() -> Phase {
            return self.phase
        }

        enum Phase {
            case ready, transitioning, complete, error
        }
    }
    
    public struct History {
        // How far back you can go by clicking "back". Max: 10
        var recent: [HistoryPage] = []
        
        private let defaultHistoryPage: HistoryPage = HistoryPage(
            page: .dashboard,
            view: AnyView(Dashboard()),
            sidebar: AnyView(DashboardSidebar()),
            title: "Dashboard"
        )
        
        public let all: [HistoryPage] = [
            HistoryPage(page: .dashboard, view: AnyView(Dashboard()), sidebar: AnyView(DashboardSidebar()), title: "Dashboard"),
            HistoryPage(page: .planning, view: AnyView(Planning()), sidebar: AnyView(DefaultPlanningSidebar()), title: "Planning"),
            HistoryPage(page: .today, view: AnyView(Today()), sidebar: AnyView(TodaySidebar()), title: "Today"),
            HistoryPage(page: .companies, view: AnyView(CompanyDashboard()), sidebar: AnyView(DefaultCompanySidebar()), title: "Companies & Projects"),
            HistoryPage(page: .jobs, view: AnyView(JobDashboard()), sidebar: AnyView(JobDashboardSidebar()), title: "Jobs"),
            HistoryPage(page: .notes, view: AnyView(NoteDashboard()), sidebar: AnyView(NoteDashboardSidebar()), title: "Notes"),
            HistoryPage(page: .tasks, view: AnyView(TaskDashboard()), sidebar: AnyView(TaskDashboardSidebar()), title: "Tasks"),
        ]
        
        /// A single page representing a page the user navigated to
        public struct HistoryPage {
            var id: UUID = UUID()
            var page: Page
            var view: AnyView
            var sidebar: AnyView
            var title: String
        }
    }
}

extension Navigation.History {
    func get(page: Page) -> HistoryPage {
        return all.first(where: {$0.page == page}) ?? defaultHistoryPage
    }
    
    mutating func push(hp: HistoryPage) -> Void {
        recent.append(hp)
        
        if recent.count > 10 {
            let _ = recent.popLast()
        }
    }

    func previous() -> HistoryPage? {
        print("DERPO recent=\(recent.count)")
        var index = recent.endIndex
        index -= 1
        
        if index <= 10 {
            print("DERPO previousIndex=\(index)")
            
            if recent.indices.contains(index) {
                return recent[index]
            }
        } else {
            index = recent.startIndex
        }

        return nil
    }
    
    func next() -> HistoryPage? {
        var index = recent.endIndex
        index -= 1

        if index <= 10 {
            print("DERPO nextIndex=\(index)")
            
            if recent.indices.contains(index) {
                return recent[index]
            }
        } else {
            index = recent.endIndex
        }
        
        return nil
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
        var inspectingEntity: NSManagedObject? = nil
        
        mutating func inspect(_ obj: NSManagedObject) -> Void {
            inspectingEntity = obj
        }
        
        mutating func cancel() -> Void {
            inspectingEntity = nil
        }
    }
    
    public struct Toolbar: Identifiable {
        public var id: UUID = UUID()
        var selected: TodayViewTab = .chronologic
        var mode: ViewMode = .full
        var showSearch: Bool = false
        var searchText: String = "" // @TODO: remove
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
        inspectingEntity = nil
    }
}

extension Navigation {
    public struct PlanningState {
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

extension Navigation.PlanningState {
    enum GlobalInterfaceFilter {
        case normal, focus
    }
}
