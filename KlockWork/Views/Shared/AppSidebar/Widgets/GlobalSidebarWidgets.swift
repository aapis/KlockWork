//
//  GlobalSidebarWidgets.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct GlobalSidebarWidgets: View {
    @EnvironmentObject public var nav: Navigation
    @AppStorage("GlobalSidebarWidgets.isCreateStackShowing") private var isCreateStackShowing: Bool = false
    @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @State private var followingPlan: Bool = false
    @State private var doesPlanExist: Bool = false
    @State private var searching: Bool = false
    public var page: PageConfiguration.AppPage = .planning

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Buttons
                .padding(.top)
                .padding(.bottom, isSearchStackShowing || isCreateStackShowing || isUpcomingTaskStackShowing ? 16 : 0)

            if isSearchStackShowing || isCreateStackShowing || isUpcomingTaskStackShowing {
                VStack(alignment: .leading, spacing: 0) {
                    if isSearchStackShowing {
                        FindDashboard(location: .sidebar)
                        Spacer()
                    } else if isCreateStackShowing {
                        CreateStack()
                    } else if isUpcomingTaskStackShowing {
                        ScrollView(showsIndicators: false) {
                            Planning.Upcoming()
                        }
                    }
                }
                .padding([.top, .bottom], self.isCreateStackShowing ? 16 : 0)
                .padding([.leading, .trailing], self.isCreateStackShowing ? 10 : 0)
                .background(self.isUpcomingTaskStackShowing || self.isCreateStackShowing ? Theme.base.opacity(0.6) : .clear)
            }
        }
        .padding(.bottom)
        .border(width: 1, edges: [.bottom], color: Theme.rowColour)
        .background(Theme.base.blendMode(.softLight).opacity(0.3))
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.tasks) { self.actionOnChangeOfTasks() }
        .onChange(of: nav.planning.jobs) { self.actionOnChangeOfJobs() }
        .onChange(of: nav.planning.notes) { self.actionOnChangeOfNotes() }
    }

    private var Buttons: some View {
        HStack(alignment: .center, spacing: 8) {
            PlanButton(doesPlanExist: $doesPlanExist)
            // @TODO: uncomment when privacy mode is built out
//            PrivacyModeButton()
            CreateButton(active: $isCreateStackShowing)
            FindButton(active: $isSearchStackShowing)
            ScoreButton()
            Forecast(
                date: DateHelper.startOfDay(self.nav.session.date),
                type: .button,
                page: self.page
            )
            Spacer()
        }
        .padding([.leading, .trailing], 15)
    }

    struct PlanButton: View {
        @Binding public var doesPlanExist: Bool

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    ZStack {
                        Theme.base.opacity(0.5)

                        if doesPlanExist {
                            FancyButtonv2(
                                text: nav.session.gif == .focus ? "Disable the global filter, show all items" : "Show only the items in your daily plan",
                                action: actionOnChangeFocus,
                                icon: nav.session.gif == .focus ? "circle.hexagongrid.fill" : "circle.hexagongrid",
                                fgColour: Theme.base,
                                showLabel: false,
                                size: .small,
                                type: .tsWhite,
                                font: .title2
                            )
                            .mask(Circle())
                        } else {
                            FancyButtonv2(
                                text: "You need to create a plan first, click here!",
                                action: {self.nav.to(.planning)},
                                icon: "hexagon",
                                fgColour: Theme.base,
                                showLabel: false,
                                size: .small,
                                type: nav.parent == .planning ? .secondary : .tsWhite,
                                font: .title2
                            )
                            .mask(Circle())
                        }
                    }
                    .mask(Circle())
                    if !doesPlanExist {
                        Image(systemName: "questionmark.circle.fill")
                            .position(x: 38, y: 38)
                    }
                }
                .frame(width: 46, height: 46)

                Text(nav.session.gif == .focus ? "On" : "Off")
                    .opacity(nav.session.gif == .focus ? 1 : 0.4)
            }
        }
    }

    struct PrivacyModeButton: View {
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    ZStack {
                        Theme.base.opacity(0.5)

                        FancyButtonv2(
                            text: "Privacy mode",
                            action: {
                                if nav.session.gif == .privacy { nav.session.gif = .normal } else { nav.session.gif = .privacy }
                            },
                            icon: nav.session.gif == .privacy ? "eye" : "eye.slash",
                            fgColour: nav.session.job?.colour_from_stored().isBright() ?? false ? .black : .white,
                            bgColour: nav.session.job?.colour_from_stored() ?? nil,
                            showLabel: false,
                            size: .small,
                            type: nav.session.gif == .privacy ? .secondary : .standard
                        )
                        .mask(Circle())
                    }
                    .mask(Circle())
                }
                .frame(width: 46, height: 46)

                Text(nav.session.gif == .privacy ? "On" : "Off")
                    .opacity(nav.session.gif == .privacy ? 1 : 0.4)
            }
        }
    }

    struct CreateButton: View {
        @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false

        @Binding public var active: Bool
        
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    ZStack {
                        Theme.base.opacity(0.5)
                        FancyButtonv2(
                            text: "Create companies, jobs, notes, projects or tasks.",
                            action: {active.toggle() ; isSearchStackShowing = false; self.isUpcomingTaskStackShowing = false},
                            icon: "doc",
                            fgColour: nav.session.job?.colour_from_stored().isBright() ?? false ? .black : .white,
                            bgColour: nav.session.job?.backgroundColor ?? nil,
                            showLabel: false,
                            size: .small,
                            type: active ? .secondary : .standard,
                            font: .title2
                        )
                        .mask(Circle())
                    }
                    .mask(Circle())
                    Image(systemName: "plus.circle.fill")
                        .position(x: 38, y: 38)
                }
                .frame(width: 46, height: 46)

                Text("Create")
                    .opacity(active ? 1 : 0.4)
            }
        }
    }

    struct FindButton: View {
        @EnvironmentObject public var nav: Navigation
        @AppStorage("GlobalSidebarWidgets.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isSearching") private var isSearching: Bool = false
        @Binding public var active: Bool

        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    ZStack {
                        Theme.base.opacity(0.5)
                        FancyButtonv2(
                            text: "Find",
                            action: {
                                self.active.toggle()
                                self.isSearching.toggle()
                                self.isCreateStackShowing = false
                                self.isUpcomingTaskStackShowing = false
                                self.nav.session.search.reset()
                            },
                            icon: "magnifyingglass",
                            fgColour: self.nav.session.job?.backgroundColor.isBright() ?? false ? .black : .white,
                            bgColour: self.nav.session.job?.backgroundColor ?? nil,
                            showLabel: false,
                            size: .small,
                            type: active ? .secondary : .standard,
                            font: .title2
                        )
                        .keyboardShortcut("f", modifiers: .command)
                        .mask(Circle())
                    }
                    .mask(Circle())
                }.frame(width: 46, height: 46)

                Text("Find")
                    .opacity(active ? 1 : 0.4)
            }
        }
    }

    struct ScoreButton: View {
        @EnvironmentObject public var state: Navigation
        @AppStorage("GlobalSidebarWidgets.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isSearching") private var isSearching: Bool = false
        @State private var score: Int = 0
        @State private var bgColour: Color?

        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    ZStack {
                        Theme.base.opacity(0.5)
                        FancyButtonv2(
                            text: "\(self.score)",
                            action: {
                                self.isSearching.toggle()
                                self.isCreateStackShowing = false
                                self.isUpcomingTaskStackShowing = false
                                self.state.session.search.reset()
                            },
                            fgColour: (self.state.session.job?.backgroundColor ?? self.bgColour ?? .clear).isBright() ? Theme.base : .white,
                            bgColour: self.state.session.job?.backgroundColor ?? self.bgColour ?? .clear,
                            showLabel: true,
                            size: .small,
                            type: .standard,
                            font: .title2
                        )
                        .mask(Circle())
                    }
                    .mask(Circle())
                }.frame(width: 46, height: 46)

                Text("Score")
                    .opacity(0.4)
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.date) { self.actionOnAppear() }
        }
    }

    struct CreateStack: View {
        @AppStorage("GlobalSidebarWidgets.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false

        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 5) {
                    FancyButtonv2(
                        text: "Company",
                        action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.companyDetail)},
                        iconAsImage: PageConfiguration.EntityType.companies.icon,
                        iconFgColour: self.nav.session.company?.backgroundColor,
                        fgColour: .white,
                        size: .link,
                        type: nav.parent == .notes ? .secondary : .standard
                    )
                    Spacer()
                    UI.KeyboardShortcutIndicator(character: "C", requireShift: true)
                }

                ZStack(alignment: .topLeading) {
                    HStack(alignment: .center) {
                        Divider().frame(height: 205)
                    }
                    VStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 10)
                            }

                            HStack {
                                FancyButtonv2(
                                    text: "Person",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.peopleDetail)},
                                    iconAsImage: PageConfiguration.EntityType.people.icon,
                                    iconFgColour: self.nav.session.company?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .people ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "U", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 10)
                            }

                            HStack {
                                FancyButtonv2(
                                    text: "Project",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.projectDetail)},
                                    iconAsImage: PageConfiguration.EntityType.projects.icon,
                                    iconFgColour: self.nav.session.project?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .projects ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "P", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 30)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Job",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.jobs)},
                                    iconAsImage: PageConfiguration.EntityType.jobs.icon,
                                    iconFgColour: self.nav.session.job?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .jobs ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "J", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Note",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.noteDetail)},
                                    iconAsImage: PageConfiguration.EntityType.notes.icon,
                                    iconFgColour: self.nav.session.job?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .notes ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "N", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Task",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.taskDetail)},
                                    iconAsImage: PageConfiguration.EntityType.tasks.icon,
                                    iconFgColour: self.nav.session.job?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "T", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Record",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.today)},
                                    iconAsImage: PageConfiguration.EntityType.records.icon,
                                    iconFgColour: self.nav.session.job?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "R", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Term",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.termDetail)},
                                    iconAsImage: PageConfiguration.EntityType.terms.icon,
                                    iconFgColour: self.nav.session.job?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "D", requireShift: true)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Definition",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false ; self.nav.to(.definitionDetail)},
                                    iconAsImage: PageConfiguration.EntityType.definitions.icon,
                                    iconFgColour: self.nav.session.job?.backgroundColor,
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard
                                )
                            }
                            Spacer()
                            UI.KeyboardShortcutIndicator(character: "D", requireShift: true)
                        }
                    }
                }
                .padding(.leading, 15)
            }
        }
    }
}

extension GlobalSidebarWidgets {
    private func actionOnAppear() -> Void {
        findPlan()
    }

    private func actionOnChangeOfTasks() -> Void {
        if (nav.planning.taskCount() + nav.planning.jobs.count + nav.planning.notes.count) == 0 {
            nav.planning = Navigation.PlanningState(moc: nav.planning.moc)
        }

        findPlan()
    }

    private func actionOnChangeOfJobs() -> Void {
        if (nav.planning.jobs.count + nav.planning.tasks.count + nav.planning.notes.count) == 0 {
            nav.planning = Navigation.PlanningState(moc: nav.planning.moc)
        }

        findPlan()
    }

    private func actionOnChangeOfNotes() -> Void {
        if (nav.planning.notes.count + nav.planning.jobs.count + nav.planning.tasks.count) == 0 {
            nav.planning = Navigation.PlanningState(moc: nav.planning.moc)
        }

        findPlan()
    }
    
    /// Determine whether there's an active plan, sets self.doesPlanExist accordingly
    /// - Returns: Void
    private func findPlan() -> Void {
        let plans = CoreDataPlan(moc: self.nav.moc).forDate(nav.session.date)
        if plans.count > 0 {
            if let plan = plans.first {
                doesPlanExist = !plan.isEmpty()
            }
        }
    }
}

extension GlobalSidebarWidgets.PlanButton {
    private func actionOnChangeFocus() -> Void {
        if nav.session.gif == .normal {
            nav.session.gif = .focus
        } else {
            nav.session.gif = .normal
        }
    }
}

extension GlobalSidebarWidgets.ScoreButton {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let assessment = self.state.activities.assessed.filter({$0.isToday == true && $0.dayNumber > 0}).first {
            self.score = assessment.score
            self.bgColour = Theme.cPurple
        }
    }
}
