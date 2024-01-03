//
//  ContentView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Home: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    @State public var selectedSidebarButton: Page = .dashboard

    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false

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
                SidebarButton(
                    destination: AnyView(Today()),
                    pageType: .today,
                    icon: "doc.append",
                    label: "Today",
                    sidebar: AnyView(TodaySidebar())
                )
            ],
            .entities: [
                SidebarButton(
                    destination: AnyView(CompanyDashboard()),
                    pageType: .companies,
                    icon: "building.2",
                    label: "Companies & Projects",
                    sidebar: AnyView(DefaultCompanySidebar())
                ),
                SidebarButton(
                    destination: AnyView(JobDashboard()),
                    pageType: .jobs,
                    icon: "hammer",
                    label: "Jobs",
                    sidebar: AnyView(JobDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(NoteDashboard()),
                    pageType: .notes,
                    icon: "note.text",
                    label: "Notes",
                    sidebar: AnyView(NoteDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(TaskDashboard()),
                    pageType: .tasks,
                    icon: "checklist",
                    label: "Tasks",
                    sidebar: AnyView(TaskDashboardSidebar())
                )
            ]
        ]
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 0) {
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

                HStack(alignment: .top, spacing: 0) {
                    if nav.sidebar != nil {
                        VStack(alignment: .leading, spacing: 0) {
                            GlobalSidebarWidgets()
                            
                            if !isSearchStackShowing {
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
                        .frame(width: 320)
                        .background(nav.parent != nil ? nav.parent!.colour : Theme.tabActiveColour)
                    } else {
                        HorizontalSeparator // TODO: maybe remove?
                    }

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
        }
        .background(Theme.base)
        .onAppear(perform: onAppear)
        .onChange(of: nav.parent!) { buttonToHighlight in
            selectedSidebarButton = buttonToHighlight
        }
    }

    var HorizontalSeparator: some View {
        // TODO: make draggable
        ZStack {
            Theme.headerColour
        }
        .frame(width: 3)
    }

    private func onAppear() -> Void {
        nav.parent = selectedSidebarButton

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
}
