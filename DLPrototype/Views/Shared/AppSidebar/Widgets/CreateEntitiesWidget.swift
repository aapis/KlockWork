//
//  CreateEntitiesWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CreateEntitiesWidget: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @AppStorage("CreateEntitiesWidget.isCreateStackShowing") private var isCreateStackShowing: Bool = false
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @State private var followingPlan: Bool = false
    @State private var doesPlanExist: Bool = false
    @State private var searching: Bool = false
    public var page: PageConfiguration.AppPage = .planning


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Buttons

            if isSearchStackShowing || isCreateStackShowing || isUpcomingTaskStackShowing {
                VStack(alignment: .leading, spacing: 0) {
                    if isSearchStackShowing {
                        FindDashboard(searching: $searching, location: .sidebar)
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
                .background(Theme.base.opacity(0.6))
            }
        }
        .padding(self.isCreateStackShowing ? .top : [.top, .bottom])
        .border(width: 1, edges: [.bottom], color: Theme.rowColour)
        .background(Theme.base.blendMode(.softLight).opacity(0.3))
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.planning.tasks) { self.actionOnChangeOfTasks() }
        .onChange(of: nav.planning.jobs) { self.actionOnChangeOfJobs() }
        .onChange(of: nav.planning.notes) { self.actionOnChangeOfNotes() }
    }

    private var Buttons: some View {
        HStack(alignment: .center, spacing: 5) {
            Spacer()
            PlanButton(doesPlanExist: $doesPlanExist)
            PrivacyModeButton()
            CreateButton(active: $isCreateStackShowing)
            FindButton(active: $isSearchStackShowing)
                .disabled(nav.parent == .dashboard)
            Forecast(
                date: DateHelper.startOfDay(self.nav.session.date),
                isForecastMember: false,
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
                                showLabel: false,
                                size: .small,
                                type: .tsWhite
                            )
                            .mask(Circle())
                        } else {
                            FancyButtonv2(
                                text: "You need to create a plan first, click here!",
                                icon: "hexagon",
                                showLabel: false,
                                size: .small,
                                type: nav.parent == .planning ? .secondary : .tsWhite,
                                redirect: AnyView(Planning()),
                                pageType: .planning,
                                sidebar: AnyView(DefaultPlanningSidebar())
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
        @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false

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
                            bgColour: nav.session.job?.colour_from_stored() ?? nil,
                            showLabel: false,
                            size: .small,
                            type: active ? .secondary : .standard
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
        @AppStorage("CreateEntitiesWidget.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isSearching") private var isSearching: Bool = false

        @Binding public var active: Bool
        
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    ZStack {
                        Theme.base.opacity(0.5)
                        FancyButtonv2(
                            text: "Search",
                            action: {active.toggle() ; isSearching.toggle() ; isCreateStackShowing = false ; self.isUpcomingTaskStackShowing = false ; nav.session.search.cancel()},
                            icon: "magnifyingglass",
                            fgColour: nav.session.job?.colour_from_stored().isBright() ?? false ? .black : .white,
                            bgColour: nav.session.job?.colour_from_stored() ?? nil,
                            showLabel: false,
                            size: .small,
                            type: active ? .secondary : .standard
                        )
                        .mask(Circle())
                    }
                    .mask(Circle())
                }.frame(width: 46, height: 46)

                Text("Find")
                    .opacity(active ? 1 : 0.4)
            }
        }
    }

    struct CreateStack: View {
        @AppStorage("CreateEntitiesWidget.isCreateStackShowing") private var isCreateStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false

        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 5) {
                    FancyButtonv2(
                        text: "Company",
                        action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                        icon: "building.2",
                        fgColour: .white,
                        size: .link,
                        type: nav.parent == .notes ? .secondary : .standard,
                        redirect: AnyView(CompanyCreate()),
                        pageType: .companies,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                    Spacer()
                }

                ZStack(alignment: .topLeading) {
                    HStack(alignment: .center) {
                        Divider().frame(height: 177)
                    }
                    VStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 10)
                            }

                            HStack {
                                FancyButtonv2(
                                    text: "Person",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "person",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .people ? .secondary : .standard,
                                    redirect: AnyView(PeopleDetail()),
                                    pageType: .people,
                                    sidebar: AnyView(PeopleDashboardSidebar())
                                )
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 10)
                            }

                            HStack {
                                FancyButtonv2(
                                    text: "Project",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "folder",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .projects ? .secondary : .standard,
                                    redirect: AnyView(ProjectCreate()),
                                    pageType: .companies,
                                    sidebar: AnyView(ProjectsDashboardSidebar())
                                )
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 30)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Job",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "hammer",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .jobs ? .secondary : .standard,
                                    redirect: AnyView(JobCreate()),
                                    pageType: .jobs,
                                    sidebar: AnyView(JobDashboardSidebar())
                                )
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Note",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "note.text",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .notes ? .secondary : .standard,
                                    redirect: AnyView(NoteCreate()),
                                    pageType: .notes,
                                    sidebar: AnyView(NoteCreateSidebar())
                                )
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Task",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "checklist.checked",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard,
                                    redirect: AnyView(TaskDetail()),
                                    pageType: .tasks,
                                    sidebar: AnyView(TaskDashboardSidebar())
                                )
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Record",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "tray",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard,
                                    redirect: AnyView(Today()),
                                    pageType: .today,
                                    sidebar: AnyView(TodaySidebar())
                                )
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center) {
                                Divider().frame(width: 60)
                            }
                            HStack {
                                FancyButtonv2(
                                    text: "Definition",
                                    action: {isCreateStackShowing = false; isSearchStackShowing = false; isUpcomingTaskStackShowing = false},
                                    icon: "list.bullet.rectangle",
                                    fgColour: .white,
                                    size: .link,
                                    type: nav.parent == .tasks ? .secondary : .standard,
                                    redirect: AnyView(DefinitionDetail()),
                                    pageType: .terms,
                                    sidebar: AnyView(TermsDashboardSidebar())
                                )
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 15)
            }
        }
    }
}

extension CreateEntitiesWidget {
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

    private func findPlan() -> Void {
        let plans = CoreDataPlan(moc: moc).forDate(nav.session.date)
        if plans.count > 0 {
            if let plan = plans.first {
                doesPlanExist = !plan.isEmpty()
            }
        }
    }
}


extension CreateEntitiesWidget.PlanButton {
    private func actionOnChangeFocus() -> Void {
        if nav.session.gif == .normal {
            nav.session.gif = .focus
        } else {
            nav.session.gif = .normal
        }
    }
}
