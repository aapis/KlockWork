//
//  WidgetLibrary.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-07.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

struct WidgetLibrary {
    typealias Conf = PageConfiguration.EntityType

    struct Buttons {
        struct ResetUserChoices: View {
            @EnvironmentObject public var state: Navigation
            public var onActionClear: (() -> Void)?

            var body: some View {
                FancyButtonv2(
                    text: "Reset interface to default state",
                    action: self.onActionClear != nil ? self.onActionClear : self.defaultClearAction,
                    icon: "arrow.clockwise.square",
                    iconWhenHighlighted: "arrow.clockwise.square.fill",
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Reset interface to default state")
                .frame(width: 25)
                .disabled(self.state.session.job == nil)
                .opacity(self.state.session.job == nil ? 0.5 : 1)
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
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
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
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
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
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
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
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
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
            public var onAction: (() -> Void)? = {}

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.jobs) },
                    iconAsImage: Conf.jobs.icon,
                    iconAsImageWhenHighlighted: Conf.jobs.selectedIcon,
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
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
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
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
                    fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title2
                )
                .help("Create a new term definition")
                .frame(width: 25)
            }
        }
    }

    struct UI {
        struct Meetings: View {
            @EnvironmentObject public var state: Navigation
            @EnvironmentObject public var updater: ViewUpdater
            @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
            @AppStorage("today.calendar") public var calendar: Int = -1
            @State private var upcomingEvents: [EKEvent] = []
            @State private var calendarName: String = ""

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    if calendar > -1 {
                        HStack {
                            Image(systemName: "calendar")

                            if upcomingEvents.count == 0 || upcomingEvents.count > 1 {
                                Text("\(upcomingEvents.count) meetings today")
                                    .font(Theme.font)
                            } else {
                                Text("\(upcomingEvents.count) meeting today")
                                    .font(Theme.font)
                            }
                        }
                        .padding(5)

                        if upcomingEvents.count <= 3 {
                            VStack(alignment: .leading) {
                                ForEach(upcomingEvents, id: \.objectSpecifier) { event in
                                    HStack {
                                        let hasPassed = event.startDate >= Date()
                                        Image(systemName: hasPassed ? "arrow.right" : "checkmark")
                                            .padding(.leading, 15)
                                        Text("\(event.title) at \(event.startTime())")
                                            .foregroundColor(hasPassed ? .white : .gray)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear(perform: actionOnAppear)
                .onChange(of: calendar) { self.actionOnChangeCalendar() }
                .id(updater.get("dashboard.header"))
            }
        }
    }
}

extension WidgetLibrary.Buttons.ResetUserChoices {
    private func defaultClearAction() -> Void {
        self.state.session.job = nil
        self.state.session.project = nil
        self.state.session.company = nil
    }
}

extension WidgetLibrary.UI.Meetings {
    private func actionOnAppear() -> Void {
        if let chosenCalendar = ce.selectedCalendar() {
            calendarName = chosenCalendar
            upcomingEvents = ce.events(chosenCalendar)
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
