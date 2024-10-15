//
//  WidgetLibrary.UI.Individual.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

extension WidgetLibrary.UI {
    struct Individual {
        struct Event: View {
            @EnvironmentObject public var state: Navigation
            public let event: EKEvent
            @State private var hasEventPassed: Bool = false

            var body: some View {
                SidebarItem(
                    data: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                    help: "\(event.startTime()) - \(event.endTime()): \(event.title ?? "")",
                    icon: "chevron.right",
                    orientation: .right,
                    action: {self.state.session.search.inspectingEvent = self.event},
                    showBorder: false,
                    showButton: false,
                    contextMenu: AnyView(self.contextMenu)
                )
                .background(self.hasEventPassed ? Theme.lightWhite : Color(event.calendar.color))
                .foregroundStyle(self.hasEventPassed ? Theme.lightBase : Theme.base)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.search.inspectingEvent) {
                    if let event = self.state.session.search.inspectingEvent {
                        self.state.setInspector(AnyView(Inspector(event: event)))
                    } else {
                        self.state.setInspector()
                    }
                }
            }

            @ViewBuilder var contextMenu: some View {
                Menu("Create for event") {
                    Button("Task...") {
                        let task = CoreDataTasks(moc: self.state.moc).createAndReturn(
                            content: self.event.title,
                            created: Date(),
                            due: self.event.startDate,
                            saveByDefault: false
                        )

                        self.state.session.task = task
                        self.state.to(.taskDetail)
                    }

                    Button("Note...") {
                        let note = CoreDataNotes(moc: self.state.moc).createAndReturn(
                            alive: true,
                            body: "# Notes for \(self.event.title ?? "Invalid event name")\n\n",
                            lastUpdate: Date(),
                            postedDate: Date(),
                            starred: false,
                            title: "Notes for \(self.event.title ?? "Invalid event name")"
                        )

                        self.state.session.note = note
                        self.state.to(.noteDetail)
                    }

                    if let defaultCompany = CoreDataCompanies(moc: PersistenceController.shared.container.viewContext).findDefault() {
                        Button("Project...") {
                            let project = CoreDataProjects(moc: self.state.moc).createAndReturn(
                                name: self.event.title,
                                abbreviation: StringHelper.abbreviate(self.event.title),
                                colour: Color.randomStorable(),
                                created: Date(),
                                pid: Int64(Int.random(in: 1...9999999))
                            )

                            self.state.session.company = defaultCompany
                            self.state.session.project = project
                            self.state.to(.projectDetail)
                        }

                        Button("Company...") {
                            let company = CoreDataCompanies(moc: self.state.moc).createAndReturn(
                                name: self.event.title,
                                abbreviation: StringHelper.abbreviate(self.event.title),
                                colour: Color.randomStorable(),
                                created: Date(),
                                projects: [],
                                isDefault: false,
                                pid: Int64(Int.random(in: 1...9999999))
                            )

                            self.state.session.company = company
                            self.state.to(.companyDetail)
                        }

                        Button("Job...") {
                            let job = CoreDataJob(moc: self.state.moc).createAndReturn(
                                alive: true,
                                colour: Color.randomStorable(),
                                jid: Double(Int.random(in: 1...9999999)),
                                overview: "Work related to calendar event \"\(self.event.title ?? "Invalid event name")\" on \(self.event.startDate.formatted(date: .abbreviated, time: .omitted)) from \(self.event.startTime()) - \(self.event.endTime())",
                                shredable: false,
                                title: self.event.title,
                                uri: "https://",
                                project: defaultCompany.defaultProject
                            )

                            self.state.session.company = defaultCompany
                            self.state.session.project = defaultCompany.defaultProject
                            self.state.session.job = job
                            self.state.to(.jobs)
                        }
                    }
                }
                Divider()
                Button("Inspect") {
                    self.state.session.search.inspectingEvent = self.event
                }
            }
        }
    }
}

extension WidgetLibrary.UI.Individual.Event {
    /// Onload handler. Determines if event has passed or not
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.hasEventPassed = event.startDate < Date()
    }
}
