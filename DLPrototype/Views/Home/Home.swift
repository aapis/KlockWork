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
//    @StateObject public var pr: CoreDataProjects = CoreDataProjects(moc: PersistenceController.shared.container.viewContext)
    
    @State public var version: String?
    @State public var build: String?
    @State public var appName: String?
    @State public var selectedSidebarButton: Page = .dashboard

    private var buttons: [PageGroup: [SidebarButton]] {
        [
            .views: [
                SidebarButton(
                    destination: AnyView(Dashboard()),
                    pageType: .dashboard,
                    icon: "house",
                    label: "Dashboard"
                ),
                SidebarButton(
                    destination: AnyView(Today()),
                    pageType: .today,
                    icon: "doc.append.fill",
                    label: "Today"
                )
            ],
            .entities: [
                SidebarButton(
                    destination: AnyView(NoteDashboard()),
                    pageType: .notes,
                    icon: "note.text",
                    label: "Notes"
                ),
                SidebarButton(
                    destination: AnyView(TaskDashboard()),
                    pageType: .tasks,
                    icon: "checklist",
                    label: "Tasks"
                ),
                SidebarButton(
                    destination: AnyView(ProjectsDashboard()),
                    pageType: .projects,
                    icon: "folder",
                    label: "Projects"
                ),
                SidebarButton(
                    destination: AnyView(JobDashboard()),
                    pageType: .jobs,
                    icon: "hammer",
                    label: "Jobs"
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

                // TODO: make draggable
                ZStack {
                    Theme.headerColour
                        .opacity(0.5)
                }
                .frame(width: 1)

                // TODO: key to making custom nav links work is to allow buttons to receive/modify $selectedView
                nav.view
                    .navigationTitle("\(appName ?? "DLPrototype") \(version ?? "0").\(build ?? "0")")
                    .environmentObject(nav)
                    .environmentObject(rm)
                    .environmentObject(crm)
                    .environmentObject(jm)
                    .environmentObject(ce)
                    .environmentObject(updater)

            }
        }
        .background(Theme.base)
        .onAppear(perform: onAppear)
        .onChange(of: nav.parent!) { buttonToHighlight in
            selectedSidebarButton = buttonToHighlight
        }
    }
    
    private func redraw() -> Void {
        updater.update()
    }

    private func onAppear() -> Void {
        version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String

        nav.view = AnyView(Dashboard())
        nav.parent = selectedSidebarButton
    }
}

//struct HomePreview: PreviewProvider {
//    static var previews: some View {
//        Home(rm: LogRecords(moc: PersistenceController.preview.container.viewContext))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
//    }
//}
