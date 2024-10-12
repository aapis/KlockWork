//
//  AppDelegate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreSpotlight

@main
struct DLPrototype: App {
    private let persistenceController = PersistenceController.shared
    @StateObject public var updater: ViewUpdater = ViewUpdater()
    @StateObject public var nav: Navigation = Navigation()
    @State private var searching: Bool = false
    @Environment(\.scenePhase) var scenePhase
    // Assessment factors, components of the scoring and evaluation algorithm
    private var defaultFactors: [FactorProxy] {
        return [
            FactorProxy(date: self.nav.session.date, weight: 1, type: .records, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .jobs, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .jobs, action: .interaction),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .tasks, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .tasks, action: .interaction),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .notes, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .notes, action: .interaction),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .companies, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .companies, action: .interaction),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .people, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .people, action: .interaction),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .projects, action: .create),
            FactorProxy(date: self.nav.session.date, weight: 1, type: .projects, action: .interaction)
        ]
    }

    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(updater)
                .environmentObject(nav)
                .onAppear(perform: onAppear)
                .defaultAppStorage(.standard)
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlight)
                .onChange(of: scenePhase) {
                    if scenePhase == .background {
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
            Button("Quit \(appName ?? "KlockWork")") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
        //        .menuBarExtraStyle(.window)
#endif
    }

    private func onAppear() -> Void {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        nav.title = "\(appName ?? "KlockWork")"
        nav.session.plan = CoreDataPlan(moc: persistenceController.container.viewContext).forDate(nav.session.date).first

        if let plan = nav.session.plan {
            nav.planning.jobs = plan.jobs as! Set<Job>
            nav.planning.tasks = plan.tasks as! Set<LogTask>
            nav.planning.notes = plan.notes as! Set<Note>
            nav.planning.projects = plan.projects as! Set<Project>
            nav.planning.companies = plan.companies as! Set<Company>
            nav.planning.id = plan.id!
        }

        // Create default company and project if none are found, only affects new users
        let cmodel = CoreDataCompanies(moc: persistenceController.container.viewContext)
        let company = cmodel.findDefault()

        if company == nil {
            let project = CoreDataProjects(moc: persistenceController.container.viewContext).alive().first(where: {$0.company?.isDefault == true})

            cmodel.create(name: "Default", abbreviation: "DE", colour: Color.randomStorable(), created: Date(), projects: NSSet(), isDefault: true, pid: 1)

            if project == nil {
                let pmodel = CoreDataProjects(moc: persistenceController.container.viewContext)
                pmodel.create(name: "Default", abbreviation: "DE", colour: Color.randomStorable(), created: Date(), pid: 1)
            }
        }

        self.onApplicationBoot()
    }

    func application(application: any App, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        return true
    }

    private func handleSpotlight(userActivity: NSUserActivity) {
        guard let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }

        // Handle spotlight interaction
        // Maybe deep-link, or something else entirely
        // This totally depends on your app's use-case
        print("[debug][Spotlight] Item tapped: \(uniqueIdentifier)")
    }

    /// Fires when application has loaded and view appears
    /// - Returns: Void
    private func onApplicationBoot() -> Void {
        // Create the default set of assessment factors if necessary (aka, if there are no AFs)
        let factors = CDAssessmentFactor(moc: self.nav.moc).all(limit: 1).first
        if factors == nil {
            for factor in self.defaultFactors {
                factor.createDefaultFactor(using: self.nav.moc)
            }
        }

        // Create assessment Status/Threshold objects
        var allStatuses = CDAssessmentThreshold(moc: self.nav.moc).all() // @TODO: replace with a .count call instead!
        if allStatuses.isEmpty || allStatuses.count < ActivityWeight.allCases.count {
            allStatuses = CDAssessmentThreshold(moc: self.nav.moc).recreateAndReturn()
        }

        self.nav.activities.statuses = allStatuses
        self.nav.activities.assess()
    }
}
