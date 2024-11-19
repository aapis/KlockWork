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
    @EnvironmentObject public var nav: Navigation
    @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @AppStorage("GlobalSidebarWidgets.isCreateStackShowing") private var isCreateStackShowing: Bool = false
    @AppStorage("general.showSessionInspector") public var showSessionInspector: Bool = false
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
    @AppStorage("notifications.interval") private var notificationInterval: Int = 0
    @AppStorage("widgetlibrary.ui.isSidebarPresented") private var isSidebarPresented: Bool = false
    @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
    @AppStorage("general.usingBackgroundColour") private var usingBackgroundColour: Bool = false
    @State public var selectedSidebarButton: Page = .dashboard
    @State private var timer: Timer? = nil
    @State private var buttons: [PageGroup: [SidebarButton]] = [:]
    @State private var sidebarTabs: [ToolbarButton] = []
    @State private var customImage: Image? = nil

    /// Sidebar widgets that live in every sidebar
    static public let standardSidebarWidgets: [ToolbarButton] = [
        ToolbarButton(
            id: 0,
            helpText: "Resources",
            icon: "globe",
            selectedIcon: "globe",
            labelText: "Resources",
            contents: AnyView(UI.UnifiedSidebar.Widget())
        ),
        ToolbarButton(
            id: 1,
            helpText: "Outline",
            icon: "menucard",
            selectedIcon: "menucard.fill",
            labelText: "Outline",
            contents: AnyView(OutlineWidget())
        ),
        ToolbarButton(
            id: 2,
            helpText: "Calendar events",
            icon: "calendar",
            selectedIcon: "calendar",
            labelText: "Calendar events",
            contents: AnyView(WidgetLibrary.UI.Sidebar.EventsWidget())
        ),
        // Experimental navigator
//        ToolbarButton(
//            id: 3,
//            helpText: "X",
//            icon: "xmark",
//            labelText: "X",
//            contents: AnyView(WidgetLibrary.UI.Navigator(location: .sidebar))
//        ),
    ]
    private let page: APage = .find

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    if nav.sidebar != nil && self.isSidebarPresented {
                        TabBackground
                        Sidebar
                            .border(width: 1, edges: [.trailing], color: Theme.rowColour)
                    }

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
            .background(self.PageBackground)
        }
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.nav.session.company) { self.actionOnChangeCompany() }
        .onChange(of: self.nav.session.project) { self.createToolbarButtons() }
        .onChange(of: self.nav.session.job) { self.createToolbarButtons() }
        .onChange(of: self.nav.theme.wallpaperChoice) {
            if self.nav.theme.wallpaperChoice == 1 {
                self.actionOnChangeCustomBackgroundImage()
            }
        }
        .onChange(of: self.nav.theme.customWallpaperUrl) { self.actionOnChangeCustomBackgroundImage() }
    }

    @ViewBuilder private var PageBackground: some View {
        if self.usingBackgroundImage {
            ZStack {
                self.nav.session.appPage.primaryColour.saturation(0.7)
                if self.nav.theme.wallpaperChoice == 1 {
                    if let customImage = self.customImage {
                        customImage.resizable().aspectRatio(contentMode: .fill)
                    }
                } else if self.nav.theme.wallpaperChoice == 2 {
                    Image("wallpaper-01").resizable().aspectRatio(contentMode: .fill)
                } else if self.nav.theme.wallpaperChoice == 3 {
                    Image("wallpaper-02").resizable().aspectRatio(contentMode: .fill)
                } else if self.nav.theme.wallpaperChoice == 4 {
                    Image("wallpaper-03").resizable().aspectRatio(contentMode: .fill)
                } else if self.nav.theme.wallpaperChoice == 5 {
                    Image("wallpaper-04").resizable().aspectRatio(contentMode: .fill)
                }
                Theme.base.blendMode(.softLight).opacity(0.5)
            }
        } else if self.usingBackgroundColour, let colour = self.nav.theme.customBackgroundColour {
            ZStack { colour }
        }
    }

    @ViewBuilder var Sidebar: some View {
        ZStack(alignment: .leading) {
            HStack {
                LinearGradient(colors: [Theme.lightWhite, .clear], startPoint: .leading, endPoint: .trailing)
                    .opacity(0.2)
                    .blendMode(.softLight)
                    .frame(width: 80)
                Spacer()
                LinearGradient(colors: [Theme.lightWhite, .clear], startPoint: .trailing, endPoint: .leading)
                    .opacity(0.2)
                    .blendMode(.softLight)
                    .frame(width: 40)
            }

            VStack(alignment: .leading, spacing: 0) {
                FancyGenericToolbar(
                    buttons: self.sidebarTabs,
                    standalone: true,
                    location: .sidebar,
                    mode: .compact,
                    page: .find,
                    scrollable: false
                )
                .padding(.top, 2)
                UI.EntityCalendar.Widget()
            }
        }
        .frame(width: 320)
        .background(nav.parent != nil ? nav.parent!.colour : Theme.tabActiveColour)
    }

    @ViewBuilder var TabBackground: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                if !(self.usingBackgroundImage || self.usingBackgroundColour) {
                    Theme.toolbarColour
                }
                LinearGradient(gradient: Gradient(colors: [Theme.base, Theme.toolbarColour]), startPoint: .topTrailing, endPoint: .topLeading)
                    .opacity(0.25)

                VStack(alignment: .trailing, spacing: 5) {
                    if let buttons = self.buttons[.views] {
                        FancyDivider()
                        ForEach(buttons) { button in button }
                    }

                    if let buttons = self.buttons[.entities] {
                        FancyDivider()
                        ForEach(buttons) { button in button }
                    }
                }
            }
        }
        .frame(width: 100)
    }

    @ViewBuilder var InspectorAndMain: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                UI.AppNavigation()
                nav.view
                    .navigationTitle(nav.pageTitle())
                    .disabled(self.nav.inspector != nil)
            }

            if nav.inspector != nil {
                Theme.base.opacity(0.7)
                ZStack(alignment: .topLeading) {
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Theme.base]), startPoint: .topTrailing, endPoint: .topLeading)
                        .opacity(0.25)
                        .frame(width: 20)

                    self.nav.parent?.appPage.primaryColour.opacity(0.2) ?? Theme.subHeaderColour

                    nav.inspector
                }
                .background(Theme.base)
                .frame(width: 340)
            }
        }
    }
}

extension Home {
    /// Onload handler. Sets view state, finds events, creates toolbar buttons, monitors keyboard for Esc
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.nav.parent = self.selectedSidebarButton
        self.checkForEvents()
        self.createToolbarButtons()
        self.actionOnChangeCustomBackgroundImage()

        KeyboardHelper.monitor(key: .keyDown, callback: {
            self.isSearchStackShowing = false
            self.isCreateStackShowing = false
            self.nav.session.search.reset()
            self.nav.session.search.inspectingEntity = nil
            self.nav.setInspector()
        })

        self.sidebarTabs = [
            ToolbarButton(
                id: 0,
                helpText: "",
                icon: "sun.min",
                selectedIcon: "sun.min.fill",
                labelText: "Cryptic message.",
                contents: AnyView(
                    ZStack(alignment: .bottomLeading) {
                        VStack(spacing: 0) {
                            GlobalSidebarWidgets()
                            nav.sidebar
                        }
                        Divider()
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                            .opacity(0.2)
                            .blendMode(.softLight)
                            .frame(height: 20)
                    }
                )
            ),
            ToolbarButton(
                id: 1,
                helpText: "Global app settings",
                icon: "gearshape",
                selectedIcon: "gearshape.fill",
                labelText: "Global app settings",
                contents: AnyView(
                    ZStack(alignment: .bottomLeading) {
                        GlobalSettingsPanel()
                        Divider()
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                            .opacity(0.2)
                            .blendMode(.softLight)
                            .frame(height: 20)
                    }
                )
            )
        ]
    }
    
    /// Find user-selected background image and use it, if available. Fires in onChange callback
    /// - Returns: Void
    private func actionOnChangeCustomBackgroundImage() -> Void {
        if let stored = self.nav.theme.customWallpaperUrl {
            if let imageData = try? Data(contentsOf: stored) {
                if let image = NSImage(data: imageData) {
                    self.customImage = Image(nsImage: image)
                }
            }
        }
    }

    /// Creates all toolbar buttons
    /// - Returns: Void
    private func createToolbarButtons() -> Void {
        self.buttons = [
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
                    icon: self.nav.planning.jobs.count == 0 ? "hexagon" : (nav.session.gif == .focus ? "hexagon.fill" : "hexagon"),
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
                SidebarButton(
                    destination: AnyView(Today()),
                    pageType: .today,
                    iconAsImage: EType.records.icon,
                    label: "Today",
                    sidebar: AnyView(TodaySidebar()),
                    altMode: PageAltMode(
                        name: "CLI Mode",
                        icon: "apple.terminal",
                        condition: commandLineMode
                    )
                ),
            ],
            .entities: []
        ]

        if self.nav.session.company != nil {
            self.buttons[.entities]!.append(
                SidebarButton(
                    destination: AnyView(CompanyDashboard()),
                    pageType: .companies,
                    iconAsImage: EType.companies.icon,
                    label: EType.companies.label,
                    sidebar: AnyView(DefaultCompanySidebar())
                )
            )
        }

        if self.nav.session.project != nil {
            self.buttons[.entities]!.append(
                SidebarButton(
                    destination: AnyView(ProjectsDashboard()),
                    pageType: .projects,
                    iconAsImage: EType.projects.icon,
                    label: EType.projects.label,
                    sidebar: AnyView(DefaultCompanySidebar())
                )
            )
        }

        if self.nav.session.job != nil {
            self.buttons[.entities]!.append(
                SidebarButton(
                    destination: AnyView(JobDashboard()),
                    pageType: .jobs,
                    iconAsImage: EType.jobs.icon,
                    label: EType.jobs.label,
                    sidebar: AnyView(JobDashboardSidebar())
                )
            )
        }
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
        let ce = CoreDataCalendarEvent(moc: self.nav.moc)
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
        self.createToolbarButtons()
    }
}
