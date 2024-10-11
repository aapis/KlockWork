//
//  WidgetLibrary.UI.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

extension WidgetLibrary {
    public struct UI {
        /// Add some random flair to a message
        static public let celebratoryStatements: [String] = [
            "rejoice",
            "booya",
            "hallelujah",
            "excellent"
        ]

        public struct Buttons {
            public enum UIButtonType {
                case resetUserChoices, createNote, createTask, createRecord, createPerson, createCompany, createProject,
                createJob, createTerm, createDefinition, historyPrevious, settings, CLIMode, CLIFilter
            }

            struct ResetUserChoices: View {
                @EnvironmentObject public var state: Navigation
                public var onActionClear: (() -> Void)?

                var body: some View {
                    if self.state.session.job != nil || self.state.session.project != nil || self.state.session.company != nil {
                        FancyButtonv2(
                            text: "Reset interface to default state",
                            action: self.onActionClear != nil ? self.onActionClear : self.defaultClearAction,
                            icon: "arrow.clockwise.square",
                            iconWhenHighlighted: "arrow.clockwise.square.fill",
                            showLabel: false,
                            size: .small,
                            type: .clear,
                            font: .title
                        )
                        .help("Reset interface to default state")
                        .frame(width: 25)
                    } else {
                        EmptyView()
                    }
                }
            }

            struct CreateNote: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: self.onAction,
                        icon: "plus.square",
                        iconWhenHighlighted: "plus.square.fill",
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        redirect: AnyView(NoteCreate()),
                        pageType: .notes,
                        sidebar: AnyView(NoteCreateSidebar()),
                        font: .title
                    )
                    .help("Create a new note")
                    .frame(width: 25)
                }
            }

            struct CreatePerson: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: { self.onAction?() ; self.state.to(.peopleDetail) },
                        icon: "plus.square",
                        iconWhenHighlighted: "plus.square.fill",
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title
                    )
                    .help("Create a new contact")
                    .frame(width: 25)
                }
            }

            struct CreateCompany: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: { self.onAction?() ; self.state.to(.companyDetail) },
                        icon: "building.2.crop.circle",
                        iconWhenHighlighted: "building.2.crop.circle.fill",
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title2
                    )
                    .help("Create a new company")
                    .frame(width: 25)
                }
            }

            struct CreateProject: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: { self.onAction?() ; self.state.to(.projectDetail) },
                        icon: "folder.badge.plus",
                        iconWhenHighlighted: "folder.fill.badge.plus",
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title2
                    )
                    .help("Create a new project")
                    .frame(width: 25)
                }
            }

            struct CreateJob: View {
                @EnvironmentObject public var state: Navigation
                @AppStorage("jobdashboard.explorerVisible") private var explorerVisible: Bool = true
                @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: self.actionOnTap,
                        iconAsImage: Conf.jobs.icon,
                        iconAsImageWhenHighlighted: Conf.jobs.selectedIcon,
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title2
                    )
                    .help("Create a new job")
                    .frame(width: 25)
                }
            }

            struct CreateTerm: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: { self.onAction?() ; self.state.to(.terms) },
                        iconAsImage: Conf.terms.selectedIcon,
                        iconAsImageWhenHighlighted: Conf.terms.selectedIcon,
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title2
                    )
                    .help("Create a new taxonomy term")
                    .frame(width: 25)
                }
            }

            struct CreateDefinition: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}

                var body: some View {
                    FancyButtonv2(
                        text: "Create",
                        action: { self.onAction?() ; self.state.to(.definitionDetail) },
                        iconAsImage: Conf.terms.selectedIcon,
                        iconAsImageWhenHighlighted: Conf.terms.selectedIcon,
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title2
                    )
                    .help("Create a new term definition")
                    .frame(width: 25)
                }
            }

            struct CreateRecord: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}
                @State private var isHighlighted: Bool = false
                @State private var selectedPage: Page = .dashboard

                var body: some View {
                    FancyButtonv2(
                        text: self.state.session.job != nil ? "Log to job \(self.state.session.job!.title ?? self.state.session.job!.jid.string)" : "Log",
                        action: self.onAction,
                        icon: "plus.square",
                        iconWhenHighlighted: "plus.square.fill",
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title
                    )
                    .help("Create a new record")
                    .frame(width: 25)
                    .disabled(self.state.session.job == nil)
                    .opacity(self.state.session.job == nil ? 0.5 : 1)
                }
            }

            struct HistoryPrevious: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}
                @State private var isHighlighted: Bool = false
                @State private var selectedPage: Page = .dashboard
                private var isEmpty: Bool { self.state.history.recent.count == 0 }

                var body: some View {
                    Button {
                        if let previous = self.state.history.previous() {
                            self.state.to(previous.page, addToHistory: false)
                            self.selectedPage = previous.page
                            self.onAction?()
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .padding(8)
                        .background(self.state.session.appPage.primaryColour.opacity(self.isHighlighted ? 1 : 0.6))
                        .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                        .clipShape(.rect(cornerRadius: 5))
                        .padding([.top, .bottom], 10)
                    }
                    .disabled(self.isEmpty)
                    .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [.command])
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in !self.isEmpty ? self.isHighlighted = hover : nil})
                }
            }

            struct Settings: View {
                @EnvironmentObject public var state: Navigation
                public var onAction: (() -> Void)? = {}
                @State private var isHighlighted: Bool = false
                @State private var selectedPage: Page = .dashboard

                var body: some View {
                    Button {
                        self.onAction?()
                    } label: {
                        Image(systemName: "gear")
                            .font(.title)
                            .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 10)
                    }
                    .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [.command])
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                }
            }

            struct CLIMode: View {
                @EnvironmentObject public var state: Navigation
                @AppStorage("general.experimental.cli") private var cliEnabled: Bool = false
                @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
                public var onAction: (() -> Void)? = {}
                @State private var isHighlighted: Bool = false
                @State private var selectedPage: Page = .dashboard

                var body: some View {
                    if self.cliEnabled {
                        FancyButtonv2(
                            text: "Command line mode",
                            action: {self.commandLineMode.toggle() ; self.onAction?()},
                            icon: self.commandLineMode ? "apple.terminal.fill" : "apple.terminal",
                            iconWhenHighlighted: self.commandLineMode ? "apple.terminal" : "apple.terminal.fill",
                            showLabel: false,
                            size: .small,
                            type: .clear,
                            font: .title
                        )
                        .help(self.commandLineMode ? "Exit CLI mode" : "Enter CLI mode")
                        .frame(width: 25)
                    }
                }
            }

            struct CLIFilter: View {
                @EnvironmentObject public var state: Navigation
                @AppStorage("general.experimental.cli") private var cliEnabled: Bool = false
                @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
                @AppStorage("today.cli.showFilter") private var showCLIFilter: Bool = false

                var body: some View {
                    if self.cliEnabled && self.commandLineMode {
                        FancyButtonv2(
                            text: "Filter",
                            action: {self.showCLIFilter.toggle()},
                            icon: "line.3.horizontal.decrease",
                            bgColour: self.state.session.appPage.primaryColour.opacity(0.2),
                            showLabel: false,
                            size: .small,
                            type: .clear
                        )
                        .mask(Circle())
                    }
                }
            }
        }

        struct ActiveIndicator: View {
            public var colour: Color = .white
            public var action: (() -> Void)? = nil
            public var href: Page? = nil

            @EnvironmentObject private var nav: Navigation

            var body: some View {
                Button {
                    if let callback = action {
                        callback()
                    } else {
                        if let href = href {
                            nav.to(href)
                        }
                    }
                } label: {
                    ZStack {
                        Theme.base
                        colour
                    }
                }
                .buttonStyle(.borderless)
                .frame(width: 6, height: 50)
            }
        }

        struct Meetings: View {
            @EnvironmentObject public var state: Navigation
            @EnvironmentObject public var updater: ViewUpdater
            @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
            @AppStorage("today.calendar") public var calendar: Int = -1
            @State private var upcomingEvents: [EKEvent] = []
            @State private var calendarName: String = ""

            private let maxEventsToPreview: Int = 2

            var body: some View {
                VStack(alignment: .leading, spacing: 5) {
                    if calendar > -1 {
                        HStack(alignment: .top) {
                            if self.upcomingEvents.count == 0 {
                                Text("No meetings today, \(UI.celebratoryStatements.randomElement()!)!")
                            } else if self.upcomingEvents.count > 1 {
                                HStack(alignment: .center) {
                                    Image(systemName: "calendar")
                                        .symbolRenderingMode(.hierarchical)
                                    Text("\(self.upcomingEvents.count) meetings")
                                }
                            } else {
                                Text("1 meeting")
                            }
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(upcomingEvents.prefix(self.maxEventsToPreview).sorted(by: {$0.startDate < $1.startDate}), id: \.self) { event in
                                HStack {
                                    let hasPassed = event.startDate >= Date()
                                    Image(systemName: hasPassed ? "arrow.right" : "checkmark")
                                        .padding(.leading, 10)
                                    HStack {
                                        Text("\(event.startTime()) - \(event.endTime()):")
                                        Text(event.title)
                                    }
                                    .foregroundColor(hasPassed ? (self.state.session.job?.backgroundColor ?? .clear).isBright() ? Theme.lightBase : Theme.lightWhite : .gray.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                }
                .foregroundStyle((self.state.session.job?.backgroundColor ?? .clear).isBright() ? Theme.lightBase : Theme.lightWhite)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.calendar) { self.actionOnChangeCalendar() }
                .id(self.updater.get("dashboard.header"))
            }
        }

        struct Chip: View {
            public var type: PageConfiguration.EntityType
            public var count: Int

            var body: some View {
                HStack(alignment: .center, spacing: 8) {
                    Text(String(self.count))
                    self.type.icon
                }
                .help("\(self.count) \(self.type.label)")
                .padding(3)
                .background(.white.opacity(0.4).blendMode(.softLight))
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }

        struct AppNavigation: View {
            @EnvironmentObject public var state: Navigation

            var body: some View {
                ZStack {
                    self.state.session.appPage.primaryColour
                    LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                        .opacity(0.6)
                        .blendMode(.softLight)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Buttons.HistoryPrevious()
                            Spacer()
                            SimpleDateSelector()
                            Spacer()
                            ForEach(self.state.navButtons, id: \.self) { type in
                                switch type {
                                case .CLIMode: Buttons.CLIMode()
                                case .CLIFilter: Buttons.CLIFilter()
                                case .historyPrevious: Buttons.HistoryPrevious()
                                case .resetUserChoices: Buttons.ResetUserChoices()
                                case .settings: Buttons.Settings()
                                case .createJob: Buttons.CreateJob()
                                case .createNote: Buttons.CreateNote()
//                                    case .createTask: Buttons.CreateTask()
                                case .createTerm: Buttons.CreateTerm()
                                case .createPerson: Buttons.CreatePerson()
                                case .createRecord: Buttons.CreateRecord()
                                case .createCompany: Buttons.CreateCompany()
                                case .createProject: Buttons.CreateProject()
                                case .createDefinition: Buttons.CreateDefinition()
                                default: EmptyView()
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        Divider()
                    }
                }
                .frame(height: 55)
            }
        }

        struct SimpleDateSelector: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("today.numPastDates") public var numPastDates: Int = 20
            @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
            @State private var isToday: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var date: String = ""
            @State private var showDateOverlay: Bool = false
            @State private var sDate: Date = Date()

            var body: some View {
                HStack(alignment: .center) {
                    FancyButtonv2(
                        text: "Previous day",
                        action: self.actionPreviousDay,
                        icon: "chevron.left",
                        fgColour: .gray,
                        highlightColour: .white,
                        showLabel: false,
                        size: .titleLink,
                        type: .titleLink
                    )
                    .help("Previous day")
                    .frame(height: 20)

                    Button {
                        self.showDateOverlay.toggle()
                    } label: {
                        HStack(alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(self.isToday ? .yellow.opacity(0.6) : .gray, lineWidth: 1)
                                    .fill(.white.opacity(self.isHighlighted ? 0.2 : 0.1))
                                if !self.showDateOverlay {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(.gray)
                                        Text(self.date)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                    }
                    .foregroundStyle(self.isHighlighted ? .white : self.isToday ? .yellow.opacity(0.6) : .gray)
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                    .overlay {
                        if self.showDateOverlay {
                            HStack {
                                DatePicker("", selection: $sDate)
                                Image(systemName: "xmark")
                            }
                        }
                    }

                    FancyButtonv2(
                        text: "Next day",
                        action: self.actionNextDay,
                        icon: "chevron.right",
                        fgColour: .gray,
                        showLabel: false,
                        size: .titleLink,
                        type: .titleLink
                    )
                    .help("Next day")
                    .frame(height: 20)
                }
                .padding(12)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnChangeDate() }
                .onChange(of: self.sDate) { self.state.session.date = self.sDate }
            }
        }

        struct ListLinkItem: View {
            @EnvironmentObject private var state: Navigation
            public let activity: Activity
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.to(activity.page)
                } label: {
                    HStack(alignment: .center) {
                        if let image = activity.iconAsImage {
                            image
                                .foregroundStyle(.yellow)
                        } else if let icon = activity.icon {
                            Image(systemName: icon)
                                .foregroundStyle(.yellow)
                        }
                        Text(activity.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .padding(8)
                    .background(.white.opacity(self.isHighlighted ? 0.07 : 0.03))
                    .clipShape(.rect(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        struct ListLinkTitle: View {
            @EnvironmentObject private var state: Navigation
            public var type: ExploreActivityType?
            public var text: String?

            var body: some View {
                HStack {
                    if let type = self.type {
                        Text(type.title.uppercased())
                    } else if let text = self.text {
                        Text(text.uppercased())
                    } else {
                        Text("Title")
                    }
                    Spacer()
                }
                .foregroundStyle(.gray)
                .font(.caption)
                .padding(.bottom)
            }
        }

        struct EntityStatistics: View {
            @EnvironmentObject private var state: Navigation
            @State private var statistics: [Statistic] = []

            var body: some View {
                VStack(spacing: 0) {
                    ListLinkTitle(text: "Overview")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            ForEach(self.statistics, id: \.id) { type in type }
                        }
                    }
                }
                .padding()
                .background(Theme.textBackground)
                .clipShape(.rect(cornerRadius: 5))
                .onAppear(perform: self.actionOnAppear)
            }

            struct Statistic: View, Identifiable {
                @EnvironmentObject private var state: Navigation
                var id: UUID = UUID()
                var type: Conf
                @State private var count: Int = 0
                @State private var isLoading: Bool = false
                @State private var isHighlighted: Bool = false

                var body: some View {
                    Button {
                        self.state.to(self.type.page)
                    } label: {
                        VStack(alignment: .center, spacing: 0) {
                            ZStack(alignment: .center) {
                                self.state.session.appPage.primaryColour.opacity(self.isHighlighted ? 1 : 0.7)
                                VStack(alignment: .center, spacing: 0) {
                                    if self.isLoading {
                                        ProgressView()
                                    } else {
                                        (self.isHighlighted ? self.type.selectedIcon : self.type.icon)
                                            .font(.largeTitle)
                                            .padding()
                                            .frame(height: 30)
                                    }
                                }
                                Spacer()
                            }
                            .frame(height: 65)

                            ZStack(alignment: .center) {
                                (self.isHighlighted ? self.state.session.appPage.primaryColour.opacity(0.4) : Theme.lightWhite)
                                VStack(alignment: .center, spacing: 0) {
                                    Text(String(self.count))
                                        .font(.system(.title3, design: .monospaced))
                                        .foregroundStyle(self.isHighlighted ? .white : self.state.session.appPage.primaryColour)
                                }
                            }
                            .frame(height: 25)
                        }
//                        .frame(height: 90)
                        .clipShape(.rect(cornerRadius: 5))
                        .useDefaultHover({ hover in self.isHighlighted = hover })
                    }
                    .buttonStyle(.plain)
                    .onAppear(perform: self.actionOnAppear)
                    .help("\(self.count) \(self.type.label)")
                }
            }
        }
    }
}

extension WidgetLibrary.UI.EntityStatistics {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        let types = PageConfiguration.EntityType.allCases.filter({ $0 != .BruceWillis })

        for type in types {
            self.statistics.append(
                Statistic(type: type)
            )
        }
    }
}

extension WidgetLibrary.UI.EntityStatistics.Statistic {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        Task {
            await self.determineCount()

            self.isLoading.toggle()
        }
    }
    
    /// Async method to determine count for each entity type
    /// - Returns: Void
    private func determineCount() async -> Void {
        self.isLoading.toggle()

        switch self.type {
        case .jobs: self.count = CoreDataJob(moc: self.state.moc).countAll()
        case .records: self.count = CoreDataRecords(moc: self.state.moc).countAll()
        case .tasks: self.count = CoreDataTasks(moc: self.state.moc).countAll()
//        case .notes: self.count = CoreDataNotes(moc: self.state.moc).countAll()
        case .people: self.count = CoreDataPerson(moc: self.state.moc).countAll()
        case .companies: self.count = CoreDataCompanies(moc: self.state.moc).countAll()
        case .projects: self.count = CoreDataProjects(moc: self.state.moc).countAll()
        case .terms: self.count = CoreDataTaxonomyTerms(moc: self.state.moc).countAll()
        default: self.count = 0
        }
    }
}

extension WidgetLibrary.UI.SimpleDateSelector {
    /// Onload handler. Sets up a timer to advance to the next day and sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.actionOnChangeDate()

        // Auto-advance date to tomorrow when the clock strikes midnight
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { timer in
            let components = Calendar.autoupdatingCurrent.dateComponents([.hour], from: Date())

            if let hour = components.hour {
                if hour == 24 {
                    self.actionNextDay()
                }
            }
        }
    }
    
    /// Fires when the date is changed.
    /// - Returns: Void
    private func actionOnChangeDate() -> Void {
        self.date = DateHelper.todayShort(self.state.session.date, format: "MMMM d, yyyy")
        self.isToday = self.areSameDate(self.state.session.date, Date())
    }

    /// Determine if two dates are the same
    /// - Parameters:
    ///   - lhs: Date
    ///   - rhs: Date
    /// - Returns: Void
    private func areSameDate(_ lhs: Date, _ rhs: Date) -> Bool {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        let fmtDate = df.string(from: lhs)
        let fmtSessionDate = df.string(from: rhs)

        return fmtDate == fmtSessionDate
    }
    
    /// Decrement the current day
    /// - Returns: Void
    private func actionPreviousDay() -> Void {
        self.state.session.date -= 86400
    }
    
    /// Increment the current day
    /// - Returns: Void
    private func actionNextDay() -> Void {
        self.state.session.date += 86400
    }
}

extension WidgetLibrary.UI.Buttons.ResetUserChoices {
    private func defaultClearAction() -> Void {
        self.state.session.job = nil
        self.state.session.project = nil
        self.state.session.company = nil
    }
}

extension WidgetLibrary.UI.Buttons.CreateJob {
    /// Fires when the button is clicked/tapped.
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.editorVisible = true
        self.explorerVisible = false

        // Creates a new job entity so the user can customize it
        // @TODO: move to new method CoreDataJobs.create
        let newJob = Job(context: self.state.moc)
        newJob.id = UUID()
        newJob.jid = 1.0
        newJob.colour = Color.randomStorable()
        newJob.alive = true
        newJob.project = CoreDataProjects(moc: self.state.moc).alive().first(where: {$0.company?.isDefault == true})
        newJob.created = Date()
        newJob.lastUpdate = newJob.created
        newJob.overview = "Sample job overview"
        newJob.title = "Sample job title"
        self.state.session.job = newJob
        self.state.forms.tp.editor.job = newJob
    }
}

extension WidgetLibrary.UI.Meetings {
    private func actionOnAppear() -> Void {
        if let chosenCalendar = ce.selectedCalendar() {
            calendarName = chosenCalendar
            upcomingEvents = ce.events(chosenCalendar).filter {$0.startDate > Date()}
        }
    }

    private func actionOnChangeCalendar() -> Void {
        let calendars = CoreDataCalendarEvent(moc: self.state.moc).getCalendarsForPicker()
        let calendarChanged = calendars.first(where: ({$0.tag == self.calendar})) != nil
        if calendarChanged {
            updater.updateOne("dashboard.header")
        }
    }
}
