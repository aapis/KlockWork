//
//  ContentView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import EventKit
import SwiftUI
import KWCore

struct Home: View {
    typealias APage = PageConfiguration.AppPage
    typealias Entity = PageConfiguration.EntityType
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    @State public var selectedSidebarButton: Page = .dashboard
    @State private var timer: Timer? = nil

    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @AppStorage("general.showSessionInspector") public var showSessionInspector: Bool = false
    @AppStorage("general.experimental.cli") private var cliEnabled: Bool = false
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false

    /// Sidebar widgets that live in every sidebar
    static public let standardSidebarWidgets: [ToolbarButton] = [
        ToolbarButton(
            id: 0,
            helpText: "Resources",
            icon: "globe",
            labelText: "Resources",
            contents: AnyView(UnifiedSidebar.Widget())
        ),
        ToolbarButton(
            id: 1,
            helpText: "Outline",
            icon: "menucard",
            labelText: "Outline",
            contents: AnyView(OutlineWidget())
        )
    ]

    private let page: APage = .find
    private var buttons: [PageGroup: [SidebarButton]] {
        [
            .views: [
                SidebarButton(
                    destination: AnyView(Dashboard()),
                    pageType: .dashboard,
                    icon: "house",
                    label: "Dashboard",
                    sidebar: AnyView(DashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(Planning()),
                    pageType: .planning,
                    icon: nav.planning.jobs.count == 0 ? "hexagon" : (nav.session.gif == .focus ? "circle.hexagongrid.fill" : "circle.hexagongrid"),
                    label: "Planning",
                    sidebar: AnyView(DefaultPlanningSidebar())
                ),
                // @TODO: Explore page
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
                            Color.black.opacity(0.7)
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
                LinearGradient(gradient: Gradient(colors: [Color.black, Theme.toolbarColour]), startPoint: .topTrailing, endPoint: .topLeading)
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
                nav.view
                    .navigationTitle(nav.pageTitle())
                    .disabled(isDatePickerPresented)
                Color.black.opacity(0.7)

                ZStack(alignment: .topLeading) {
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .topTrailing, endPoint: .topLeading)
                        .opacity(0.25)
                        .frame(width: 20)

                    Theme.subHeaderColour

                    nav.inspector

                    if isDatePickerPresented {
                        Color.black.opacity(0.7)
                    }
                }
                .background(Theme.base)
                .frame(width: 340)
            }
        } else {
            VStack {
                //                                if nav.history.recent.count > 0 {
                //                                    HStack {
                //                                        Button {
                //                                            if let previous = nav.history.previous() {
                //                                                nav.to(previous.page)
                //                                            }
                //                                        } label: {
                //                                            HStack(spacing: 5) {
                //                                                Image(systemName: "arrow.left")
                //                                                Text("Back")
                //                                            }
                //                                        }
                //                                        .buttonStyle(.plain)
                //                                        .background(Theme.subHeaderColour)
                //
                //                                        Spacer()
                //                                        Button {
                //                                            if let next = nav.history.next() {
                //                                                nav.to(next.page)
                //                                            }
                //                                        } label: {
                //                                            HStack(spacing: 5) {
                //                                                Text("Next")
                //                                                Image(systemName: "arrow.right")
                //                                            }
                //                                        }
                //                                        .buttonStyle(.plain)
                //                                        .background(Theme.subHeaderColour)
                //                                    }
                //                                    .background(Theme.base)
                //                                    .frame(height: 70)
                //                                }

                ZStack {
                    nav.view
                        .navigationTitle(nav.pageTitle())
                        .disabled(isDatePickerPresented)
                    (isDatePickerPresented ? Color.black.opacity(0.7) : .clear)
                }
            }
        }
    }
}

extension Home {
    private func onAppear() -> Void {
        nav.parent = selectedSidebarButton
        checkForEvents()

        // Thank you https://blog.rampatra.com/how-to-detect-escape-key-pressed-in-macos-apps
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if self.isEscapeKey(with: $0) {
                isDatePickerPresented = false
                nav.session.search.inspectingEntity = nil
                nav.setInspector()
                return nil
            } else {
                return $0
            }
        }
    }

    private func isEscapeKey(with event: NSEvent) -> Bool {
        return Int(event.keyCode) == 53
    }

    private func checkForEvents() -> Void {
        timer?.invalidate()

        nav.session.eventStatus = updateIndicator()

        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            nav.session.eventStatus = updateIndicator()
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
}
