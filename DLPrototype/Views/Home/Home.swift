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
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    
    @StateObject public var rm: LogRecords = LogRecords(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
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
                    destination: AnyView(Planning()),
                    pageType: .planning,
                    icon: "circle.hexagongrid",
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
                                .environmentObject(nav)
                                .environmentObject(rm)
                                .environmentObject(crm)
                                .environmentObject(jm)
                                .environmentObject(ce)
                                .environmentObject(cvm)
                                .environmentObject(updater)
                                .disabled(true)
                            Color.black.opacity(0.7)
                        }
                    } else {
                        if nav.inspector != nil {
                            ZStack(alignment: .topLeading) {
                                nav.view
                                    .disabled(true)
                                
                                Color.black.opacity(0.7)

                                ZStack(alignment: .topLeading) {
                                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .topTrailing, endPoint: .topLeading)
                                        .opacity(0.25)
                                        .frame(width: 20)
                                    
                                    Theme.subHeaderColour
                                    
                                    nav.inspector
                                        .environmentObject(nav)
                                }
                                .background(Theme.base)
                                .frame(width: 340)
                            }
                            
                        } else {
                            VStack {
                                if nav.history.recent.count > 0 {
                                    HStack {
                                        Button {
                                            if let previous = nav.history.previous() {
                                                nav.to(previous.page)
                                            }
                                        } label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "arrow.left")
                                                Text("Back")
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Spacer()
                                        Button {
                                            if let next = nav.history.next() {
                                                nav.to(next.page)
                                            }
                                        } label: {
                                            HStack(spacing: 5) {
                                                Text("Next")
                                                Image(systemName: "arrow.right")
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
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

//struct HomePreview: PreviewProvider {
//    static var previews: some View {
//        Home(rm: LogRecords(moc: PersistenceController.preview.container.viewContext))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
//    }
//}
