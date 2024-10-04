//
//  Navigation.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum Page {
    case dashboard, today, notes, tasks, projects, jobs, companies, planning, terms, definitionDetail, taskDetail, noteDetail, people, peopleDetail

    var colour: Color {
        switch self {
        case .dashboard:
            return PageConfiguration.AppPage.find.primaryColour
        case .today:
            return PageConfiguration.AppPage.today.primaryColour
        case .planning:
            return PageConfiguration.AppPage.planning.primaryColour
        default:
            return PageConfiguration.AppPage.explore.primaryColour
        }
    }

    var defaultTitle: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .today: return "Today"
        case .tasks: return "Tasks"
        case .notes: return "Notes"
        case .projects: return "Projects"
        case .jobs: return "Jobs"
        case .companies: return "Companies"
        case .planning: return "Planning"
        case .terms: return "Terms"
        case .definitionDetail: return "Definition"
        case .taskDetail: return "Task"
        case .noteDetail: return "Note"
        case .people: return "People"
        case .peopleDetail: return "Person"
        }
    }

    var parentView: Page? {
        switch self {
        case .dashboard: return nil
        case .today: return nil
        case .tasks: return nil
        case .notes: return nil
        case .projects: return nil
        case .jobs: return nil
        case .companies: return nil
        case .planning: return nil
        case .terms: return nil
        case .definitionDetail: return .terms
        case .taskDetail: return .tasks
        case .noteDetail: return .notes
        case .people: return nil
        case .peopleDetail: return .people
        }
    }
}

public enum PageGroup: Hashable {
    case views, entities
}

public class Navigation: Identifiable, ObservableObject {
    public let id: UUID = UUID()

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
//    @Published public var state: State = State()
    @Published public var history: History = History()
    @Published public var forms: Forms = Forms()
    @Published public var events: SysEvents = SysEvents()

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
            forms.tp.clear()
            setInspector()
//        })
//        if state.phase == .complete {
//            
//        } else {
//            
//        }
    }

    public func setParent(_ newParent: Page) -> Void {
        parent = newParent
    }

    // @TODO: Should attempt to set content with "@ViewBuilder content: () -> Content" instead of wrapping in AnyView
    public func setSidebar(_ newView: AnyView?) -> Void {
        if let view = newView {
            sidebar = view
        }
    }

    public func setTitle(_ newTitle: String) -> Void {
        title = newTitle
    }

    public func setId() -> Void {
        pageId = UUID()
    }
    
    public func setInspector(_ newInspector: AnyView? = nil) -> Void {
        inspector = newInspector
    }

    public func save(callback: (() -> Void)? = nil) -> Void {
        self.saved = true

        if let cb = callback {
            cb()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.saved = false
        }
    }

    public func save(updatedValue: String, callback: ((String) -> Void)? = nil) -> Void {
        self.saved = true

        if let cb = callback {
            cb(updatedValue)
        }

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

        self.history.push(hp: hp)
        self.session.search.cancel()

        if self.history.recent.count > 20 {
            self.history.recent = []
        }
    }

    public func link(to page: Page) -> AnyView {
        let hp = self.history.get(page: page)

        return hp.view
    }

    public func reset() -> Void {
        parent = .dashboard
        view = nil
        sidebar = nil
        setId()
        inspector = nil
        session = Session()
//        state = State()
        history = History()
        forms = Forms()
    }
}

extension Navigation {
    public struct Session {
        var job: Job?
        var project: Project?
        var note: Note?
        var plan: Plan?
        var task: LogTask?
        var company: Company?
        var record: LogRecord?
        var term: TaxonomyTerm?
        var person: Person?
        var definition: TaxonomyTermDefinitions?
        var date: Date = Date()
        var idate: IdentifiableDay = IdentifiableDay()
        var gif: PlanningState.GlobalInterfaceFilter = .normal
        var search: Search = Search(moc: PersistenceController.shared.container.viewContext)
        var toolbar: Toolbar = Toolbar()
        var eventStatus: EventIndicatorStatus = .ready
        var cli: CommandLineSession = CommandLineSession()
    }
    
    public struct CommandLineSession {
        typealias CLIApp = CommandLineInterface.App
        typealias CLIAppType = CommandLineInterface.App.AppType

        var history: [History] = []
        var command: String?
        var app: CLIAppType = .log
        var selected: CLIApp?

        public class History: Identifiable, NSCopying {
            public var id: UUID = UUID()
            var time: Date = Date()
            var command: String
            var status: Status = .standard
            var message: String
            var appType: CLIAppType
            var job: Job? = nil

            init(time: Date = Date(), command: String, status: Status = .standard, message: String, appType: CLIAppType, job: Job?) {
                self.time = time
                self.command = command
                self.status = status
                self.message = message
                self.appType = appType
                self.job = job
            }

            /// Converts a single history line item to it's string representation
            /// - Returns: String
            public func toString() -> String {
                return "\(time.formatted(date: .abbreviated, time: .complete)) \(appType.name) \"\(command)\""
            }

            public func copy(with zone: NSZone? = nil) -> Any {
                return History(time: time, command: command, status: status, message: message, appType: appType, job: job)
            }

            public enum Status {
                case success, error, warning, standard
                
                var icon: Image {
                    switch self {
                    case .success, .standard:
                        Image(systemName: "checkmark.circle.fill")
                    case .error:
                        Image(systemName: "xmark.circle.fill")
                    case .warning:
                        Image(systemName: "triangle.circle.fill")
                    }
                }
                
                var colour: Color {
                    switch self {
                    case .standard: .white
                    case .success: .green
                    case .error: .red
                    case .warning: .yellow
                    }
                }
            }
        }
    }

    // @TODO: remove from Navigation
    public struct Forms {
        var note: NoteForm = NoteForm()
        var tp: ThreePanelForm = ThreePanelForm()

        struct NoteForm {
            var template: NoteTemplates.Template? = nil
            var job: Job? = nil
            var version: NoteVersion? = nil
            var star: Bool = false
        }

        struct TermForm {
            var job: Job? = nil
        }

        struct ThreePanelForm {
            var currentPosition: Panel.Position = .first
            var first: FetchedResults<Company>? = nil
            var middle: [Project] = []
            var last: [NSManagedObject] = []
            var selected: [Panel.SelectedValueCoordinates] = []
            var editor: Editor = Editor()

            struct Editor {
                var job: Job? = nil
                var jid: String? = ""
                var title: String? = ""
            }

            mutating public func clear() -> Void {
                self.currentPosition = .first
                self.middle = []
                self.last = []
                self.selected = []
            }
        }

        public class Field: Identifiable, Equatable {
            public let id: UUID = UUID()
            public var type: LayoutType = .text
            public var body: some View { FieldView(field: self) }
            public var label: String = ""
            public var value: Any? = nil
            public var entity: NSManagedObject? = nil
            public var keyPath: String
            public var status: FieldStatus = .standard

            init(type: LayoutType, label: String, value: Any? = nil, entity: NSManagedObject? = nil, keyPath: String) {
                self.type = type
                self.label = label
                self.value = value
                self.entity = entity
                self.keyPath = keyPath
            }

            static public func == (lhs: Navigation.Forms.Field, rhs: Navigation.Forms.Field) -> Bool {
                return lhs.id == rhs.id
            }

            public func update(value: Any) -> Void {
                if let entity = self.entity {
                    let en = entity as! Job

                    switch self.keyPath {
                    case "uri": self.value = URL(string: value as? String ?? "")
                    case "title": self.value = value as? String ?? ""
                    case "shredable": self.value = value as? Bool ?? false
                    case "overview": self.value = value as? String ?? ""
                    case "lastUpdate": self.value = Date()
                    case "jid": self.value = Double(value as! String) ?? 1.0
                    case "created": self.value = DateHelper.date(value as! String)
                    case "colour": self.value = value as? Array<Double>
                    case "alive": self.value = value as? Bool ?? false
                    case "id": self.value = en.id
                    case "project": self.value = en.project // @TODO: should use self.value
                    default:
                        print("[debug][Navigation.Forms.Field] Unknown field \(self.keyPath)")
                    }

                    en.setValue(self.value, forKey: self.keyPath)

                    PersistenceController.shared.save()
                }
            }

            public enum LayoutType {
                case text, dropdown, projectDropdown, date, boolean, colour, editor
            }

            public enum FieldStatus {
                case unsaved, saved, standard
            }

            struct FieldView: View {
                public var field: Field

                @State private var oldValue: String = ""
                @State private var newValue: String = ""
                @State private var status: FieldStatus = .standard

                @EnvironmentObject private var nav: Navigation

                var body: some View {
                    GridRow(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(field.label)
                                .padding(5)

                            switch field.type {
                            case .boolean: FancyToggle(label: self.field.label, value: self.field.value as! Bool, showLabel: true, onChange: self.onChangeToggle)
                            case .colour: FancyColourPicker(initialColour: self.field.value as! [Double], onChange: self.onChangeColour, showLabel: false)
                            case .editor: FancyTextField(placeholder: self.field.label, lineLimit: 10, fieldStatus: self.field.status, text: $newValue)
                            case .projectDropdown: ProjectPickerUsing(onChangeLarge: onChangeProjectDropdown, size: .large, defaultSelection: Int((self.field.value as! Project).pid), displayName: $newValue)
                            default:
                                FancyTextField(placeholder: self.field.label, fieldStatus: self.field.status, text: $newValue)
                            }
                        }
                    }
                    .onAppear(perform: onLoad)
                    .onChange(of: newValue) {
                        field.status = .unsaved

                        if oldValue != newValue {
                            field.update(value: newValue)
                            field.status = .saved

                            self.status = field.status
                        }
                    }
                }

                private func onLoad() -> Void {
                    if let entity = self.field.entity {
                        if let value = entity.value(forKey: self.field.keyPath) {
                            switch self.field.keyPath {
                            case "uri": self.field.value = (value as? URL)?.absoluteString
                            case "title": self.field.value = value as? String ?? ""
                            case "shredable": self.field.value = value as? Bool ?? false
                            case "overview": self.field.value = value as? String ?? ""
                            case "lastUpdate": self.field.value = Date().description
                            case "jid": self.field.value = (value as! Double).string
                            case "created": self.field.value = value
                            case "colour": self.field.value = value as? Array<Double>
                            case "alive": self.field.value = value as? Bool ?? false
                            default:
                                print("[debug] Unknown field \(self.field.keyPath)")
                            }

                            oldValue = self.field.value as? String ?? ""
                            newValue = self.field.value as? String ?? ""
                        }
                    }

                    self.status = field.status
                }
                
                private func onChangeToggle(status: Bool) -> Void {
                    field.update(value: status)
                    self.status = field.status
                }

                private func onChangeProjectDropdown(selected: Project, sender: String?) -> Void {
                    field.update(value: selected)
                    self.status = field.status
                }

                private func onChangeColour(colour: Color) -> Void {
                    field.update(value: colour.toStored())
                    self.status = field.status
                }
            }
        }
    }
    
    public struct SysEvents: Equatable {
        var id: UUID = UUID()
        var stack: [SysEvent] = []

        mutating func on(_ type: SysEvent.Types, _ callback: @escaping () -> Void) -> Void {
            stack.insert(SysEvent(type: type, data: nil, callback: callback), at: 0)
//            print("DERPO nav.events.stack.count=\(stack.count)")
        }
        
        mutating func trigger(_ type: SysEvent.Types) -> Void {
            if let event = stack.first(where: {$0.type == type}) {
                event.callback()
                stack.removeAll(where: {$0 == event})
            }
        }
        
        public static func == (lhs: Navigation.SysEvents, rhs: Navigation.SysEvents) -> Bool {
            lhs.id == rhs.id
        }
        
        public struct SysEvent: Equatable {
            var id: UUID = UUID()
            var type: SysEvent.Types
            var data: Any?
            var callback: () -> Void
            
            public static func == (lhs: Navigation.SysEvents.SysEvent, rhs: Navigation.SysEvents.SysEvent) -> Bool {
                lhs.id == rhs.id
            }
            
            public enum Types {
                case focusStateChange
            }
        }
    }

    public struct ApplicationViewState {
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
            HistoryPage(page: .jobs, view: AnyView(JobDashboardRedux()), sidebar: AnyView(JobDashboardSidebar()), title: "Jobs"),
            HistoryPage(page: .notes, view: AnyView(NoteDashboard()), sidebar: AnyView(NoteDashboardSidebar()), title: "Notes"),
            HistoryPage(page: .tasks, view: AnyView(TaskDashboard()), sidebar: AnyView(TaskDashboardSidebar()), title: "Tasks"),
            HistoryPage(page: .terms, view: AnyView(TermsDashboard()), sidebar: AnyView(TermsDashboardSidebar()), title: "Terms"),
            HistoryPage(page: .definitionDetail, view: AnyView(DefinitionDetail()), sidebar: AnyView(TermsDashboardSidebar()), title: "Definition detail"),
            HistoryPage(page: .taskDetail, view: AnyView(EmptyView()), sidebar: AnyView(TermsDashboardSidebar()), title: "Task detail"),
            HistoryPage(page: .noteDetail, view: AnyView(NoteView()), sidebar: AnyView(NoteCreateSidebar()), title: "Note detail"),
            HistoryPage(page: .people, view: AnyView(PeopleDashboard()), sidebar: AnyView(PeopleDashboardSidebar()), title: "People"),
            HistoryPage(page: .peopleDetail, view: AnyView(PeopleDetail()), sidebar: AnyView(PeopleDashboardSidebar()), title: "Person"),
        ]
        
        /// A single page representing a page the user navigated to
        public struct HistoryPage {
            var id: UUID = UUID()
            var page: Page
            var view: AnyView
            var sidebar: AnyView
            var title: String
        }
        
        public struct Breadcrumb {
            var id: UUID = UUID()
            var current: Page
            var history: [HistoryPage] = []
            
            
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
        self.job = job
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

    // @TODO: do we need this AND cancel?
    mutating func reset() -> Void {
        components = []
        text = nil
        hasResults = false
        inspectingEntity = nil
    }

    // @TODO: do we need this AND reset?
    mutating func cancel() -> Void {
        inspectingEntity = nil
        text = nil
    }

    mutating func inspect(_ obj: NSManagedObject) -> Void {
        inspectingEntity = obj
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
        case normal, focus, privacy
    }
}
