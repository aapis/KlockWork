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
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var nav: Navigation
    
    @StateObject public var rm: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var pr: CoreDataProjects = CoreDataProjects(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var cvm: CoreDataNoteVersions = CoreDataNoteVersions(moc: PersistenceController.shared.container.viewContext)
    
    @State public var selectedSidebarButton: Page = .dashboard
    @State public var selectedJob: Job?

    @AppStorage("home.isDatePickerPresented") public var isDatePickerPresented: Bool = false

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
                    destination: AnyView(Today()),
                    pageType: .today,
                    icon: "doc.append.fill",
                    label: "Today",
                    sidebar: AnyView(TodaySidebar())
                )
            ],
            .entities: [
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
                ),
                SidebarButton(
                    destination: AnyView(ProjectsDashboard()),
                    pageType: .projects,
                    icon: "folder",
                    label: "Projects",
                    sidebar: AnyView(ProjectsDashboardSidebar())
                ),
                SidebarButton(
                    destination: AnyView(JobDashboard()),
                    pageType: .jobs,
                    icon: "hammer",
                    label: "Jobs",
                    sidebar: AnyView(JobDashboardSidebar())
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
                            GlobalSidebarWidgets(isDatePickerPresented: $isDatePickerPresented)

                            if isDatePickerPresented{
                                ZStack {
                                    nav.sidebar
                                        .environmentObject(cvm)
                                        .environmentObject(nav)
                                    Color.black.opacity(0.7)
                                }
                            } else {
                                nav.sidebar
                                    .environmentObject(cvm)
                                    .environmentObject(nav)
                            }
                        }
                        .frame(width: 320)
                        .background(nav.parent != nil ? nav.parent!.colour : Theme.tabActiveColour)
                    } else {
                        HorizontalSeparator // TODO: maybe remove?
                    }

                    if isDatePickerPresented{
                        ZStack {
                            nav.view
                                .navigationTitle(nav.pageTitle())
                                .environmentObject(nav)
                                .environmentObject(rm)
                                .environmentObject(crm)
                                .environmentObject(jm)
                                .environmentObject(ce)
                                .environmentObject(cvm)
                                .environmentObject(updater)
                            Color.black.opacity(0.7)
                        }
                    } else {
                        nav.view
                            .navigationTitle(nav.pageTitle())
                            .environmentObject(nav)
                            .environmentObject(rm)
                            .environmentObject(crm)
                            .environmentObject(jm)
                            .environmentObject(ce)
                            .environmentObject(cvm)
                            .environmentObject(updater)
                    }
                }
            }
        }
        .background(Theme.base)
        .onAppear(perform: onAppear)
        .onChange(of: nav.parent!) { buttonToHighlight in
            selectedSidebarButton = buttonToHighlight
        }
        .onChange(of: nav.pageId!) { newUuid in
            updater.setOne(nav.parent!.ViewUpdaterKey, newUuid)
        }
        .onChange(of: nav.session.date) { newDate in
            if let page = nav.parent {
                if page == .today {
                    updater.updateOne("today.table")
                }
            }
        }
    }

    var HorizontalSeparator: some View {
        // TODO: make draggable
        ZStack {
            Theme.headerColour
        }
        .frame(width: 3)
    }
    
    private func redraw() -> Void {
        updater.update()
    }

    private func onAppear() -> Void {
        nav.parent = selectedSidebarButton

        // Thank you https://blog.rampatra.com/how-to-detect-escape-key-pressed-in-macos-apps
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if self.isEscapeKey(with: $0) {
                isDatePickerPresented = false
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

//struct HomePreview: PreviewProvider {
//    static var previews: some View {
//        Home(rm: LogRecords(moc: PersistenceController.preview.container.viewContext))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
//    }
//}
