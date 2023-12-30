//
//  AppDelegate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

@main
struct DLPrototype: App {
    private let persistenceController = PersistenceController.shared
    @StateObject public var updater: ViewUpdater = ViewUpdater()
    @StateObject public var nav: Navigation = Navigation()
    
    @State private var searching: Bool = false
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(updater)
                .environmentObject(nav)
                .onAppear(perform: onAppear)
                .defaultAppStorage(.standard)
                .onChange(of: scenePhase) { phase in
                    if phase == .background || phase == .inactive {
                        // @TODO: serialize/deserialize previous session data here
                        persistenceController.save()
                    }
                }
        }
        // TODO: still shows the window close/minimize/zoom,
        // see https://stackoverflow.com/questions/70501890/how-can-i-hide-title-bar-in-swiftui-for-macos-app
//        .windowStyle(.hiddenTitleBar)
        .commands {
            MainMenu(moc: persistenceController.container.viewContext, nav: nav)
        }

        #if os(macOS)
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(nav)
        }
        
        // TODO: temp commented out, too early to include this
        MenuBarExtra("name", systemImage: "clock.fill") {
            let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            // @TODO: temp commented out until I build a compatible search view
//            FindDashboard(searching: $searching)
//                .environmentObject(nav)
//            Button("Quick Record") {
//                print("TODO: implement quick record")
//            }.keyboardShortcut("1")
            
            Button("Search") {
                nav.setView(AnyView(Dashboard()))
                nav.setSidebar(AnyView(DashboardSidebar()))
                nav.setParent(.dashboard)
            }

            Divider()
            Button("Quit \(appName ?? "ClockWork")") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
//        .menuBarExtraStyle(.window)
        #endif
    }

    private func onAppear() -> Void {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        
        // https://github.com/lukakerr/NSWindowStyles
//        NSApp?.mainWindow?.styleMask.remove(.titled)
//        NSApp.presentationOptions.remove(.titled)

        nav.title = "\(appName ?? "DLPrototype") \(version ?? "0").\(build ?? "0")"
        nav.session.plan = CoreDataPlan(moc: persistenceController.container.viewContext).forDate(nav.session.date).first

        if let plan = nav.session.plan {
            nav.planning.jobs = plan.jobs as! Set<Job>
            nav.planning.tasks = plan.tasks as! Set<LogTask>
            nav.planning.notes = plan.notes as! Set<Note>
            nav.planning.projects = plan.projects as! Set<Project>
            nav.planning.companies = plan.companies as! Set<Company>
            nav.planning.id = plan.id!
        }
    }
}
