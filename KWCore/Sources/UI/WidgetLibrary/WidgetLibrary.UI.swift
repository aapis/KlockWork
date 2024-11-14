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

        struct AppFooter: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.appfooter.isMinimized") private var isMinimized: Bool = false
            public var period: UI.Explore.Visualization.Timeline.TimelineTab = .day
            public var start: Date?
            public var end: Date?
            public var format: String = "MMMM dd"
            private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    ZStack(alignment: .topTrailing) {
                        if !self.isMinimized {
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                .blendMode(.softLight)
                        } else {
                            Theme.base.blendMode(.softLight)
                        }
                        LazyVGrid(columns: self.twoCol, alignment: .leading, spacing: 10) {
                            GridRow {
                                // @TODO: implement UI.SuggestedStack in place of SuggestedLinksInRange when it gets fixed
//                                UI.SuggestedStack(
//                                    period: self.period,
//                                    start: self.start ?? self.state.session.date.startOfDay,
//                                    end: self.end ?? self.state.session.date.endOfDay,
//                                    format: self.format
//                                )
                                UI.SuggestedLinksInRange(
                                    period: self.period,
                                    start: self.start ?? self.state.session.date.startOfDay,
                                    end: self.end ?? self.state.session.date.endOfDay,
                                    format: self.format,
                                    useMiniMode: self.isMinimized
                                )
                                .frame(height: self.isMinimized ? 50 : 200)
                                UI.InteractionsInRange(
                                    period: self.period,
                                    start: self.start ?? self.state.session.date.startOfDay,
                                    end: self.end ?? self.state.session.date.endOfDay,
                                    format: self.format,
                                    useMiniMode: self.isMinimized
                                )
                                .frame(height: self.isMinimized ? 50 : 200)
                            }
                        }
                        .padding()
                        HStack {
                            Spacer()
                            UI.Buttons.Minimize(isMinimized: $isMinimized)
                                .padding([.trailing, .top], 8)
                        }
                    }
                }
                .frame(height: self.isMinimized ? 50 : 200)
                .padding(.bottom, self.isMinimized ? 0 : 8)
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
                HStack(alignment: .center, spacing: 0) {
                    FancyButtonv2(
                        text: "Previous month",
                        action: {self.state.session.date -= 86400*30},
                        icon: "chevron.left.chevron.left.dotted",
                        fgColour: .gray,
                        highlightColour: .white,
                        showLabel: false,
                        size: .titleLink,
                        type: .titleLink
                    )
                    .help("Previous month")
                    .frame(height: 20)
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
                    FancyButtonv2(
                        text: "Next month",
                        action: {self.state.session.date += 86400*30},
                        icon: "chevron.right.dotted.chevron.right",
                        fgColour: .gray,
                        highlightColour: .white,
                        showLabel: false,
                        size: .titleLink,
                        type: .titleLink
                    )
                    .help("Next month")
                    .frame(height: 20)
                }
                .padding(12)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnChangeDate() }
                .onChange(of: self.sDate) { self.state.session.date = self.sDate }
            }
        }

        struct ListExternalLinkItem: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("general.shouldCheckLinkStatus") private var shouldCheckLinkStatus: Bool = false
            public var name: String
            public var icon: String?
            public var iconAsImage: Image?
            public var activity: Activity
            @State private var isHighlighted: Bool = false
            @State private var isMinimized: Bool = true
            @State private var isLinkOnline: Bool = false

            var body: some View {
                HStack(alignment: .top) {
                    UI.Buttons.Minimize(isMinimized: $isMinimized)

                    VStack(alignment: .leading, spacing: 1) {
                        if let url = self.activity.url {
                            SwiftUI.Link(destination: url, label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .center) {
                                        if let image = self.iconAsImage {
                                            image
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(self.state.session.job?.backgroundColor ?? self.state.theme.tint)
                                        } else if let icon = self.icon {
                                            Image(systemName: icon)
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(self.state.session.job?.backgroundColor ?? self.state.theme.tint)
                                        }
                                        Text(self.name)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        Image(systemName: self.shouldCheckLinkStatus ? self.isLinkOnline ? "link" : "questionmark.square.fill" : "link")
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(8)
                                }
                                .buttonStyle(.plain)
                                .useDefaultHover({ hover in self.isHighlighted = hover })
                            })
                            .foregroundStyle(.white)
                            .background(self.shouldCheckLinkStatus ? self.isLinkOnline ? .clear : Color.red.opacity(0.3) : .clear)
                        }
                        if !self.isMinimized {
                            if self.activity.source != nil {
                                HStack(alignment: .top) {
                                    switch self.activity.source {
                                    case is NoteVersion:
                                        let entity = self.activity.source as? NoteVersion
                                        Text("Found in note \"\(entity?.note?.title ?? "Error: Note not found")\" at \(DateHelper.todayShort(entity?.created ?? Date.now, format: "HH:mm"))")
                                            .foregroundStyle(.gray)
                                        Spacer()
                                        UI.Buttons.SmallOpen(callback: {
                                            if let entity = self.activity.source as? NoteVersion {
                                                self.state.to(.noteDetail)
                                                self.state.session.note = entity.note
                                            }
                                        })
                                    case is LogRecord:
                                        let entity = self.activity.source as? LogRecord
                                        Text("Found in record \"\(entity?.message ?? "Error: Record not found")\" at \(DateHelper.todayShort(entity?.timestamp ?? Date.now, format: "HH:mm"))")
                                            .foregroundStyle(.gray)
                                        Spacer()
                                        UI.Buttons.SmallOpen(callback: {
                                            if let entity = self.activity.source as? LogRecord {
                                                if let created = entity.timestamp {
                                                    self.state.to(.today)
                                                    self.state.session.date = created
                                                }
                                            }
                                        })
                                    default:
                                        Text("No source found")
                                    }
                                }
                                .padding(8)
                            }

                            if let job = self.activity.job {
                                ResourcePath(
                                    company: job.project?.company,
                                    project: job.project,
                                    job: job
                                )
                            }
                        }
                    }
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.shouldCheckLinkStatus) { self.actionOnAppear() }
                    .contextMenu { ContextMenu(activity: self.activity) }
                    .background(.white.opacity(self.isHighlighted ? 0.07 : 0.03))
                    .clipShape(.rect(cornerRadius: 5))
                    .help(self.isLinkOnline ? self.activity.help : "Error: The website appears to be down.")
                }
            }

            // MARK: ListExternalItem.ContextMenu
            struct ContextMenu: View {
                public let activity: Activity

                var body: some View {
                    if let url = self.activity.url {
                        Button("Copy to clipboard", action: {
                            ClipboardHelper.copy(url.absoluteString)
                        })
                    }
                }
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
                                .foregroundStyle(self.state.theme.tint)
                        } else if let icon = self.icon {
                            Image(systemName: icon)
                                .foregroundStyle(self.state.theme.tint)
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
                                .foregroundStyle(self.state.theme.tint)
                        } else if let icon = self.icon {
                            Image(systemName: icon)
                                .foregroundStyle(self.state.theme.tint)
                        }
                        Text(self.name)
                            .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                        Spacer()
                        if let actionIcon = self.actionIcon {
                            Image(systemName: actionIcon)
                                .foregroundStyle(self.state.theme.tint)
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
                HStack(alignment: .center) {
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
            }
        }

        struct EntityStatistics: View {
            @EnvironmentObject private var state: Navigation
            @State private var statistics: [Statistic] = []

            var body: some View {
                VStack(spacing: 0) {
                    ListLinkTitle(text: "Overview")
                        .padding(.bottom, 5)
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

        // MARK: ActivityLinks
        struct ActivityLinks: View {
            @EnvironmentObject private var state: Navigation
            public var start: Date?
            public var end: Date?
            @State private var activities: [Activity] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 5) {
                        if self.activities.count > 0 {
                            ForEach(self.activities, id: \.id) { activity in
                                UI.ListExternalLinkItem(
                                    name: activity.name,
                                    icon: activity.icon,
                                    activity: activity
                                )
                            }
                        } else {
                            UI.ListButtonItem(
                                callback: {_ in},
                                name: "None found for \(DateHelper.todayShort(self.state.session.timeline.date ?? self.state.session.date, format: "yyyy"))"
                            )
                            .disabled(true)
                        }
                    }
                }
                .id(self.vid)
                .frame(maxHeight: 200)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
            }
        }

        // MARK: ExploreLinks
        struct ExploreLinks: View {
            @EnvironmentObject private var state: Navigation
            private var activities: [Activity] {
                [
                    Activity(name: "Activity Calendar", page: .activityCalendar, type: .visualize, icon: "calendar"),
                    Activity(name: "Timeline", page: .timeline, type: .visualize, icon: "moonphase.waxing.crescent"),
                    Activity(name: "Flashcards", page: .activityFlashcards, type: .activity, icon: "person.text.rectangle")
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
                                    .help(activity.help)
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
                                                Button("Remove") {
                                                    CDSavedSearch(moc: self.state.moc).unpublish(link.label)
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

        // MARK: SuggestedStack
        struct SuggestedStack: View {
            @EnvironmentObject private var state: Navigation
            public var period: UI.Explore.Visualization.Timeline.TimelineTab? = nil
            public var start: Date?
            public var end: Date?
            public var format: String?
            @State private var activities: [Activity] = []
            @State private var tabs: [ToolbarButton] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                VStack {
                    UI.ListLinkTitle(text: "Suggested items from \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))")
                    FancyGenericToolbar(
                        buttons: self.tabs,
                        standalone: true,
                        location: .content,
                        mode: .compact,
                        page: self.state.session.appPage,
                        alwaysShowTab: true
                    )
                    Spacer()
                }
                .id(self.vid)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.date) { self.actionOnAppear() }
            }
        }

        // MARK: SuggestedLinksInRange
        struct SuggestedLinksInRange: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showProjects") public var showProjects: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showJobs") public var showJobs: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showCompanies") public var showCompanies: Bool = true
            public var period: UI.Explore.Visualization.Timeline.TimelineTab
            public var start: Date?
            public var end: Date?
            public var format: String?
            public var useMiniMode: Bool = false
            @State private var activities: [Activity] = []
            @State private var tabs: [ToolbarButton] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                VStack {
                    if !self.useMiniMode {
                        UI.ListLinkTitle(text: "Suggested links from \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))")
                        UI.ActivityLinks(start: self.start, end: self.end)
                    } else {
                        UI.Buttons.FooterActivity(count: self.activities.count, label: "Links", icon: "link")
                    }
                    Spacer()
                }
                .id(self.vid)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.date) { self.actionOnAppear() }
                .onChange(of: self.state.saved) {
                    if self.state.saved {
                        self.actionOnAppear()
                    }
                }
            }
        }

        // MARK: SavedSearchTermsInRange
        struct SavedSearchTermsInRange: View {
            @EnvironmentObject private var state: Navigation
            public var period: UI.Explore.Visualization.Timeline.TimelineTab
            public var start: Date?
            public var end: Date?
            public var format: String?
            @State private var vid: UUID = UUID()

            var body: some View {
                VStack {
                    UI.ListLinkTitle(text: "Search terms saved in \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))")
                    SavedSearchTermLinks(
                        period: self.period,
                        start: self.start,
                        end: self.end,
                        format: self.format
                    )
                    Spacer()
                }
            }
        }

        // MARK: SavedSearchTermLinks
        struct SavedSearchTermLinks: View {
            @EnvironmentObject private var state: Navigation
            public var period: UI.Explore.Visualization.Timeline.TimelineTab? = nil
            public var start: Date?
            public var end: Date?
            public var format: String?
            @State private var terms: [SavedSearch] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 5) {
                        if self.terms.count > 0 {
                            ForEach(self.terms, id: \.id) { savedSearch in
                                UI.Buttons.SavedSearchTerm(savedSearch: savedSearch)
                            }
                        } else {
                            UI.ListButtonItem(
                                callback: {_ in},
                                name: "None found for \(DateHelper.todayShort(self.state.session.date, format: "yyyy"))"
                            )
                            .disabled(true)
                        }
                        Spacer()
                    }
                }
                .id(self.vid)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.date) { self.actionOnAppear() }
            }
        }

        // MARK: InteractionsInRange
        struct InteractionsInRange: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showProjects") public var showProjects: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showJobs") public var showJobs: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showCompanies") public var showCompanies: Bool = true
            public var period: UI.Explore.Visualization.Timeline.TimelineTab
            public var start: Date?
            public var end: Date?
            public var format: String?
            public var useMiniMode: Bool = false
            @State private var tabs: [ToolbarButton] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                VStack {
                    if !self.useMiniMode {
                        UI.ListLinkTitle(text: "Interactions from \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))")
                        FancyGenericToolbar(
                            buttons: self.tabs,
                            standalone: true,
                            location: .content,
                            mode: .compact,
                            page: self.state.session.appPage,
                            alwaysShowTab: true
                        )
                    }
                    Spacer()
                }
                .id(self.vid)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.vid = UUID() ; self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.date) { self.vid = UUID() ; self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.custom.rangeStart) { self.vid = UUID() ; self.actionOnAppear() }
                .onChange(of: self.state.session.timeline.custom.rangeEnd) { self.vid = UUID() ; self.actionOnAppear() }
                .onChange(of: self.showCompanies) { self.actionOnAppear() }
                .onChange(of: self.showProjects) { self.actionOnAppear() }
                .onChange(of: self.showJobs) { self.actionOnAppear() }
            }
        }

        // MARK: ActivityFeed
        struct ActivityFeed: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
            @State private var tabs: [ToolbarButton] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                VStack {
                    UI.ListLinkTitle(text: "Activity Feed")
                    FancyGenericToolbar(
                        buttons: self.tabs,
                        standalone: true,
                        location: .content,
                        mode: .full,
                        page: self.state.session.appPage
                    )
                    Spacer()
                }
                .id(self.vid)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
                .onChange(of: self.maxYearsPastInHistory) { self.actionOnAppear() }
                .onChange(of: self.state.session.pagination.currentPageOffset) { self.actionOnAppear() }
            }
        }

        // MARK: GenericTimelineActivity
        struct GenericTimelineActivity: View, Identifiable, Equatable {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.jobs.showPublished") private var allowAlive: Bool = true
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
            @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showRecords") public var showRecords: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showNotes") public var showNotes: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTasks") public var showTasks: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showProjects") public var showProjects: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showJobs") public var showJobs: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showCompanies") public var showCompanies: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showPeople") public var showPeople: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTerms") public var showTerms: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showDefinitions") public var showDefinitions: Bool = true
            public var id: UUID = UUID()
            public var historicalDate: Date
            public var view: AnyView?
            @State private var activities: [GenericTimelineActivity] = []
            @State private var currentActivities: [GenericTimelineActivity] = []
            @State private var vid: UUID = UUID()

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ToolbarButtons()
                        if self.activities.count > 0 {
                            ForEach(self.currentActivities) { activity in
                                if let view = activity.view {
                                    view
                                }
                            }
                            UI.Pagination(entityCount: self.activities.count)
                        } else {
                            LogRowEmpty(
                                message: "No activities found for \(DateHelper.todayShort(self.historicalDate, format: "MMMM dd, YYYY"))",
                                index: 0,
                                colour: Theme.rowColour
                            )
                        }
                    }
                }
                .id(self.vid)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.tableSortOrder) { self.actionOnAppear() }
                .onChange(of: self.perPage) { self.actionOnAppear() }
                .onChange(of: self.state.session.pagination.currentPageOffset) { self.actionOnAppear() }
                .onChange(of: self.showRecords) { self.actionOnAppear() }
                .onChange(of: self.showNotes) { self.actionOnAppear() }
                .onChange(of: self.showTasks) { self.actionOnAppear() }
                .onChange(of: self.showProjects) { self.actionOnAppear() }
                .onChange(of: self.showJobs) { self.actionOnAppear() }
                .onChange(of: self.showCompanies) { self.actionOnAppear() }
                .onChange(of: self.showPeople) { self.actionOnAppear() }
                .onChange(of: self.showTerms) { self.actionOnAppear() }
                .onChange(of: self.showDefinitions) { self.actionOnAppear() }
            }
        }

        // MARK: BoundSearchTypeFilter
        struct BoundSearchTypeFilter: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.jobs.showPublished") private var allowAlive: Bool = true
            @Binding public var showRecords: Bool
            @Binding public var showNotes: Bool
            @Binding public var showTasks: Bool
            @Binding public var showProjects: Bool
            @Binding public var showJobs: Bool
            @Binding public var showCompanies: Bool
            @Binding public var showPeople: Bool
            @Binding public var showTerms: Bool
            @Binding public var showDefinitions: Bool

            var body: some View {
                GridRow {
                    ZStack(alignment: .topLeading) {
                        self.state.parent?.appPage.primaryColour.opacity(0.6) ?? Theme.subHeaderColour
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .opacity(0.4)
                            .frame(height: 15)

                        HStack(alignment: .center) {
                            UI.Toggle(isOn: $showRecords, eType: .records)
                            UI.Toggle(isOn: $showNotes, eType: .notes)
                            UI.Toggle(isOn: $showTasks, eType: .tasks)
                            UI.Toggle(isOn: $showProjects, eType: .projects)
                            UI.Toggle(isOn: $showJobs, eType: .jobs)
                            UI.Toggle(isOn: $showCompanies, eType: .companies)
                            UI.Toggle(isOn: $showPeople, eType: .people)
                            UI.Toggle(isOn: $showTerms, eType: .terms)
                            Spacer()
                            UI.Toggle(isOn: $allowAlive, icon: "heart", selectedIcon: "heart.fill")
                                .help("Published only")
                        }
                        .padding(.top, 8)
                        .padding([.leading, .trailing], 10)
                    }
                }
                .frame(height: 40)
                .foregroundStyle(.gray)
            }
        }

        // MARK: SearchTypeFilter
        struct SearchTypeFilter: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.jobs.showPublished") private var allowAlive: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showRecords") public var showRecords: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showNotes") public var showNotes: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTasks") public var showTasks: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showProjects") public var showProjects: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showJobs") public var showJobs: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showCompanies") public var showCompanies: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showPeople") public var showPeople: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTerms") public var showTerms: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showDefinitions") public var showDefinitions: Bool = true

            var body: some View {
                GridRow {
                    ZStack(alignment: .topLeading) {
                        self.state.parent?.appPage.primaryColour.opacity(0.6) ?? Theme.subHeaderColour
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .opacity(0.4)
                            .frame(height: 15)

                        HStack(alignment: .center) {
                            UI.Toggle(isOn: $showRecords, eType: .records)
                            UI.Toggle(isOn: $showNotes, eType: .notes)
                            UI.Toggle(isOn: $showTasks, eType: .tasks)
                            UI.Toggle(isOn: $showProjects, eType: .projects)
                            UI.Toggle(isOn: $showJobs, eType: .jobs)
                            UI.Toggle(isOn: $showCompanies, eType: .companies)
                            UI.Toggle(isOn: $showPeople, eType: .people)
                            UI.Toggle(isOn: $showTerms, eType: .terms)
                            Spacer()
                            UI.Toggle(isOn: $allowAlive, icon: "heart", selectedIcon: "heart.fill")
                                .help("Published only")
                        }
                        .padding(.top, 8)
                        .padding([.leading, .trailing], 10)
                    }
                }
                .frame(height: 40)
                .foregroundStyle(.gray)
            }
        }

        // MARK: SearchBar
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
                            .foregroundStyle(self.state.theme.tint)
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
                                        .opacity(self.company == nil ? 0.5 : 1)
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

        // MARK: Toggle
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

        // MARK: GroupHeaderContextMenu
        struct GroupHeaderContextMenu: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateCompany") private var shouldCreateCompany: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateProject") private var shouldCreateProject: Bool = false
            @AppStorage("widgetlibrary.ui.unifiedsidebar.shouldCreateJob") private var shouldCreateJob: Bool = false
            public let page: Page
            public let entity: NSManagedObject

            var body: some View {
                Button(action: self.actionRedirectToEdit, label: {
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
                if self.state.session.appPage == .planning {
                    Divider()
                    Button("Add to Plan", action: self.actionEdit)
                }
                Divider()
                Button(action: self.actionInspect, label: {
                    Text("Inspect")
                })
            }
        }

        // MARK: InlineEntityCreate
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

        // MARK: KeyboardShortcutIndicator
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

        // MARK: Pagination
        struct Pagination: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widgetlibrary.ui.pagination.perpage") public var perPage: Int = 10
            public var entityCount: Int
            @State private var pages: [Page] = []

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    if self.entityCount > 0 && self.pages.count > 0 {
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
                @State private var menuLabel: String = ""
                @State private var selected: MenuOption? = nil
                private var options: [MenuOption] {
                    [
                        MenuOption(label: "5 per page", tag: 5, icon: "circle.grid.2x1.fill"),
                        MenuOption(label: "10 per page", tag: 10, icon: "circle.grid.2x1.fill"),
                        MenuOption(label: "20 per page", tag: 20, icon: "circle.grid.2x1.fill"),
                        MenuOption(label: "30 per page", tag: 30, icon: "circle.grid.2x2.fill"),
                        MenuOption(label: "50 per page", tag: 50, icon: "circle.grid.2x2.fill"),
                        MenuOption(label: "100 per page", tag: 100, icon: "circle.grid.3x3.fill"),
                    ]
                }

                var body: some View {
                    HStack(spacing: 8) {
                        HStack(alignment: .center) {
                            Image(systemName: self.options.filter({$0.tag == self.perPage}).first?.icon ?? "")
                                .foregroundStyle(self.state.theme.tint)
                            Menu(self.selected?.label ?? self.options.filter({$0.tag == self.perPage}).first?.label ?? "Pagination") {
                                ForEach(self.options) { option in
                                    Button {
                                        self.perPage = option.tag
                                        self.selected = option
                                    } label: {
                                        HStack {
                                            Image(systemName: option.icon)
                                            Text(option.label)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .useDefaultHover({ hover in self.isHighlighted = hover })
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                        }
                        .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                    }
                    .padding(8)
                    .background(self.isHighlighted ? Theme.textBackground.opacity(1) : Theme.textBackground.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .onAppear(perform: {self.change(selected: self.perPage, sender: "")})
                    .onChange(of: self.perPage) {
                        change(selected: self.perPage, sender: "")
                    }
                    .help("Number of records per page. 10, 30, 50, or 100.")
                }

                // MARK: Pagination.Widget.MenuOption
                internal struct MenuOption: Identifiable {
                    var id: UUID = UUID()
                    var label: String
                    var tag: Int
                    var icon: String
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

        // MARK: SortSelector
        struct SortSelector: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.tableSortOrder") private var tableSortOrder: Int = 0
            @State private var isHighlighted: Bool = false

            var body: some View {
                HStack(spacing: 5) {
                    HStack(alignment: .center) {
                        Image(systemName: self.tableSortOrder == 1 ? "text.line.last.and.arrowtriangle.forward" : "text.line.first.and.arrowtriangle.forward")
                            .foregroundStyle(self.state.theme.tint)
                        Menu(self.tableSortOrder == 0 ? "Newest first" : "Oldest first") {
                            Button {
                                self.tableSortOrder = 0
                            } label: {
                                HStack {
                                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                                    Text("Newest first")
                                }
                            }
                            Button {
                                self.tableSortOrder = 1
                            } label: {
                                HStack {
                                    Image(systemName: "text.line.last.and.arrowtriangle.forward")
                                    Text("Oldest first")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({ hover in self.isHighlighted = hover })
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                    .onAppear(perform: {self.change(selected: self.tableSortOrder, sender: "")})
                    .onChange(of: self.tableSortOrder) {
                        change(selected: self.tableSortOrder, sender: "")
                    }
                    .help("Change table sort order (newest or oldest first)")
                }
                .padding(6)
                .background(self.isHighlighted ? Theme.textBackground.opacity(1) : Theme.textBackground.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        // MARK: ViewModeSelector
        public struct ViewModeSelector: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.viewMode") public var index: Int = 0
            @State private var isHighlighted: Bool = false

            public var body: some View {
                HStack(alignment: .center) {
                    Image(systemName: self.state.session.toolbar.mode == .full ? "rectangle.pattern.checkered" : "rectangle")
                        .foregroundStyle(self.state.theme.tint)
                    Menu(self.state.session.toolbar.mode == .full ? "Full" : "Plain") {
                        Button {
                            self.index = 1
                            self.state.session.toolbar.mode = .full
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.pattern.checkered")
                                Text("Full")
                            }
                        }
                        Button {
                            self.index = 2
                            self.state.session.toolbar.mode = .plain
                        } label: {
                            HStack {
                                Image(systemName: "rectangle")
                                Text("Plain")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                }
                .padding(6)
                .background(Theme.textBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                .onAppear(perform: {self.change(selected: index, sender: "")})
                .onChange(of: self.index) {
                    change(selected: self.index, sender: "")
                }
                .help("Change view mode. Tap to see options.")

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

        // MARK: RowAddButton
        struct RowAddButton: View {
            public var title: String = "Add"
            @Binding public var isPresented: Bool
            public var animationDuration: CGFloat = 0.1
            public var callback: (() -> Void)? = nil
#if os(macOS)
            @State private var isHighlighted: Bool = false
#endif

            var body: some View {
                Button {
                    withAnimation(.linear(duration: self.animationDuration)) {
                        self.isPresented.toggle()
                        self.callback?()
                    }
                } label: {
                    ZStack(alignment: .center) {
                        RadialGradient(colors: [Theme.base, .clear], center: .center, startRadius: 0, endRadius: 40)
                            .blendMode(.softLight)
                            .opacity(0.8)
                        Text(self.title)
                            .font(.caption)
                            .padding(6)
                            .padding([.leading, .trailing], 8)
#if os(macOS)
                            .background(self.isHighlighted ? .white : .white.opacity(0.8))
#elseif os(iOS)
                            .background(self.isPresented ? .orange : .white)
#endif
                            .foregroundStyle(Theme.base)
                            .clipShape(.capsule(style: .continuous))
                    }
#if os(macOS)
                    .useDefaultHover({ hover in self.isHighlighted = hover })
#endif
                }
                .frame(width: 80)
                .buttonStyle(.plain)
            }
        }

        // MARK: RowAddNavLink
        struct RowAddNavLink: View {
            public var title: String = "Add"
            public let target: AnyView
#if os(macOS)
            @State private var isHighlighted: Bool = false
#endif

            var body: some View {
                NavigationLink {
                    self.target
                } label: {
                    ZStack(alignment: .center) {
                        RadialGradient(colors: [Theme.base, .clear], center: .center, startRadius: 0, endRadius: 40)
                            .blendMode(.softLight)
                            .opacity(0.8)
                        Text(self.title)
                            .font(.caption)
                            .padding(6)
                            .padding([.leading, .trailing], 8)
#if os(macOS)
                            .background(self.isHighlighted ? .white : .white.opacity(0.8))
#elseif os(iOS)
                            .background(.white)
#endif
                            .foregroundStyle(Theme.base)
                            .clipShape(.capsule(style: .continuous))
                    }
                }
                .frame(width: 90)
#if os(macOS)
                .useDefaultHover({ hover in self.isHighlighted = hover })
#endif
            }
        }

        struct SimpleEntityList: View {
            @EnvironmentObject private var state: Navigation
            public let type: EType
            public var start: Date?
            public var end: Date?
            @State private var entities: [SimpleEntityRow] = []

            var body: some View {
                VStack {
                    if self.entities.count > 0 {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(self.entities) { entity in entity }
                            }
                        }
                    } else {
                        UI.ListButtonItem(
                            callback: {_ in},
                            name: "None found for \(self.state.session.timeline.formatted())"
                        )
                        .disabled(true)
                    }
                }
                .onAppear(perform: self.actionOnAppear)
            }
        }

        // MARK: SimpleEntityRow
        struct SimpleEntityRow: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            public var id: UUID = UUID()
            public var entity: NSManagedObject
            @State private var isHighlighted: Bool = false

            var body: some View {
                switch self.entity {
                case is Company:
                    Button {
                        self.state.session.job = nil
                        self.state.session.project = nil
                        self.state.session.company = self.entity as? Company
                    } label: {
                        if let entity = self.entity as? Company {
                            entity.linkRowView
                                .underline(self.isHighlighted)
                                .contextMenu {
                                    Button("Edit...") { self.state.to(.companyDetail) }
                                    Divider()
                                    Button("Inspect", action: {
                                        let entity = self.entity as? Company
                                        self.state.session.search.inspectingEntity = entity
                                        self.state.setInspector(AnyView(Inspector(entity: entity)))
                                    })
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                    .help("Open")
                case is Project:
                    Button {
                        self.state.session.job = nil
                        self.state.session.project = self.entity as? Project
                        self.state.session.company = self.state.session.project?.company
                    } label: {
                        if let entity = self.entity as? Project {
                            entity.linkRowView
                                .underline(self.isHighlighted)
                                .contextMenu {
                                    Button("Edit...") { self.state.to(.projectDetail) }
                                    Divider()
                                    Button("Inspect", action: {
                                        let entity = self.entity as? Project
                                        self.state.session.search.inspectingEntity = entity
                                        self.state.setInspector(AnyView(Inspector(entity: entity)))
                                    })
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                    .help("Open")
                case is Job:
                    Button {
                        self.state.session.job = self.entity as? Job
                        self.state.session.project = self.state.session.job?.project
                        self.state.session.company = self.state.session.project?.company
                    } label: {
                        if let entity = self.entity as? Job {
                            entity.linkRowView
                                .underline(self.isHighlighted)
                                .contextMenu {
                                    Button("Edit...") { self.state.to(.jobs) }
                                    Divider()
                                    Button("Inspect", action: {
                                        let entity = self.entity as? Job
                                        self.state.session.search.inspectingEntity = entity
                                        self.state.setInspector(AnyView(Inspector(entity: entity)))
                                    })
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                    .help("Open")
                default:
                    EmptyView()
                }
            }
        }

        // MARK: WidgetLoading
        struct WidgetLoading: View {
            var body: some View {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                    Spacer()
                }
                .padding()
            }
        }

        // MARK: DaysWhereMentioned
        struct DaysWhereMentioned: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showRecords") public var showRecords: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTasks") public var showTasks: Bool = true
            @State private var vid: UUID = UUID()
            @State private var days: [Day] = []

            var body: some View {
                VStack {
                    UI.ListLinkTitle(text: "Interactions with \(self.state.session.job?.title ?? self.state.session.job?.jid.string ?? "job")")
                    if self.state.session.job != nil || self.state.session.project != nil || self.state.session.company != nil {
                        if !self.days.isEmpty {
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 5) {
                                    ForEach(self.days, id: \.id) { entity in
                                        UI.ListButtonItem(
                                            callback: { _ in
                                                self.state.session.date = entity.date
                                            },
                                            name: DateHelper.todayShort(entity.date, format: "MMMM dd, yyyy"),
                                            iconAsImage: entity.type.icon,
                                            actionIcon: "chevron.right"
                                        )
                                    }
                                }
                            }
                        } else {
                            UI.ListButtonItem(
                                callback: {_ in},
                                name: "None found for \(DateHelper.todayShort(self.state.session.date, format: "yyyy"))"
                            )
                            .disabled(true)
                        }
                    } else {
                        UI.ListButtonItem(
                            callback: {_ in},
                            name: "Select an entity from the sidebar"
                        )
                        .disabled(true)
                    }
                    Spacer()
                }
                .id(self.vid)
                .frame(height: 250)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.job) { self.actionOnAppear() }
                .onChange(of: self.state.session.project) { self.actionOnAppear() }
                .onChange(of: self.state.session.company) { self.actionOnAppear() }
                .onChange(of: self.showRecords) { self.actionOnAppear() }
            }

            struct Day: Identifiable {
                var id: UUID = UUID()
                var type: EType
                var date: Date
            }
        }
    }
}

extension WidgetLibrary.UI.ActivityLinks {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.activities = []

        Task {
            await self.getLinksFromJobs()
            await self.getLinksFromNotes()
            await self.getLinksFromRecords()
            self.vid = UUID()
        }
    }

    /// Get links from records created or updated on a given day
    /// @TODO: move to LogRecord
    /// - Returns: Void
    private func getLinksFromRecords() async -> Void {
        if let start = self.start {
            if let end = self.end {
                let linkLength = 40
                let records = CoreDataRecords(moc: self.state.moc).inRange(
                    start: start,
                    end: end
                )

                for record in records {
                    if let message = record.message {
                        if message.contains("https://") {
                            let linkRegex = /https:\/\/([^ \n]+)/
                            if let match = message.firstMatch(of: linkRegex) {
                                let sMatch = String(match.0)
                                var label: String = sMatch

                                if sMatch.count > linkLength {
                                    label = label.prefix(linkLength) + "..."
                                }
                                if !self.activities.contains(where: {$0.name == label}) {
                                    self.activities.append(
                                        Activity(
                                            name: label,
                                            help: sMatch,
                                            page: self.state.parent ?? .dashboard,
                                            type: .activity,
                                            job: record.job,
                                            source: record,
                                            url: URL(string: sMatch) ?? nil
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /// Get links from jobs created or updated on a given day
    /// @TODO: move to Job
    /// - Returns: Void
    private func getLinksFromJobs() async -> Void {
        let jobs = CoreDataJob(moc: self.state.moc).inRange(
            start: self.start,
            end: self.end
        )

        for job in jobs {
            if let uri = job.uri {
                if uri.absoluteString != "https://" {
                    self.activities.append(
                        Activity(
                            name: uri.absoluteString,
                            page: self.state.parent ?? .dashboard,
                            type: .activity,
                            job: job,
                            url: uri.absoluteURL
                        )
                    )
                }
            }
        }
    }

    /// Find links in notes created on a given day
    /// @TODO: Move to Note
    /// - Returns: Void
    private func getLinksFromNotes() async -> Void {
        if self.start != nil && self.end != nil {
            let notes = CoreDataNotes(moc: self.state.moc).inRange(
                start: self.start,
                end: self.end
            )
            let linkLength = 40

            for note in notes {
                if let versions = note.versions?.allObjects as? [NoteVersion] {
                    for version in versions {
                        if let createdOn = version.created {
                            if createdOn > self.start! && createdOn < self.end! {
                                if let content = version.content {
                                    let linkRegex = /https:\/\/([^ \n]+)/
                                    if let match = content.firstMatch(of: linkRegex) {
                                        let sMatch = String(match.0)
                                        var label: String = sMatch

                                        if sMatch.count > linkLength {
                                            label = label.prefix(linkLength) + "..."
                                        }
                                        if !self.activities.contains(where: {$0.name == label}) {
                                            self.activities.append(
                                                Activity(
                                                    name: label,
                                                    help: sMatch,
                                                    page: self.state.parent ?? .dashboard,
                                                    type: .activity,
                                                    job: note.mJob,
                                                    source: version,
                                                    url: URL(string: sMatch) ?? nil
                                                )
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension WidgetLibrary.UI.ListExternalLinkItem {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.shouldCheckLinkStatus {
            self.checkLinkStatus(link: self.name)
        }
    }

    /// Determine if a link is active.
    /// Danke: https://stackoverflow.com/a/52518310
    /// - Parameter link: String
    /// - Returns: Void
    private func checkLinkStatus(link: String) -> Void {
        if let url = URL(string: link) {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"

            URLSession(configuration: .default).dataTask(with: request) { (_, response, error) -> Void in
                guard error == nil else { return }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
                self.isLinkOnline = true
            }
            .resume()
        }
    }
}

extension WidgetLibrary.UI.DaysWhereMentioned {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.days = []

        Task {
            await self.findInteractions()
            self.vid = UUID()
        }
    }

    /// Finds all interactions for the start/end or selected date
    /// - Returns: Void
    private func findInteractions() async -> Void {
        let calendar = Calendar.autoupdatingCurrent

        if self.showRecords {
            if let records = self.state.session.job?.records?.allObjects as? [LogRecord] {
                for record in records {
                    if let timestamp = record.timestamp {
                        let components = calendar.dateComponents([.day], from: timestamp)
                        if !self.days.contains(where: {
                            let co = calendar.dateComponents([.day], from: $0.date)
                            return co.day == components.day
                        }) {
                            self.days.append(
                                Day(type: .records, date: timestamp)
                            )
                        }
                    }
                }
            }
        }

        if self.showTasks {
            if let tasks = self.state.session.job?.tasks?.allObjects as? [LogTask] {
                for task in tasks {
                    if let date = task.completedDate {
                        let components = calendar.dateComponents([.day], from: date)
                        if !self.days.contains(where: {
                            let co = calendar.dateComponents([.day], from: $0.date)
                            return co.day == components.day
                        }) {
                            self.days.append(
                                Day(type: .tasks, date: date)
                            )
                        }
                    }
                }
            }
        }

        let plans = CoreDataPlan(moc: self.state.moc).forToday(self.state.session.date)
        if !plans.isEmpty {
            for plan in plans {
                if let date = plan.created {
                    let components = calendar.dateComponents([.day], from: date)
                    if !self.days.contains(where: {
                        let co = calendar.dateComponents([.day], from: $0.date)
                        return co.day == components.day
                    }) {
                        self.days.append(
                            Day(type: .plans, date: date)
                        )
                    }
                }
            }
        }

        self.days = self.days.sorted(by: {$0.date > $1.date})
    }
}

extension WidgetLibrary.UI.SimpleEntityList {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        Task {
            await self.findInteractions()
        }
    }

    /// Finds all interactions for the start/end or selected date
    /// - Returns: Void
    private func findInteractions() async -> Void {
        switch self.type {
        case .companies:
            var source: [Company]
            if self.start != nil && self.end != nil {
                source = CoreDataCompanies(moc: self.state.moc).interactionsIn(start: self.start, end: self.end)
            } else {
                source = CoreDataCompanies(moc: self.state.moc).interactionsOn(self.state.session.timeline.date ?? self.state.session.date)
            }

            for entity in source {
                self.entities.append(
                    UI.SimpleEntityRow(
                        entity: entity
                    )
                )
            }
        case .projects:
            var source: [Project]
            if self.start != nil && self.end != nil {
                source = CoreDataProjects(moc: self.state.moc).interactionsIn(start: self.start, end: self.end)
            } else {
                source = CoreDataProjects(moc: self.state.moc).interactionsOn(self.state.session.timeline.date ?? self.state.session.date)
            }

            for entity in source {
                self.entities.append(
                    UI.SimpleEntityRow(
                        entity: entity
                    )
                )
            }
        case .jobs:
            var source: [Job]
            if self.start != nil && self.end != nil {
                source = CoreDataJob(moc: self.state.moc).interactionsIn(start: self.start, end: self.end)
            } else {
                source = CoreDataJob(moc: self.state.moc).interactionsOn(self.state.session.timeline.date ?? self.state.session.date)
            }

            for entity in source {
                self.entities.append(
                    UI.SimpleEntityRow(
                        entity: entity
                    )
                )
            }
        default:
            print("noop")
        }
    }
}

extension WidgetLibrary.UI.InteractionsInRange {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.tabs = []
        self.tabs.append(
            ToolbarButton(
                id: 0,
                helpText: "Jobs interacted with in \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))",
                icon: "hammer",
                labelText: "Jobs",
                contents: AnyView(
                    UI.SimpleEntityList(type: .jobs, start: self.start, end: self.end)
                )
            )
        )
        if self.showProjects {
            self.tabs.append(
                ToolbarButton(
                    id: 1,
                    helpText: "Projects interacted with in \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))",
                    icon: "folder",
                    labelText: "Projects",
                    contents: AnyView(
                        UI.SimpleEntityList(type: .projects, start: self.start, end: self.end)
                    )
                )
            )
        }
        if self.showCompanies {
            self.tabs.append(
                ToolbarButton(
                    id: 2,
                    helpText: "Companies interacted with in \(self.format == nil ? "period" : self.state.session.dateFormatted(self.format!))",
                    icon: "building.2",
                    labelText: "Companies",
                    contents: AnyView(
                        UI.SimpleEntityList(type: .companies, start: self.start, end: self.end)
                    )
                )
            )
        }
        self.vid = UUID()
    }
}

extension WidgetLibrary.UI.SuggestedLinksInRange {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.vid = UUID()
    }
}

extension WidgetLibrary.UI.SuggestedStack {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.tabs = [
            ToolbarButton(
                id: 0,
                helpText: "",
                icon: "link",
                labelText: "Links",
                contents: AnyView(
                    UI.ActivityLinks(start: self.start, end: self.end)
                )
            ),
            ToolbarButton(
                id: 1,
                helpText: "",
                icon: "magnifyingglass",
                labelText: "Saved search terms",
                contents: AnyView(
                    UI.SavedSearchTermLinks(
                        period: self.period,
                        format: self.format
                    )
                )
            )
        ]
    }
}

extension WidgetLibrary.UI.SavedSearchTermLinks {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.terms = []
        Task {
            switch self.period {
            case .day:
                await self.findSavedTermsForPeriod(self.state.session.date.startOfDay, self.state.session.date.endOfDay)
            case .week:
                await self.findSavedTermsForPeriod(self.state.session.date.startOfWeek, self.state.session.date.endOfWeek)
            case .month:
                await self.findSavedTermsForPeriod(self.state.session.date.startOfMonth, self.state.session.date.endOfMonth)
            case .year:
                await self.findSavedTermsForPeriod(self.state.session.date.startOfYear, self.state.session.date.endOfYear)
            default:
                await self.findSavedTermsForPeriod(self.start, self.end)
            }
            self.vid = UUID()
        }
    }

    /// Find saved search terms within the given period
    /// - Returns: Void
    private func findSavedTermsForPeriod(_ start: Date?, _ end: Date?) async -> Void {
        if start != nil && end != nil {
            self.terms = CDSavedSearch(moc: self.state.moc).createdBetween(start, end: end)
        }
    }
}

extension WidgetLibrary.UI.GenericTimelineActivity {
    /// Equatable conformity
    /// - Parameters:
    ///   - lhs: GenericTimelineActivity
    ///   - rhs: GenericTimelineActivity
    /// - Returns: Bool
    static func == (lhs: WidgetLibrary.UI.GenericTimelineActivity, rhs: WidgetLibrary.UI.GenericTimelineActivity) -> Bool {
        return lhs.id == rhs.id
    }

    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        Task {
            await self.populateTimeline()
            self.vid = UUID()
        }
    }

    /// Onload handler. Sets view state
    /// - Returns: Void
    private func populateTimeline() async -> Void {
        self.activities = []
        self.state.session.timeline.date = self.historicalDate

        let records = CoreDataRecords(moc: self.state.moc).forDate(self.historicalDate)
        if self.showRecords {
            for record in records {
                // Records created
                if let date = record.timestamp {
                    if let rContent = record.message {
                        // Ignore records representing definitions (those activities are added later)
                        if !rContent.contains("==") {
                            self.activities.append(
                                UI.GenericTimelineActivity(
                                    historicalDate: date,
                                    view: AnyView(record.rowView)
                                )
                            )
                        }
                    }
                }
            }
        }

        if self.showTasks {
            let tasks = CoreDataTasks(moc: self.state.moc).forDate(self.historicalDate, from: records)
            let window = DateHelper.startAndEndOf(self.historicalDate)
            for task in tasks {
                if task.lastUpdate ?? task.created ?? Date() > window.0 && task.lastUpdate ?? task.created ?? Date() < window.1 {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: self.historicalDate,
                            view: AnyView(task.rowView)
                        )
                    )
                }
            }
        }

        if self.showNotes {
            let notes = CoreDataNotes(moc: self.state.moc).forDate(self.historicalDate)
            for note in notes {
                // Notes created
                if let date = note.postedDate {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: date,
                            view: AnyView(note.rowView)
                        )
                    )
                } else
                // Notes updated
                if note.postedDate != note.lastUpdate && note.lastUpdate != nil {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: note.lastUpdate!,
                            view: AnyView(note.rowView)
                        )
                    )
                }
            }
        }

        if self.showJobs {
            let jobs = CoreDataJob(moc: self.state.moc).forDate(self.historicalDate)
            for job in jobs {
                // Jobs created
                if let date = job.created {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: date,
                            view: AnyView(job.rowView)
                        )
                    )
                } else
                // Jobs updated
                if let date = job.lastUpdate {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: date,
                            view: AnyView(job.rowView)
                        )
                    )
                }
            }
        }

        if self.showCompanies {
            let companies = CoreDataCompanies(moc: self.state.moc).forDate(self.historicalDate)
            for company in companies {
                // Companies created
                if let date = company.createdDate {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: date,
                            view: AnyView(company.rowView)
                        )
                    )
                } else
                // Companies updated
                if let date = company.lastUpdate {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: date,
                            view: AnyView(company.rowView)
                        )
                    )
                }
            }
        }

        // Technically this is showDefinitions, but the toggle isn't implemented yet
        // @TODO: change to self.showDefinitions
        if self.showTerms {
            let definitions = CoreDataTaxonomyTermDefinitions(moc: self.state.moc).forDate(self.historicalDate)
            for definition in definitions {
                // Definition updated
                if definition.created != definition.lastUpdate && definition.lastUpdate != nil {
                    if let date = definition.lastUpdate {
                        self.activities.append(
                            UI.GenericTimelineActivity(
                                historicalDate: date,
                                view: AnyView(definition.rowView)
                            )
                        )
                    }
                } else
                // Definition created
                if let date = definition.created {
                    self.activities.append(
                        UI.GenericTimelineActivity(
                            historicalDate: date,
                            view: AnyView(definition.rowView)
                        )
                    )
                }
            }
        }

        // @TODO: This doesn't work just yet
//        let plans = CoreDataPlan(moc: self.state.moc).forToday(self.historicalDate)
//        let calendar = Calendar.autoupdatingCurrent
//        if !plans.isEmpty {
//            for plan in plans {
//                if let date = plan.created {
//                    let components = calendar.dateComponents([.day], from: date)
//                    if !self.activities.contains(where: {
//                        let co = calendar.dateComponents([.day], from: $0.historicalDate)
//                        return co.day == components.day
//                    }) {
//                        self.activities.append(
//                            UI.GenericTimelineActivity(
//                                historicalDate: date,
//                                view: AnyView(plan.rowView)
//                            )
//                        )
//                    }
//                }
//            }
//        }

        self.activities = self.activities.sorted(by: {self.tableSortOrder == 0 ? $0.historicalDate > $1.historicalDate : $0.historicalDate < $1.historicalDate})

        // Find the current page of resources by offset
        let lBound = self.state.session.pagination.currentPageOffset
        let uBound = lBound + self.perPage

        if lBound < self.activities.count && uBound <= self.activities.count {
            self.currentActivities = Array(self.activities[lBound..<uBound])
        } else {
            self.currentActivities = self.activities
        }
    }
}

extension WidgetLibrary.UI.ActivityFeed {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.tabs = []
        var tabSet: Set<ToolbarButton> = []

        let calendar = Calendar.autoupdatingCurrent
        let current = calendar.dateComponents([.year, .month, .day], from: self.state.session.date)

        if current.isValidDate == false {
            for offset in 0...self.maxYearsPastInHistory {
                let offsetYear = ((offset * -1) + current.year!)
                let components = DateComponents(year: offsetYear, month: current.month!, day: current.day!)
                if let day = calendar.date(from: components) {
                    tabSet.insert(
                        ToolbarButton(
                            id: offset,
                            helpText: "Show feed this day in \(DateHelper.todayShort(day, format: "yyyy"))",
                            icon: "\(DateHelper.todayShort(day, format: "yy")).square.fill",
                            labelText: DateHelper.todayShort(day, format: "yyyy"),
                            contents: AnyView(
                                UI.GenericTimelineActivity(
                                    historicalDate: day
                                )
                            )
                        )
                    )
                }
            }
        }

        self.tabs = Array(tabSet)
        self.vid = UUID()
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
    private func actionRedirectToEdit() -> Void {
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

        if self.state.session.appPage == .planning {
            if let job = self.state.session.job {
                self.state.planning.jobs.insert(job)
            }
        }
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
        let types = PageConfiguration.EntityType.allCases.filter({ ![.BruceWillis, .plans].contains($0) })

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
        case .definitions: self.count = CoreDataTaxonomyTermDefinitions(moc: self.state.moc).countAll()
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
        self.date = DateHelper.todayShort(self.state.session.date, format: "MMMM dd, yyyy")
        self.isToday = self.areSameDate(self.state.session.date, Date())
    }

    /// Determine if two dates are the same
    /// - Parameters:
    ///   - lhs: Date
    ///   - rhs: Date
    /// - Returns: Void
    private func areSameDate(_ lhs: Date, _ rhs: Date) -> Bool {
        let df = DateFormatter()
        df.dateFormat = "MMMM dd"
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
