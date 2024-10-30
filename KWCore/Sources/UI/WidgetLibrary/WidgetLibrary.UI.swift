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
                .buttonStyle(.plain)
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
            @State private var randomCelebratoryStatement: String = ""

            private let maxEventsToPreview: Int = 2

            var body: some View {
                VStack(alignment: .leading, spacing: 5) {
                    if calendar > -1 {
                        HStack(alignment: .top) {
                            if self.upcomingEvents.count == 0 {
                                Text("No meetings today, \(self.randomCelebratoryStatement)!")
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
                                    Button {
                                        self.state.session.search.inspectingEvent = event
                                    } label: {
                                        HStack {
                                            Text("\(event.startTime()) - \(event.endTime()):")
                                            Text(event.title)
                                        }
                                        .foregroundColor(hasPassed ? (self.state.session.job?.backgroundColor ?? .clear).isBright() ? Theme.lightBase : .white : .gray.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                    }
                                    .useDefaultHover({_ in})
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .foregroundStyle((self.state.session.job?.backgroundColor ?? .clear).isBright() ? Theme.lightBase : Theme.lightWhite)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.calendar) { self.actionOnChangeCalendar() }
                .onChange(of: self.state.session.search.inspectingEvent) {
                    if let event = self.state.session.search.inspectingEvent {
                        self.state.setInspector(AnyView(Inspector(event: event)))
                    } else {
                        self.state.setInspector()
                    }
                }
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
                                case .createTask: Buttons.CreateTask()
                                case .createTerm: Buttons.CreateTerm()
                                case .createPerson: Buttons.CreatePerson()
                                case .createRecord: Buttons.CreateRecord()
                                case .createCompany: Buttons.CreateCompany()
                                case .createProject: Buttons.CreateProject()
                                case .createDefinition: Buttons.CreateDefinition()
                                case .sidebarToggle: Buttons.SidebarToggle()
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
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(self.isToday ? .yellow.opacity(0.6) : .gray, lineWidth: 1)
                                    .fill(self.isToday ? .yellow.opacity(self.isHighlighted ? 0.8 : 0.7) : .gray.opacity(self.isHighlighted ? 0.8 : 0.7))
                                if !self.showDateOverlay {
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text(self.date)
                                    }
                                    .foregroundStyle(self.isToday ? Theme.base : Theme.lightWhite)
                                }
                            }
                            .frame(width: 200)
                        }
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                    .overlay {
                        if self.showDateOverlay {
                            DatePicker("", selection: $sDate)
                                .foregroundStyle(self.isToday ? Theme.base : Theme.lightBase)
                        }
                    }
                    .onChange(of: self.sDate) { self.showDateOverlay.toggle() }

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
            public var page: Page
            public var name: String
            public var icon: String?
            public var iconAsImage: Image?
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.to(self.page)
                } label: {
                    HStack(alignment: .center) {
                        if let image = self.iconAsImage {
                            image
                                .foregroundStyle(self.state.session.job?.backgroundColor ?? .yellow)
                        } else if let icon = self.icon {
                            Image(systemName: icon)
                                .foregroundStyle(self.state.session.job?.backgroundColor ?? .yellow)
                        }
                        Text(self.name)
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

        struct ListButtonItem: View {
            @EnvironmentObject private var state: Navigation
            public var callback: (String) -> Void
            public var name: String
            public var icon: String?
            public var iconAsImage: Image?
            public var actionIcon: String?
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.callback(self.name)
                } label: {
                    HStack(alignment: .center) {
                        if let image = self.iconAsImage {
                            image
                                .foregroundStyle(self.state.session.job?.backgroundColor ?? .yellow)
                        } else if let icon = self.icon {
                            Image(systemName: icon)
                                .foregroundStyle(self.state.session.job?.backgroundColor ?? .yellow)
                        }
                        Text(self.name)
                            .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                        Spacer()
                        if let actionIcon = self.actionIcon {
                            Image(systemName: actionIcon)
                                .foregroundStyle(self.state.session.job?.backgroundColor ?? .yellow)
                        }
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
                .padding(.bottom, 5)
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
                .background(
                    ZStack {
                        self.state.session.appPage.primaryColour
                        Theme.textBackground
                    }
                )
                .clipShape(.rect(bottomLeadingRadius: 5, bottomTrailingRadius: 5))
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
                                Color.gray.opacity(self.isHighlighted ? 1 : 0.7)
                                VStack(alignment: .center, spacing: 0) {
                                    if self.isLoading {
                                        ProgressView()
                                    } else {
                                        (self.isHighlighted ? self.type.selectedIcon : self.type.icon)
                                            .symbolRenderingMode(.hierarchical)
                                            .font(.largeTitle)
                                    }
                                }
                                Spacer()
                            }
                            .frame(height: 65)

                            ZStack(alignment: .center) {
                                (self.isHighlighted ? Color.yellow : Theme.textBackground)
                                VStack(alignment: .center, spacing: 0) {
                                    Text(String(self.count))
                                        .font(.system(.title3, design: .monospaced))
                                        .foregroundStyle(self.isHighlighted ? Theme.base : .gray)
                                }
                            }
                            .frame(height: 25)
                        }
                        .frame(width: 65)
                        .clipShape(.rect(cornerRadius: 5))
                        .useDefaultHover({ hover in self.isHighlighted = hover })
                    }
                    .buttonStyle(.plain)
                    .onAppear(perform: self.actionOnAppear)
                    .help("\(self.count) \(self.type.label)")
                }
            }
        }

        struct ExploreLinks: View {
            @EnvironmentObject private var state: Navigation
            private var activities: [Activity] {
                [
                    Activity(name: "Activity Calendar", page: .activityCalendar, type: .visualize, icon: "calendar"),
                    Activity(name: "Flashcards", page: .activityFlashcards, type: .activity, icon: "person.text.rectangle"),
                ]
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        ForEach(ExploreActivityType.allCases, id: \.hashValue) { type in
                            VStack(alignment: .leading, spacing: 5) {
                                UI.ListLinkTitle(type: type)

                                ForEach(self.activities.filter({$0.type == type}), id: \.id) { activity in
                                    UI.ListLinkItem(
                                        page: activity.page,
                                        name: activity.name,
                                        icon: activity.icon
                                    )
                                }
                            }
                            .padding()
                            .background(
                                ZStack {
                                    self.state.session.appPage.primaryColour
                                    Theme.textBackground
                                }
                            )
                            .clipShape(.rect(cornerRadius: 5))
                        }
                    }
                }
            }
        }

        // @TODO: move to another namespace
        struct Link: Identifiable, Hashable {
            var id: UUID = UUID()
            var label: String
            var column: Column
            var page: Page?
            var date: Date = Date.now
        }

        enum Column: CaseIterable {
            case recent, saved

            var title: String {
                switch self {
                case .recent: "Recent Searches"
                case .saved: "Saved Searches"
                }
            }
        }

        struct LinkList: View {
            @EnvironmentObject private var state: Navigation
            @State private var links: Set<Link> = []
            public var location: WidgetLocation
            public var isSearching: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    if self.location == .content {
                        HStack(alignment: .top) {
                            LinkList
                        }
                    } else if self.location == .sidebar {
                        LinkList
                    }
                }
                .padding(.top, 8)
                .padding([.leading, .trailing], self.location == .content ? 16 : 8)
                .padding(.bottom, self.isSearching ? 0 : self.location == .content ? 16 : 8)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.search.history) { self.actionOnAppear() }
            }

            var LinkList: some View {
                ForEach(Column.allCases, id: \.hashValue) { column in
                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            UI.ListLinkTitle(text: column.title)
                            Button {
                                self.state.session.search.clearHistory()
                                if column == .saved {
                                    CDSavedSearch(moc: self.state.moc).destroyAll()
                                }
                                self.actionOnAppear()
                            } label: {
                                Image(systemName: "arrow.clockwise.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            .help("Clear all \(column.title)")
                            .disabled(self.links.filter({$0.column == column}).count == 0)
                            .buttonStyle(.plain)
                            .useDefaultHover({_ in})
                        }
                        .padding(8)

                        ZStack(alignment: .bottom) {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                                .blendMode(.softLight)
                                .opacity(0.4)
                                .frame(height: 20)

                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 5) {
                                    if self.links.filter({$0.column == column}).count == 0 {
                                        UI.ListButtonItem(
                                            callback: {_ in},
                                            name: "Nothing yet"
                                        )
                                        .disabled(true)
                                    }

                                    ForEach(self.links.filter({$0.column == column}).sorted(by: {$0.date > $1.date}), id: \.id) { link in
                                        UI.ListButtonItem(
                                            callback: self.actionOnTap,
                                            name: link.label,
                                            actionIcon: "magnifyingglass"
                                        )
                                        .contextMenu {
                                            if link.column == .recent {
                                                Button("Save search term") {
                                                    self.state.session.search.addToHistory(link.label)
                                                    CDSavedSearch(moc: self.state.moc).create(
                                                        term: link.label,
                                                        created: Date()
                                                    )
                                                    self.actionOnAppear()
                                                }
                                                Divider()
                                                Button("Delete") {
                                                    self.state.session.search.removeFromHistory(link.label)
                                                    self.actionOnAppear()
                                                }
                                            } else {
                                                Button("Delete") {
                                                    CDSavedSearch(moc: self.state.moc).destroy(link.label)
                                                    self.actionOnAppear()
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(self.location == .content ? 16 : 8)
                            }
                        }
                        .background(Theme.textBackground)
                        .clipShape(.rect(cornerRadius: 5))
                    }
                }
            }
        }

        struct ActivityCalendar: View {
            @EnvironmentObject private var state: Navigation
            @State public var month: String = "_DEFAULT_MONTH"
            @State private var date: Date = Date()
            @State private var legendId: UUID = UUID() // @TODO: remove this gross hack once views refresh properly
            @State private var calendarId: UUID = UUID() // @TODO: remove this gross hack once views refresh properly
            public var weekdays: [DayOfWeek] = [
                DayOfWeek(symbol: "Sun"),
                DayOfWeek(symbol: "Mon"),
                DayOfWeek(symbol: "Tues"),
                DayOfWeek(symbol: "Wed"),
                DayOfWeek(symbol: "Thurs"),
                DayOfWeek(symbol: "Fri"),
                DayOfWeek(symbol: "Sat")
            ]
            public var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
            }

            var body: some View {
                NavigationStack {
                    VStack {
                        Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 0) {
                            MonthNav(date: $date)

                            // Day of week
                            GridRow {
                                ZStack(alignment: .bottomLeading) {
                                    LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                                        .frame(height: 50)
                                        .opacity(0.05)
                                    LazyVGrid(columns: self.columns, alignment: .center) {
                                        ForEach(weekdays) {sym in
                                            Text(sym.symbol)
                                                .foregroundStyle(sym.current ? self.state.theme.tint : .white)
                                        }
                                        .font(.caption)
                                    }
                                    .padding([.leading, .trailing, .top])
                                    .padding(.bottom, 5)
                                }
                            }
                            .background(Theme.rowColour)

                            VStack {
                                // List of days representing 1 month
                                Month(month: $month, id: $calendarId)
                                    .id(self.calendarId)

                                Spacer() // @TODO: put a new set of stats or something here?
                            }
                            .background(Theme.rowColour)

                            // Legend
                            Legend(id: $legendId, calendarId: $calendarId)
                                .border(width: 1, edges: [.top], color: .gray.opacity(0.7))
                                .id(self.legendId)
                        }
                        Spacer()
                    }
                    .background(Theme.cGreen)
                    .scrollDismissesKeyboard(.immediately)
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.date) { self.actionChangeDate()}
                    .navigationTitle("Activity Calendar")
    #if os(iOS)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                self.state.date = DateHelper.startOfDay()
                                self.date = self.state.date
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                        }
                    }
    #endif
                }
            }

            struct MonthNav: View {
                @EnvironmentObject private var state: Navigation
                @Binding public var date: Date
                @State private var isCurrentMonth: Bool = false // @TODO: implement

                var body: some View {
                    GridRow {
                        HStack {
                            MonthNavButton(orientation: .leading, date: $date)
                            Spacer()
                            MonthNavButton(orientation: .trailing, date: $date)
                        }
                    }
                    .border(width: 1, edges: [.bottom], color: .gray)
                    .background(Theme.cGreen)
                }
            }

            struct MonthNavButton: View {
                @EnvironmentObject private var state: Navigation
                public var orientation: UnitPoint
                @Binding public var date: Date
                @State private var previousMonth: String = ""
                @State private var nextMonth: String = ""
                @State private var isHighlighted: Bool = false

                var body: some View {
                    HStack {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [Theme.base.opacity(0.6), .clear]), startPoint: self.orientation, endPoint: self.orientation == .leading ? .trailing : .leading)
                                .blendMode(.softLight)
                            Button {
                                self.actionOnTap()
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: self.orientation == .leading ? "chevron.left" : "chevron.right")
                                        .padding([.top, .bottom], 12)
                                    Spacer()
                                }
                                .useDefaultHover({ hover in self.isHighlighted = hover })
                            }
                            .buttonStyle(.plain)
                            .frame(width: 50)
                            .background(Theme.cPurple.opacity(self.isHighlighted ? 1 : 0.8))
                            .clipShape(.capsule(style: .continuous))
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                        }
                    }
                    .frame(width: 80, height: 75)
                }

                /// Navigate between months by tapping on the button
                /// @TODO: shared functionality with ActivityCalendar.actionOnSwipe, refactor!
                /// - Returns: Void
                private func actionOnTap() -> Void {
                    let oneMonthMs: Double = 2592000

                    if self.orientation == .leading {
                        self.date = self.state.session.date - oneMonthMs
                    } else {
                        self.date = self.state.session.date + oneMonthMs
                    }
                }
            }
        }

        struct FlashcardActivity: View {
            @EnvironmentObject private var state: Navigation
            private var page: PageConfiguration.AppPage = .explore
            @State private var isJobSelectorPresented: Bool = false
            @State private var job: Job? // @TODO: rewrite to use self.state.session.job

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    FlashcardDeck(job: $job)
                }
                .onAppear(perform: {
                    if self.state.session.job != nil {
                        self.job = self.state.session.job
                        self.isJobSelectorPresented = false
                    } else {
                        self.isJobSelectorPresented = true
                    }
                })
                .onChange(of: self.state.session.job) { self.job = self.state.session.job }
                .background(self.page.primaryColour)
                .navigationTitle(job != nil ? self.job!.title ?? self.job!.jid.string: "Activity: Flashcard")
        #if os(iOS)
                .toolbarBackground(job != nil ? self.job!.backgroundColor : Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        #endif
            }

            struct FlashcardDeck: View {
                @EnvironmentObject private var state: Navigation
                @Binding public var job: Job?
                @State private var terms: Array<TaxonomyTerm> = []
                @State private var current: TaxonomyTerm? = nil
                @State private var isAnswerCardShowing: Bool = false
                @State private var clue: String = ""
                @State private var viewed: Set<TaxonomyTerm> = []
                @State private var definitions: [TaxonomyTermDefinitions] = []

                var body: some View {
                    VStack(alignment: .center, spacing: 0) {
                        Card(
                            isAnswerCardShowing: $isAnswerCardShowing,
                            definitions: $definitions,
                            current: $current,
                            job: $job
                        )
                        Actions(
                            isAnswerCardShowing: $isAnswerCardShowing,
                            definitions: $definitions,
                            current: $current,
                            terms: $terms,
                            viewed: $viewed
                        )
                    }
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: job) {
                        self.actionOnAppear()
                    }
                }

                struct Actions: View {
                    @EnvironmentObject private var state: Navigation
                    @Binding public var isAnswerCardShowing: Bool
                    @Binding public var definitions: [TaxonomyTermDefinitions]
                    @Binding public var current: TaxonomyTerm?
                    @Binding public var terms: [TaxonomyTerm]
                    @Binding public var viewed: Set<TaxonomyTerm>

                    var body: some View {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                .frame(height: 50)
                                .opacity(0.06)

                            Buttons
                        }
                    }

                    var Buttons: some View {
                        HStack(alignment: .center) {
                            Button {
                                self.isAnswerCardShowing.toggle()
                            } label: {
                                ZStack(alignment: .center) {
                                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                    Image(systemName: "rectangle.landscape.rotate")
                                }
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .mask(Circle().frame(width: 50, height: 50))

                            Button {
                                self.isAnswerCardShowing = false
                            } label: {
                                ZStack(alignment: .center) {
                                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                    Image(systemName: "hand.thumbsup.fill")
                                }
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .mask(Circle().frame(width: 50, height: 50))

                            Button {
                                self.isAnswerCardShowing = false
                            } label: {
                                ZStack(alignment: .center) {
                                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                    Image(systemName: "hand.thumbsdown.fill")
                                }
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .mask(Circle().frame(width: 50, height: 50))

                            Button {
                                self.isAnswerCardShowing = false

                                if let next = self.terms.randomElement() {
                                    if next != current {
                                        // Pick another random element if we've seen the next item already
                                        if !self.viewed.contains(next) {
                                            current = next
                                        } else {
                                            current = self.terms.randomElement()
                                        }
                                    }
                                }

                                if self.current != nil {
                                    viewed.insert(self.current!)
                                }
                            } label: {
                                ZStack(alignment: .center) {
                                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .mask(Circle().frame(width: 50, height: 50))
                        }
                        .frame(height: 90)
                        .border(width: 1, edges: [.top], color: self.state.theme.tint)
                    }
                }

                struct Card: View {
                    @Binding public var isAnswerCardShowing: Bool
                    @Binding public var definitions: [TaxonomyTermDefinitions] // @TODO: convert this to dict grouped by job
                    @Binding public var current: TaxonomyTerm?
                    @Binding public var job: Job?
                    @State private var clue: String = ""

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            if self.isAnswerCardShowing {
                                // Definitions
                                HStack(alignment: .center, spacing: 0) {
                                    Text("\(self.definitions.count) Jobs define \"\(self.clue)\"")
                                        .textCase(.uppercase)
                                        .font(.caption)
                                        .padding(5)
                                    Spacer()
                                }
                                .background(self.job?.backgroundColor ?? Theme.rowColour)

                                VStack(alignment: .leading, spacing: 0) {
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 1) {
                                            ForEach(Array(definitions.enumerated()), id: \.element) { idx, term in
                                                VStack(alignment: .leading, spacing: 0) {
                                                    HStack(alignment: .top) {
                                                        Text((term.job?.title ?? term.job?.jid.string) ?? "_JOB_NAME")
                                                            .multilineTextAlignment(.leading)
                                                            .padding(14)
                                                            .foregroundStyle((term.job?.backgroundColor ?? Theme.rowColour).isBright() ? .white.opacity(0.75) : .gray)
                                                        Spacer()
                                                    }


                                                    ZStack(alignment: .topLeading) {
                                                        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                                            .frame(height: 50)
                                                            .opacity(0.1)

                                                        NavigationLink {
                                                            DefinitionDetail(definition: term)
                                                        } label: {
                                                            HStack(alignment: .center) {
                                                                Text(term.definition ?? "Definition not found")
                                                                    .multilineTextAlignment(.leading)
                                                                Spacer()
                                                                Image(systemName: "chevron.right")
                                                            }
                                                            .padding(14)
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                }
                                                .background(term.job?.backgroundColor)
                                                .foregroundStyle((term.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Answer
                                if self.current != nil {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Spacer()
                                        VStack(alignment: .center) {
                                            Text("Clue")
                                                .foregroundStyle((self.job?.backgroundColor ?? Theme.rowColour).isBright() ? .white.opacity(0.75) : .gray)
                                            Text(clue)
                                                .font(.title2)
                                                .bold()
                                                .multilineTextAlignment(.center)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            Spacer()
                        }
                        .onChange(of: current) {
                            if self.current != nil {
                                self.clue = current?.name ?? "Clue"

                                if let defs = self.current!.definitions {
                                    if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                                        self.definitions = ttds
                                    }
                                }
                            }
                        }
                    }
                }
            }

            struct Flashcard {
                var term: TaxonomyTerm
            }
        }

        struct SearchBar: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("searchbar.showTypes") private var showingTypes: Bool = false
            @AppStorage("searchbar.shared") private var searchText: String = ""
            @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
            @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
            public var disabled: Bool = false
            public var placeholder: String? = "Search..."
            public var onSubmit: (() -> Void)? = nil
            public var onReset: (() -> Void)? = nil
            @FocusState private var primaryTextFieldInFocus: Bool

            var body: some View {
                ZStack(alignment: .trailing)  {
                    FancyTextField(placeholder: placeholder!, lineLimit: 1, onSubmit: onSubmit, transparent: true, disabled: disabled, font: .title3, text: $searchText)
                        .padding(.leading, 35)
                        .focused($primaryTextFieldInFocus)
                        .onAppear {
                            // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.primaryTextFieldInFocus = true
                            }
                        }

                    HStack(alignment: .center) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                        Spacer()
                        if self.searchText.count > 0 {
                            UI.Buttons.Close(action: self.actionOnReset)
                        } else {
                            FancyButtonv2(
                                text: "Entities",
                                action: {self.showingTypes.toggle()},
                                icon: self.showingTypes ? "arrow.up.square.fill" : "arrow.down.square.fill",
                                showLabel: false,
                                type: .clear,
                                font: .title2
                            )
                            .help("Choose the entities you want to search")
                        }
                    }
                    .padding([.leading, .trailing])
                }
                .frame(height: 57)
                .background(self.state.session.job?.backgroundColor.opacity(0.6) ?? Theme.textBackground)
                .onAppear(perform: self.actionOnAppear)
            }
        }

        // MARK: BoundSearchBar
        struct BoundSearchBar: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("searchbar.showTypes") private var showingTypes: Bool = false
            @AppStorage("searchbar.shared") private var searchText: String = ""
            @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
            @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
            @Binding public var text: String
            public var disabled: Bool = false
            public var placeholder: String? = "Search..."
            public var onSubmit: (() -> Void)? = nil
            public var onReset: (() -> Void)? = nil
            @FocusState private var primaryTextFieldInFocus: Bool

            var body: some View {
                ZStack(alignment: .trailing)  {
                    FancyTextField(placeholder: placeholder!, lineLimit: 1, onSubmit: onSubmit, transparent: true, disabled: disabled, font: .title3, text: $text)
                        .padding(.leading, 35)
                        .focused($primaryTextFieldInFocus)
                        .onAppear {
                            // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.primaryTextFieldInFocus = true
                            }
                        }

                    HStack(alignment: .center) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(self.state.session.job?.backgroundColor ?? .yellow)
                        Spacer()
                        if self.text.count > 0 {
                            UI.Buttons.Close(action: self.actionOnReset)
                        } else {
                            FancyButtonv2(
                                text: "Entities",
                                action: {self.showingTypes.toggle()},
                                icon: self.showingTypes ? "arrow.up.square.fill" : "arrow.down.square.fill",
                                showLabel: false,
                                type: .clear,
                                font: .title2
                            )
                            .frame(width: 18)
                            .help("Choose the entities you want to search")
                        }
                    }
                    .padding([.leading, .trailing])
                }
                .frame(height: 57)
                .background(Theme.textBackground)
                .onAppear(perform: self.actionOnAppear)
            }
        }

        // MARK: ResourcePath
        struct ResourcePath: View {
            @EnvironmentObject public var state: Navigation
            public var company: Company?
            public var project: Project?
            public var job: Job?
            public var showRoot: Bool = false

            var body: some View {
                HStack(alignment: .center, spacing: 0) {
                    ZStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 8) {
                            HStack(spacing: 0) {
                                if self.showRoot {
                                    Button {
                                        self.state.session.company = nil
                                        self.state.session.project = nil
                                        self.state.session.job = nil
                                    } label: {
                                        Image(systemName: "house.fill")
                                            .padding([.top, .bottom], 7)
                                            .padding([.leading, .trailing], 4)
                                            .background(Theme.lightBase)
                                            .foregroundStyle(self.company == nil ? Theme.lightWhite : self.state.theme.tint)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(self.company == nil)
                                    .useDefaultHover({ _ in})

                                    Image(systemName: "chevron.right")
                                        .padding([.top, .bottom], 8)
                                        .padding([.leading, .trailing], 4)
                                        .background(Theme.lightBase)
                                        .foregroundStyle(Theme.lightWhite)
                                }

                                if let abbreviation = self.company?.abbreviation {
                                    Text(abbreviation)
                                        .padding(7)
                                        .background(self.company?.backgroundColor ?? Theme.base)
                                        .foregroundStyle((self.company?.backgroundColor.isBright() ?? false) ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                                    Image(systemName: "chevron.right")
                                        .padding([.top, .bottom], 8)
                                        .padding([.leading, .trailing], 4)
                                        .background((self.company?.backgroundColor ?? Theme.base).opacity(0.9))
                                        .foregroundStyle((self.company?.backgroundColor  ?? Theme.base).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                                }

                                if let abbreviation = self.project?.abbreviation {
                                    Text(abbreviation)
                                        .padding(7)
                                        .background(self.project?.backgroundColor ?? Theme.base)
                                        .foregroundStyle((self.project?.backgroundColor ?? Theme.base).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                                    Image(systemName: "chevron.right")
                                        .padding([.top, .bottom], 8)
                                        .padding([.leading, .trailing], 4)
                                        .background((self.project?.backgroundColor ?? Theme.base).opacity(0.9))
                                        .foregroundStyle((self.project?.backgroundColor ?? Theme.base).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                                }
                            }
                            .background(self.state.session.appPage.primaryColour)

                            Text("\(self.job?.title ?? self.job?.jid.string ?? "")")
                                .foregroundStyle((self.job?.backgroundColor ?? Theme.base).isBright() ? Theme.base : .white)
                            Spacer()
                        }
                        .foregroundStyle((self.project?.backgroundColor ?? .clear).isBright() ? Theme.base : .white)
                    }
                }
                .frame(height: 30)
                .background(self.job?.backgroundColor ?? .clear)
            }
        }

        struct Toggle: View {
            public var title: String? = nil
            @Binding public var isOn: Bool
            public var eType: PageConfiguration.EntityType? = .BruceWillis
            public var icon: String? = nil
            public var selectedIcon: String? = nil
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.isOn.toggle()
                } label: {
                    HStack(alignment: .center, spacing: 4) {
                        if let title = self.title {
                            Text(title)
                        }

                        if let icon = self.icon {
                            (self.isOn ? Image(systemName: self.selectedIcon ?? "xmark") : Image(systemName: icon))
                        } else {
                            (self.isOn ? self.eType?.selectedIcon : self.eType?.icon)
                        }
                    }
                    .foregroundStyle(self.isOn ? .yellow : .gray)
                    .padding(3)
                }
                .help(self.title ?? self.eType?.label ?? "")
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }

            init(_ title: String? = nil, isOn: Binding<Bool>, eType: PageConfiguration.EntityType? = .BruceWillis, icon: String? = nil, selectedIcon: String? = nil) {
                self.title = title
                self.eType = eType
                self.icon = icon
                self.selectedIcon = selectedIcon
                _isOn = isOn
            }
        }

        struct GroupHeaderContextMenu: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateCompany") private var shouldCreateCompany: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateProject") private var shouldCreateProject: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateJob") private var shouldCreateJob: Bool = false
            public let page: Page
            public let entity: NSManagedObject

            var body: some View {
                Button(action: self.actionEdit, label: {
                    Text("Edit...")
                })
                Divider()
                Menu("New") {
                    if [.companyDetail, .projectDetail].contains(where: {$0 == self.page}) {
                        Button(action: self.actionOnSecondaryTap, label: {
                            if self.page == .companyDetail {
                                Text("Project")
                            } else if self.page == .projectDetail {
                                Text("Job")
                            }
                        })
                    } else if self.page == .jobs {
                        Button(action: {self.state.to(.taskDetail)}, label: {
                            Text("Task...")
                        })
                        Button(action: {self.state.to(.today)}, label: {
                            Text("Record...")
                        })
                        Button(action: {self.state.to(.noteDetail)}, label: {
                            Text("Note...")
                        })
                        Button(action: {self.state.to(.definitionDetail)}, label: {
                            Text("Definition...")
                        })
                    }
                }
                Divider()
                Button(action: self.actionInspect, label: {
                    Text("Inspect")
                })
            }
        }

        struct InlineEntityCreate: View {
            public var label: String
            public var onCreateChild: (String) -> Void
            public var onAbortChild: () -> Void
            @State private var newEntityName: String = ""
            @FocusState private var newEntityFieldFocused: Bool

            var body: some View {
                HStack {
                    Image(systemName: "folder")
                        .padding([.leading, .top, .bottom])
                    FancyTextField(
                        placeholder: self.label,
                        onSubmit: {self.onCreateChild(self.newEntityName)},
                        transparent: true,
                        text: $newEntityName
                    )
                    .focused($newEntityFieldFocused)
                    .onAppear(perform: {self.newEntityFieldFocused = true})
                    .onDisappear(perform: {self.newEntityFieldFocused = false})
                    Spacer()
                    UI.Buttons.Close(action: self.onAbortChild)
                        .padding(.trailing)
                }
            }
        }

        struct KeyboardShortcutIndicator: View {
            public var character: String
            public var requireShift: Bool = false
            public var requireCmd: Bool = true

            var body: some View {
                HStack(alignment: .top, spacing: 2) {
                    if self.requireShift { Image(systemName: "arrowshape.up") }
                    if self.requireShift { Image(systemName: "command") }
                    Text(self.character)
                }
                .help("\(self.requireShift ? "Shift+" : "")\(self.requireCmd ? "Command+" : "")\(self.character)")
                .foregroundStyle(.white.opacity(0.55))
                .font(.caption)
                .padding(3)
                .background(.white.opacity(0.4).blendMode(.softLight))
                .clipShape(.rect(cornerRadius: 4))
            }
        }

        struct RowActionButton: View {
            @EnvironmentObject public var state: Navigation
            public var callback: (() -> Void)
            public var icon: String?
            public var iconAsImage: Image?
            public var helpText: String = ""
            public var highlightedColour: Color = .yellow
            public var page: PageConfiguration.AppPage = .explore
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.callback()
                } label: {
                    ZStack(alignment: .center) {
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .leading, endPoint: .trailing)
                        self.isHighlighted ? self.highlightedColour : self.state.session.appPage.primaryColour

                        if let icon = self.icon {
                            Image(systemName: icon)
                                .symbolRenderingMode(.hierarchical)
                                .padding(5)
                        } else if let iconAsImage = self.iconAsImage {
                            iconAsImage
                                .symbolRenderingMode(.hierarchical)
                                .padding(5)
                        }
                    }
                    .foregroundStyle(self.isHighlighted ? Theme.base : self.highlightedColour)
                }
                .font(.headline)
                .buttonStyle(.plain)
                .help(self.helpText)
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        struct Pagination: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
            public var entityCount: Int
            @State private var pages: [Page] = []

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    if self.entityCount > 0 && self.pages.count > 1 {
                        Main
                    }
                }
                .onAppear(perform: self.actionOnAppear)
            }

            var Main: some View {
                HStack(spacing: 1) {
                    Spacer()
                    Button {
                        if self.state.session.pagination.currentPageOffset > 0 {
                            self.state.session.pagination.currentPageOffset -= self.perPage
                        }
                    } label: {
                        Image(systemName: "chevron.left.chevron.left.dotted")
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({_ in})
                    .keyboardShortcut("[", modifiers: [.control, .shift])
                    .disabled(self.state.session.pagination.currentPageOffset == 0)

                    ForEach(self.pages, id: \.id) { page in
                        page
                    }

                    Button {
                        self.state.session.pagination.currentPageOffset += self.perPage
                    } label: {
                        Image(systemName: "chevron.right.dotted.chevron.right")
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({_ in})
                    .keyboardShortcut("]", modifiers: [.control, .shift])
                    Spacer()
                }
                .background(
                    ZStack(alignment: .top) {
                        self.state.session.appPage.primaryColour
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .opacity(0.4)
                            .frame(height: 15)
                    }
                )
            }

            struct Widget: View {
                @EnvironmentObject public var state: Navigation
                @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
                @State private var isHighlighted: Bool = false
                private var pickerItems: [CustomPickerItem] {
                    return [
                        CustomPickerItem(title: "Pagination", tag: 0),
                        CustomPickerItem(title: "10 per page", tag: 10),
                        CustomPickerItem(title: "30 per page", tag: 30),
                        CustomPickerItem(title: "50 per page", tag: 50)
                    ]
                }

                var body: some View {
                    HStack(spacing: 5) {
                        FancyPicker(onChange: change, items: self.pickerItems, defaultSelected: self.perPage, icon: "square.grid.3x3")
                            .onAppear(perform: {self.change(selected: self.perPage, sender: "")})
                            .onChange(of: self.perPage) {
                                change(selected: self.perPage, sender: "")
                            }
                    }
                    .padding(6)
                    .background(self.isHighlighted ? Theme.textBackground.opacity(1) : Theme.textBackground.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                }
            }

            struct Page: View, Identifiable {
                @EnvironmentObject public var state: Navigation
                @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
                public var id: UUID = UUID()
                public var index: Int
                public var value: String
                @State private var isHighlighted: Bool = false
                @State private var isCurrent: Bool = false

                var body: some View {
                    Button {
                        self.state.session.pagination.currentPageOffset = self.index * self.perPage
                    } label: {
                        ZStack(alignment: .center) {
                            if self.isCurrent {
                                Circle()
                                    .fill(self.isHighlighted ? self.state.theme.tint.opacity(1) : self.state.theme.tint.opacity(0.8))
                                    .frame(width: 20)
                            } else {
                                (self.isHighlighted ? Theme.textBackground.opacity(1) : Theme.textBackground.opacity(0))
                            }
                            Text(self.value)
                                .padding(8)
                                .foregroundStyle(self.isCurrent ? Theme.base : .gray)
                        }
                        .frame(maxWidth: 35)
                        .useDefaultHover({ hover in self.isHighlighted = hover })
                    }
                    .buttonStyle(.plain)
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.state.session.pagination.currentPageOffset) { self.actionOnAppear() }
                }
            }
        }

        struct SortSelector: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
            @State private var isHighlighted: Bool = false
            private var pickerItems: [CustomPickerItem] {
                return [
                    CustomPickerItem(title: "Sort", tag: -1),
                    CustomPickerItem(title: "Newest first", tag: 0),
                    CustomPickerItem(title: "Oldest first", tag: 1)
                ]
            }

            var body: some View {
                HStack(spacing: 5) {
                    FancyPicker(onChange: change, items: self.pickerItems, defaultSelected: self.tableSortOrder, icon: "arrow.up.arrow.down")
                        .onAppear(perform: {self.change(selected: self.tableSortOrder, sender: "")})
                        .onChange(of: self.tableSortOrder) {
                            change(selected: self.tableSortOrder, sender: "")
                        }
                }
                .padding(6)
                .background(self.isHighlighted ? Theme.textBackground.opacity(1) : Theme.textBackground.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        public struct ViewModeSelector: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.viewMode") public var index: Int = 0
            private var items: [CustomPickerItem] {
                return [
                    CustomPickerItem(title: "View mode", tag: 0),
                    CustomPickerItem(title: "Full", tag: 1),
                    CustomPickerItem(title: "Plain", tag: 2)
                ]
            }

            public var body: some View {
                FancyPicker(onChange: change, items: items, defaultSelected: index, icon: self.index == 1 ? "rectangle.pattern.checkered" : "rectangle")
                    .onAppear(perform: {self.change(selected: index, sender: "")})
                    .onChange(of: self.index) {
                        change(selected: self.index, sender: "")
                    }
            }

            private func change(selected: Int, sender: String?) -> Void {
                if selected == 1 || selected == 0 {
                    self.state.session.toolbar.mode = .full
                } else if selected == 2 {
                    self.state.session.toolbar.mode = .plain
                }

                index = selected
            }
        }
    }
}

extension WidgetLibrary.UI.SortSelector {
    /// Fires when number of records per-page selector is changed
    /// - Parameters:
    ///   - selected: Int
    ///   - sender: String
    /// - Returns: Void
    private func change(selected: Int, sender: String?) -> Void {
        if selected > -1 {
            self.tableSortOrder = selected
        }
    }
}


extension WidgetLibrary.UI.Pagination {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.perPage == 0 {
            self.pages = []
            return
        }

        let numPages = self.entityCount/self.perPage

        if numPages > 0 {
            for page in 0..<numPages {
                self.pages.append(
                    Page(
                        index: page,
                        value: String(page + 1)
                    )
                )
            }
        }
    }
}

extension WidgetLibrary.UI.Pagination.Widget {
    /// Fires when number of records per-page selector is changed
    /// - Parameters:
    ///   - selected: Int
    ///   - sender: String
    /// - Returns: Void
    private func change(selected: Int, sender: String?) -> Void {
        if selected > 0 {
            self.perPage = selected
        }
    }
}

extension WidgetLibrary.UI.Pagination.Page {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.isCurrent = (self.state.session.pagination.currentPageOffset/self.perPage) == self.index
    }
}

extension WidgetLibrary.UI.GroupHeaderContextMenu {
    /// Navigate to an edit page
    /// - Returns: Void
    private func actionEdit() -> Void {
        switch self.page {
        case .recordDetail:
            self.state.session.record = self.entity as? LogRecord
        case .jobs:
            self.state.session.job = self.entity as? Job
        case .companyDetail:
            self.state.session.company = self.entity as? Company
        case .projectDetail:
            self.state.session.project = self.entity as? Project
        case .definitionDetail:
            self.state.session.definition = self.entity as? TaxonomyTermDefinitions
        case .taskDetail:
            self.state.session.task = self.entity as? LogTask
        case .noteDetail:
            self.state.session.note = self.entity as? Note
        case .peopleDetail:
            self.state.session.person = self.entity as? Person
        default:
            print("noop")
        }
        self.state.to(self.page)
    }

    /// Inspect an entity
    /// - Returns: Void
    private func actionInspect() -> Void {
        self.state.session.search.inspectingEntity = self.entity
        self.state.setInspector(AnyView(Inspector(entity: self.entity)))
    }
    
    /// Fires when each row is right clicked
    /// - Returns: Void
    private func actionOnSecondaryTap() -> Void {
        switch self.entity {
        case is Company:
            self.state.session.company = self.entity as? Company
            self.state.session.company?.addToProjects(
                CoreDataProjects(moc: self.state.moc).createAndReturn(
                    name: "EDIT ME",
                    abbreviation: "EM",
                    colour: Color.randomStorable(),
                    created: Date(),
                    company: self.state.session.company,
                    saveByDefault: false
                )
            )
            self.shouldCreateProject = true
        case is Project:
            self.state.session.project = self.entity as? Project
            self.state.session.project?.addToJobs(
                CoreDataJob(moc: self.state.moc).createAndReturn(
                    alive: true,
                    colour: Color.randomStorable(),
                    jid: 1.0,
                    overview: "",
                    shredable: false,
                    title: "EDIT ME",
                    uri: "",
                    saveByDefault: false
                )
            )
            self.shouldCreateJob = true
        case is Job:
            self.state.session.job = self.entity as? Job
        default:
            print("Noop")
        }
    }
}

extension WidgetLibrary.UI.LinkList {
    /// Onload handler. Starts monitoring keyboard for esc key
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.links = []
        let savedSearchTerms = CDSavedSearch(moc: self.state.moc).all()

        for link in self.state.session.search.history {
            if !savedSearchTerms.contains(where: {$0.term == link}) {
                self.links.insert(
                    WidgetLibrary.UI.Link(label: link, column: .recent)
                )
            }
        }

        for link in savedSearchTerms {
            self.links.insert(
                WidgetLibrary.UI.Link(label: link.term!, column: .saved, date: link.created ?? Date.now)
            )
        }
    }
    
    /// Fires when a link is tapped on
    /// - Returns: Void
    private func actionOnTap(searchText: String) -> Void {
        self.state.session.search.text = searchText
    }
}

extension WidgetLibrary.UI.BoundSearchBar {
    /// Onload handler. Starts monitoring keyboard for esc key
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.text = self.state.session.search.text ?? ""
    }

    /// Reset field text
    /// - Returns: Void
    private func actionOnReset() -> Void {
        self.text = ""

        if onReset != nil {
            onReset!()
        }
    }
}

extension WidgetLibrary.UI.SearchBar {
    /// Onload handler. Starts monitoring keyboard for esc key
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.searchText = self.state.session.search.text ?? ""
    }

    /// Reset field text
    /// - Returns: Void
    private func actionOnReset() -> Void {
        self.searchText = ""

        if onReset != nil {
            onReset!()
        }
    }
}

extension WidgetLibrary.UI.FlashcardActivity.FlashcardDeck {
    /// Onload/onChangeJob handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.isAnswerCardShowing = false
        self.terms = []
        self.definitions = []
        self.current = nil
        self.clue = ""

        if self.job != nil {
            if let termsForJob = CoreDataTaxonomyTerms(moc: self.state.moc).byJob(self.job!) {
                self.terms = termsForJob
            }
        }

        if !self.terms.isEmpty {
            self.current = self.terms.randomElement()
            self.clue = self.current?.name ?? "_TERM_NAME"
            self.viewed.insert(self.current!)
//            self.definitions = []

            if let defs = self.current!.definitions {
                if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                    self.definitions = ttds
                }
            }
        }
    }
}

extension WidgetLibrary.UI.ActivityCalendar {
    /// Get month string from date
    /// - Returns: Void
    private func actionChangeDate() -> Void {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: self.date)
        self.state.session.date = DateHelper.startOfDay(self.date)
    }

    /// Onload handler. Used by DatePicker, should be AppState.date by default
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.date = self.state.session.date
    }
}


extension WidgetLibrary.UI.EntityStatistics {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        let types = PageConfiguration.EntityType.allCases.filter({ ![.BruceWillis, .definitions].contains($0) })

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
        case .notes: self.count = CoreDataNotes(moc: self.state.moc).countAll()
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

extension WidgetLibrary.UI.Meetings {
    private func actionOnAppear() -> Void {
        if let chosenCalendar = ce.selectedCalendar() {
            calendarName = chosenCalendar
            upcomingEvents = ce.events(chosenCalendar).filter {$0.startDate > Date()}
        }

        if let statement = WidgetLibrary.UI.celebratoryStatements.randomElement() {
            self.randomCelebratoryStatement = statement
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
