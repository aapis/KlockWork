//
//  ContentView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI
import EventKit
import KWCore

struct Home: View {
    typealias APage = PageConfiguration.AppPage
    typealias Entity = PageConfiguration.EntityType
    typealias UI = WidgetLibrary.UI
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @AppStorage("general.showSessionInspector") public var showSessionInspector: Bool = false
    @AppStorage("general.experimental.cli") private var cliEnabled: Bool = false
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
    @AppStorage("notifications.interval") private var notificationInterval: Int = 0
    @State public var selectedSidebarButton: Page = .dashboard
    @State private var timer: Timer? = nil

    /// Sidebar widgets that live in every sidebar
    static public let standardSidebarWidgets: [ToolbarButton] = [
        ToolbarButton(
            id: 0,
            helpText: "Resources",
            icon: "globe",
            labelText: "Resources",
            contents: AnyView(UI.UnifiedSidebar.Widget())
        ),
        ToolbarButton(
            id: 1,
            helpText: "Outline",
            icon: "menucard",
            labelText: "Outline",
            contents: AnyView(OutlineWidget())
        ),
        ToolbarButton(
            id: 2,
            helpText: "Calendar events",
            icon: "calendar",
            labelText: "Calendar events",
            contents: AnyView(WidgetLibrary.UI.Sidebar.EventsWidget())
        ),
    ]

    private let page: APage = .find
    private var buttons: [PageGroup: [SidebarButton]] {
        [
            .views: [
                SidebarButton(
                    destination: AnyView(Dashboard()),
                    pageType: .dashboard,
                    icon: "magnifyingglass",
                    label: "Find anything",
                    sidebar: AnyView(DashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(Planning()),
                    pageType: .planning,
                    icon: nav.planning.jobs.count == 0 ? "hexagon" : (nav.session.gif == .focus ? "circle.hexagongrid.fill" : "circle.hexagongrid"),
                    label: "Planning",
                    sidebar: AnyView(DefaultPlanningSidebar())
                ),
                SidebarButton(
                    destination: AnyView(Explore()),
                    pageType: .explore,
                    icon: "globe.desk",
                    label: "Explore",
                    sidebar: AnyView(ExploreSidebar())
                ),
            ],
            .entities: [
                SidebarButton(
                    destination: AnyView(Today()),
                    pageType: .today,
                    iconAsImage: Entity.records.icon,
                    label: "Today",
                    sidebar: AnyView(TodaySidebar()),
                    altMode: PageAltMode(
                        name: "CLI Mode",
                        icon: "apple.terminal",
                        condition: cliEnabled && commandLineMode
                    )
                ),
                SidebarButton(
                    destination: AnyView(TaskDashboard()),
                    pageType: .tasks,
                    iconAsImage: Entity.tasks.icon,
                    label: Entity.tasks.label,
                    sidebar: AnyView(TaskDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(NoteDashboard()),
                    pageType: .notes,
                    iconAsImage: Entity.notes.icon,
                    label: Entity.notes.label,
                    sidebar: AnyView(NoteDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(PeopleDashboard()),
                    pageType: .people,
                    iconAsImage: Entity.people.icon,
                    label: Entity.people.label,
                    sidebar: AnyView(PeopleDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(CompanyDashboard()),
                    pageType: .companies,
                    iconAsImage: Entity.companies.icon,
                    label: Entity.companies.label,
                    sidebar: AnyView(DefaultCompanySidebar())
                ),
                SidebarButton(
                    destination: AnyView(ProjectsDashboard()),
                    pageType: .projects,
                    iconAsImage: Entity.projects.icon,
                    label: Entity.projects.label,
                    sidebar: AnyView(DefaultCompanySidebar())
                ),
                SidebarButton(
                    destination: AnyView(JobDashboard()),
                    pageType: .jobs,
                    iconAsImage: Entity.jobs.icon,
                    label: Entity.jobs.label,
                    sidebar: AnyView(JobDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(TermsDashboard()),
                    pageType: .terms,
                    iconAsImage: Entity.terms.icon,
                    label: Entity.terms.label,
                    sidebar: AnyView(TermsDashboardSidebar())
                )
            ]
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    TabBackground
                    if nav.sidebar != nil {
                        Sidebar
                    }

                    Divider().background(Theme.rowColour)
                    ZStack(alignment: .leading) {
                        InspectorAndMain
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .leading, endPoint: .trailing)
                            .opacity(0.1)
                            .blendMode(.softLight)
                            .frame(width: 20)
                    }

                    if showSessionInspector {
                        SessionInspector()
                    }
                }
            }
        }
        .onAppear(perform: self.onAppear)
        .onChange(of: self.nav.session.company) { self.actionOnChangeCompany() }
    }

    @ViewBuilder var Sidebar: some View {
        ZStack(alignment: .trailing) {
            Color.white
                .opacity(0.4)
                .blendMode(.softLight)
            LinearGradient(colors: [.white, .clear], startPoint: .trailing, endPoint: .leading)
                .opacity(0.1)
                .blendMode(.softLight)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 0) {
                GlobalSidebarWidgets()

                if !isSearchStackShowing && !isUpcomingTaskStackShowing {
                    if isDatePickerPresented {
                        ZStack {
                            nav.sidebar
                            Theme.base.opacity(0.7)
                        }
                    } else {
                        nav.sidebar
                    }
                }
            }
        }
        .frame(width: 320)
        .background(nav.parent != nil ? nav.parent!.colour : Theme.tabActiveColour)
    }

    @ViewBuilder var TabBackground: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                Theme.toolbarColour
                LinearGradient(gradient: Gradient(colors: [Theme.base, Theme.toolbarColour]), startPoint: .topTrailing, endPoint: .topLeading)
                    .opacity(0.25)

                VStack(alignment: .trailing, spacing: 5) {
                    FancyDivider()
                    ForEach(buttons[.views]!) { button in button.environmentObject(nav) }

                    FancyDivider()
                    ForEach(buttons[.entities]!) { button in button.environmentObject(nav) }
                }
            }
        }
        .frame(width: 100)
    }

    @ViewBuilder var InspectorAndMain: some View {
        if nav.inspector != nil {
            ZStack(alignment: .topLeading) {
                VStack {
                    UI.AppNavigation()
                    nav.view
                        .navigationTitle(nav.pageTitle())
                        .disabled(isDatePickerPresented)

                }
                Theme.base.opacity(0.7)

                ZStack(alignment: .topLeading) {
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Theme.base]), startPoint: .topTrailing, endPoint: .topLeading)
                        .opacity(0.25)
                        .frame(width: 20)

                    self.nav.parent?.appPage.primaryColour.opacity(0.2) ?? Theme.subHeaderColour

                    nav.inspector

                    if isDatePickerPresented {
                        Theme.base.opacity(0.7)
                    }
                }
                .background(Theme.base)
                .frame(width: 340)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                UI.AppNavigation()

                ZStack {
                    nav.view
                        .navigationTitle(nav.pageTitle())
                        .disabled(isDatePickerPresented)
                    (isDatePickerPresented ? Theme.base.opacity(0.7) : .clear)
                }
            }
        }
    }
}

extension Home {
    private func onAppear() -> Void {
        nav.parent = selectedSidebarButton
        checkForEvents()

        KeyboardHelper.monitor(key: .keyDown, callback: {
            self.isSearchStackShowing = false
            self.isDatePickerPresented = false
            self.nav.session.search.reset()
            self.nav.session.search.inspectingEntity = nil
            self.nav.setInspector()
        })
    }
    
    /// Check for upcoming events and create notifications
    /// - Returns: Void
    private func checkForEvents() -> Void {
        self.timer?.invalidate()
        self.nav.session.eventStatus = updateIndicator()
        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.nav.session.eventStatus = updateIndicator()

            // Create notifications for new events
            NotificationHelper.createNotifications(
                from: CoreDataTasks(moc: self.nav.moc).upcoming(hasScheduledNotification: false),
                interval: self.notificationInterval
            )
        }
    }

    /// Updates the dashboard icon upcoming event indicator
    /// - Returns: EventIndicatorStatus
    private func updateIndicator() -> EventIndicatorStatus {
        let ce = CoreDataCalendarEvent(moc: moc)
        var upcoming: [EKEvent] = []
        var inProgress: [EKEvent] = []

        if let chosenCalendar = ce.selectedCalendar() {
            inProgress = ce.eventsInProgress(chosenCalendar)
            upcoming = ce.eventsUpcoming(chosenCalendar)
        }

        if let next = upcoming.first {
            if let evStart = next.startDate {
                let now = Date.now

                if evStart - now <= 600 {
                    return .imminent
                } else if evStart - now <= 1800 {
                    return .upcoming
                }
            }
        } else if let current = inProgress.first {
            if let evEnd = current.endDate {
                if Date.now <= evEnd {
                    return .inProgress
                }
            }
        }

        return .ready
    }
    
    /// Fires when you change companies, resets children
    /// - Returns: Void
    private func actionOnChangeCompany() -> Void {
        self.nav.session.project = nil
        self.nav.session.job = nil
    }
}
