//
//  Settings.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct SettingsView: View {
    private enum SettingsTabs: Hashable {
        case general, today, advanced, dashboard, notedashboard
    }

    @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTabs.general)

            TodaySettings()
                .environmentObject(ce)
                .environmentObject(nav)
                .tabItem {
                    Label("Today", systemImage: "tray")
                }
                .tag(SettingsTabs.today)

            DashboardSettings()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(SettingsTabs.dashboard)

            NoteDashboardSettings()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(SettingsTabs.notedashboard)
        }
        .padding(20)
    }
}

struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
